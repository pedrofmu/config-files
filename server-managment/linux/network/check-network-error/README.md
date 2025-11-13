# Network Configuration and Troubleshooting Script

Este script de shell verifica y soluciona problemas comunes de red en un sistema Linux, como la configuración de la puerta de enlace, la conectividad a Internet y la resolución de DNS.

## Funcionalidades

- **Comprobación de dependencias**: Verifica si están instaladas las herramientas necesarias (`ip`, `ping`, `bc`, `grep`, `curl`).
- **Configuración de la puerta de enlace**: Si la puerta de enlace no está configurada, intenta obtener una dirección IP por DHCP.
- **Pruebas de conectividad**:
  - Ping a la puerta de enlace predeterminada.
  - Ping a 8.8.8.8 (Internet).
  - Ping a google.com (DNS).
- **Soluciones automáticas y ayuda**: Si una prueba falla, ofrece soluciones y enlaces útiles.

## Requisitos

- `ip`
- `ping`
- `bc`
- `grep`
- `curl`
