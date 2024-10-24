#!/bin/bash

public_interface=$1
private_interface=$2
private_ip=$3

# Validación de parámetros
if [ -z "$public_interface" ] || [ -z "$private_interface" ] || [ -z "$private_ip" ]; then
  echo "Uso: $0 <public_interface> <private_interface> <private_ip>"
  exit 1
fi

# Instalación de UFW
if ! apt install -y ufw; then
  echo "Error instalando ufw."
  exit 1
fi

ufw allow OpenSSH
ufw enable

# Configuración de red
for file in /etc/netplan/*.yaml; do
  if [ -f "$file" ]; then
    mv "$file" "/etc/netplan/.${file##*/}.bak"
  else
    echo "No se encontró ningún archivo YAML de configuración de Netplan en /etc/netplan."
    exit 1
  fi
done

cat <<EOF > /etc/netplan/01-netcfg.yaml
# Let NetworkManager manage all devices on this system
network:
  ethernets:
    $public_interface:
      dhcp4: true 
    $private_interface:
      dhcp4: no
      addresses:
        - $private_ip 
  version: 2
EOF

# Ajustar los permisos del archivo
chmod 600 /etc/netplan/01-netcfg.yaml

netplan apply

# Configurar NAT y enrutamiento
file_1="/etc/ufw/sysctl.conf"
if [ -f "$file_1" ]; then
  sed -i 's|#net/ipv4/ip_forward=.*|net/ipv4/ip_forward=1|' $file_1
fi

file_2="/etc/default/ufw"
if [ -f "$file_2" ]; then
  sed -i 's|DEFAULT_FORWARD_POLICY=".*"|DEFAULT_FORWARD_POLICY="ACCEPT"|' $file_2
fi

file_3="/etc/ufw/before.rules"
if [ -f "$file_3" ]; then
    if [! grep -q "#NAT\n*nat\n:POSTROUTING ACCEPT [0:0]\n-A POSTROUTING -s $private_ip -o $public_interface -j MASQUERADE\nCOMMIT\n" "$file_3"]; then
        sed -i "1s|^|#NAT\n*nat\n:POSTROUTING ACCEPT [0:0]\n-A POSTROUTING -s $private_ip -o $public_interface -j MASQUERADE\nCOMMIT\n|" "$file_3"
    fi
fi

ufw reload
