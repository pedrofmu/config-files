#!/bin/sh

check_dependencies() {
    for cmd in ip ping bc grep curl; do
        if ! command -v $cmd > /dev/null 2>&1; then
            echo "Command $cmd is required but not installed. Some parts of the script might fail."
            echo "What do you want to do [ continue (c) / exit (e) ]"
            read result
            if [ "$result" = "e" ]; then
                exit
            fi
        fi
    done
}
check_dependencies

GATEWAY=$(ip route | awk '/default/ {print $3; exit}')

to_dotted_dec() {
    local num="$1"
    printf "%d.%d.%d.%d" \
        $(( (num >> 24) & 0xFF )) \
        $(( (num >> 16) & 0xFF )) \
        $(( (num >>  8) & 0xFF )) \
        $((  num        & 0xFF ))
}

display_help() {
    case "$1" in
        "gateway_missing") echo "the route is not configured, you can try configuring a static ip or setting up a DHCP server." 
        ;;
        "gateway_unreacheable") echo "gateway is unreachable, it might be a problem with the firewall or a gateway not present in your network" 
        ;;
        "ping_internet_failed") echo "ping internet failed, it might be a bad configuration in the routing" 
        ;;
        "dns_resolve_failed") echo "the resolve DNS didnt work, check the dns client configuration and the DNS server configuration" 
        ;;
        *) echo default
        ;;
    esac
}

try_dhcp() {
    posible_dhcp_clients="dhclient dhcpd" 

    for dhcp_client in $posible_dhcp_clients 
    do
        command -v $dhcp_client > /dev/null 2>&1 
        if [ $? -eq 0 ]; then
            echo "use the root password"
            case "$dhcp_client" in
                "dhclient")
                    su -c "dhclient -r && dhclient"
                    sleep 10 
                ;;
                *) echo "error not implemented dhcp client" 
                ;;
            esac
        fi
    done
    GATEWAY=$(ip route | awk '/default/ {print $3; exit}')
    if [ -z "$GATEWAY" ]; then
        echo "Failed to obtain a gateway via DHCP."
        return 1
    fi
}

scan_local_network() {
    interface=$(ip route | grep "default" | head -n 1 | grep -oP 'dev \K[^\s]+')

    ip=$(ip a | grep $interface | grep -oP 'inet \K[^\s]+' | cut -d '/' -f 1)
    prefix=$(ip a | grep $interface | grep -oP 'inet \K[^\s]+' | cut -d '/' -f 2)

    total_ips=$(echo "2^(32 - $prefix) - 2" | bc)

    set -- $(echo $ip | sed 's/\./ /g')

    # Convertir IP a número de 32 bits
    ip_num=$(( ($1 << 24) + ($2 << 16) + ($3 << 8) + $4 ))

    # Crear la máscara de red a partir del CIDR
    # Ejemplo: /24 -> 255.255.255.0 en binario es 11111111.11111111.11111111.00000000
    # Máscara 32 bits: 0xFFFFFFFF << (32 - cidr)
    mask_num=$(( 0xFFFFFFFF << (32 - $prefix) & 0xFFFFFFFF ))

    network_num=$(( ip_num & mask_num ))

    host_count=0
    if [ "$prefix" -lt 31 ]; then
        host_count=$(( (1 << (32 - $prefix)) - 2 ))
    elif [ "$prefix" -eq 31 ]; then
        # /31: Usualmente se usan en enlaces punto a punto, hay 2 direcciones sin host reservados
        host_count=2
    elif [ "$prefix" -eq 32 ]; then
        # /32: Solo una dirección host
        host_count=1
    fi

    i=1
    while [ "$i" -le "$host_count" ]; do
        host_ip=$(to_dotted_dec "$((network_num + i))")
        ping -c 1 -W 2 "$host_ip" > /dev/null 2>&1 
        if [ "$?" -eq 0 ]; then
            echo "$host_ip is up, check if it is a valid gateway"
        fi
        i=$((i+1))
    done
}

if [ -z "$GATEWAY" ]; then
    echo "The gateway is missing, check your IP configuration with 'ip a'."
    echo "What do you want to try? [search for DHCP (s) / display common help (h) / exit (e)]"
    read result
    if [ "$result" = "s" ]; then
        try_dhcp
    elif [ "$result" = "h" ]; then
         display_help "gateway_missing"  
    else
        exit
    fi
else
    echo "The gateway is configured."
fi

ping -c 1 "$GATEWAY" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Gateway $GATEWAY is unreacheable."
    echo "What do you want to try? [scan for devices in network (s) / display common help (h) / exit (e)]"
    read result
    if [ "$result" = "s" ]; then
        scan_local_network
    elif [ "$result" = "h" ]; then
         display_help "gateway_unreacheable"  
    else
        exit
    fi
else
    echo "The gateway is reachable."
fi

ping -c 1 8.8.8.8 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Ping to the internet failed. Do you want to try a curl? [yes (y) / exit (e)]"
    read result
    if [ "$result" = "y" ]; then
        curl -s 172.217.16.195 > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Internet is reachable; it was a problem with ping."
        else
            echo "Internet is unreachable. What do you want to do? [display common help (h) / exit (e)]"
            read result
            if [ "$result" = "h" ]; then
                display_help "ping_internet_failed"
            else
                exit
            fi
        fi
    fi
else
    echo "The internet is reachable."
fi


ping -c 1 google.com > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Ping with DNS failed. Do you want to try a curl? [yes (y) / exit (e)]"
    read result
    if [ "$result" = "y" ]; then
        curl -s google.com > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Internet with DNS worked; it was a problem with ping."
        else
            echo "Dns didnt work. What do you want to do? [display common help (h) / exit (e)]"
            read result
            if [ "$result" = "h" ]; then
                display_help "dns_resolve_failed"
            else
                exit
            fi
        fi
    else
        exit
    fi
else
    echo "DNS is working."
fi
