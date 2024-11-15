# Network Configuration and UFW Setup Script 

## Overview 

This scirpt configures a server to redirect packets and enforce NAT. It is designed for Ubuntu Server 22.04 LTS, however, should work on most computers that use NetPlan and UFW. 

## Main tasks: 

1. Install and configure UFW. 
2. Allows OpenSSH connections. 
3. Set up network interfaces with Netplan. 
4. Enable IP forwarding and NAT. 

## Application 

```bash 
sudo ./script.sh <public_interface> <private_interface> <private_ip/netmask> 
``` 

## Description 

1. **Validation**: Check if the required parameters were passed. 
2. **UFW Installation**: Installs UFW and allows SSH. 
3. **Netplan**: Configure the public (DHCP) and private (static IP) interfaces. 
4. **NAT/IP Forwarding**: Enables IP forwarding and configures NAT for the private network. 
5. **Application**: Changes with 'netplan apply' and 'ufw reload' are applied.## Archivos Modificados

- `/etc/netplan/01-netcfg.yaml`
- `/etc/ufw/sysctl.conf`
- `/etc/default/ufw`
- `/etc/ufw/before.rules`

## Notes
- The script creates Netplan file backups at '/etc/netplan/'. 
- Restore settings: rename the file '.bak' and run 'netplan apply'. 
- The private ip is not the network but the device, e.g. 192.168.1.1/24
