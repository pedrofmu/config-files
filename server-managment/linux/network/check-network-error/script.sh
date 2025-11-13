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
        "gateway_missing")
            echo "The route is not configured. You can try configuring a static IP or setting up a DHCP server."
            echo "Helpful links:"
            echo "- How to set a static IP: https://www.baeldung.com/linux/set-static-ip-address"
            echo "- Setting up a DHCP server: https://ubuntu.com/server/docs/about-dynamic-host-configuration-protocol-dhcp"
        ;;
        "gateway_unreacheable")
            echo "The gateway is unreachable. This might be a problem with the firewall or a missing gateway in your network."
            echo "Helpful links:"
            echo "- Troubleshooting firewalls: https://wiki.archlinux.org/title/Firewalls"
            echo "- Understanding network gateways: https://en.wikipedia.org/wiki/Default_gateway"
        ;;
        "ping_internet_failed")
            echo "Ping to the internet failed. This might indicate a routing misconfiguration."
            echo "Helpful links:"
            echo "- Debugging routing issues: https://linux.die.net/man/8/route"
        ;;
        "dns_resolve_failed")
            echo "DNS resolution did not work. Check your DNS client configuration and the DNS server configuration."
            echo "Helpful links:"
            echo "- Configuring DNS client: https://www.cyberciti.biz/tips/linux-how-to-setup-as-dns-client.html"
            echo "- Set your own DNS server: https://ubuntu.com/server/docs/domain-name-service-dns"
        ;;
        *)
            echo "Default: No specific help available for this case."
        ;;
    esac
}


try_dhcp() {
    posible_dhcp_clients="dhclient dhcpd udhcpc connmanctl nmcli"

    for dhcp_client in $posible_dhcp_clients; do
        command -v $dhcp_client > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Using DHCP client: $dhcp_client"
            echo "Use the root password if prompted"
            case "$dhcp_client" in
                "dhclient")
                    su -c "dhclient -r && dhclient"
                ;;
                "dhcpd")
                    su -c "dhcpcd -k && dhcpcd"
                ;;
                "udhcpc")
                    interface=$(ip route | awk '/default/ {print $5; exit}')
                    if [ -z "$interface" ]; then
                        echo "No default interface found for udhcpc."
                        continue
                    fi
                    su -c "udhcpc -i $interface"
                ;;
                "connmanctl")
                    service_name=$(su -c "connmanctl services" | awk '/ethernet/ {print $NF; exit}')
                    if [ -z "$service_name" ]; then
                        echo "No Ethernet service found."
                        return 1
                    fi
                    su -c "connmanctl config $service_name --ipv4 dhcp"
                ;;
                "nmcli")
                    su -c "nmcli networking off && nmcli networking on"
                ;;
                *)
                    echo "Error: not implemented for DHCP client $dhcp_client."
                ;;
            esac
            break
        fi
    done

    sleep 10

    GATEWAY=$(ip route | awk '/default/ {print $3; exit}')
    if [ -z "$GATEWAY" ]; then
        echo "Failed to obtain a gateway via DHCP."
        return 1
    else
        echo "Gateway obtained: $GATEWAY"
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
