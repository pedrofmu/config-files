# Network Configuration and UFW Setup Script

## Overview

Este scirpt configura un servidor para redireccionar paquetes y aplicar el NAT. Esta pensado para
Ubuntu Server 22.04 LTS, sin embargo debería funcionar en la mayoria de equipos que utilicen
NetPlan y UFW.

### Tareas principales:
1. Instala y configura UFW.
2. Permite conexiones OpenSSH.
3. Configura interfaces de red con Netplan.
4. Habilita IP forwarding y NAT.


## Uso

```bash
sudo ./script.sh <public_interface> <private_interface> <private_ip>
```

## Descripción

1. **Validación**: Comprueba si se pasaron los parámetros requeridos.
2. **Instalación UFW**: Instala UFW y permite SSH.
3. **Netplan**: Configura las interfaces públicas (DHCP) y privadas (IP estática).
4. **NAT/IP Forwarding**: Habilita el reenvío de IP y configura NAT para la red privada.
5. **Aplicación**: Se aplican los cambios con `netplan apply` y `ufw reload`.

## Archivos Modificados

- `/etc/netplan/01-netcfg.yaml`
- `/etc/ufw/sysctl.conf`
- `/etc/default/ufw`
- `/etc/ufw/before.rules`

## Notas

- El script crea copias de seguridad de archivos Netplan en `/etc/netplan/`.
- Restaurar configuración: renombrar el archivo `.bak` y ejecutar `netplan apply`.
