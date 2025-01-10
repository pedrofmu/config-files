#!/bin/dash

GATEWAY=$(ip route | grep "default" | head -n 1 | cut -d " " -f 3)

try_dhcp() {
    posible_dhcp_clients="dhclient dhcpd" 

    for dhcp_client in $posible_dhcp_clients 
    do
        command -v $dhcp_client > /dev/null 2>&1 
        if [ $? -eq 0 ]; then
            case "$dhcp_client" in
                "dhclient")
                    echo "use the root password"
                    su -c "dhclient -r && dhclient"
                    sleep 10 
                    GATEWAY=$(ip route | grep "default" | head -n 1 | cut -d " " -f 3)
                ;;
                *) echo "error not implemented dhcp client" 
                ;;
            esac
             
        fi
    done
}

scan_local_network() {
    interface=$(ip route | grep "default" | head -n 1 | grep -oP 'dev \K[^\s]+')

    ip=$(ip a | grep $interface | grep -oP 'inet \K[^\s]+' | cut -d '/' -f 1)
    prefix=$(ip a | grep $interface | grep -oP 'inet \K[^\s]+' | cut -d '/' -f 2)

    total_ips=$(echo "2^(32 - $prefix) - 2" | bc)

    set -- $(echo $ip | sed 's/\./ /g')

    echo "$1 $2 $3 $4 | $total_ips"
}

scan_local_network

if [ -z "$GATEWAY" ]; then
    echo "The gateway is missing, check your IP configuration with 'ip a'."
    echo "What do you want to try? [search for DHCP (s) / exit (e)]"
    read result
    if [ "$result" = "s" ]; then
        try_dhcp
    else
        exit
    fi
else
    echo "The gateway is configured."
fi

ping -c 1 "$GATEWAY" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Gateway $GATEWAY is unreachable."
    echo "What do you want to try? [scan for devices in network (s) / exit (e)]"
    read result
    if [ "$result" = "s" ]; then
        scan_local_network
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
            echo "Internet is unreachable. Try contacting your network administrator for more information."
            exit
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
            echo "Internet is unreachable. Try contacting your network administrator for more information."
            exit
        fi
    else
        exit
    fi
else
    echo "DNS is working."
fi
