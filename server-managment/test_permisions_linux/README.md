# Verificador de Permisos

## Descripción
Este script en Bash verifica si usuarios tienen permisos de lectura (`l`) o escritura (`w`) en rutas especificadas en un archivo de configuración.

---

## Uso rápido

1. **Preparar el archivo `newusers.txt`:**
   - Formato: `usuario,modo,ruta,resultado_esperado`
   - Ejemplo:
     ```plaintext
     jmartinez,l,./src/,1
     jmartinez,w,./bin/,1
     mmiralles,w,./bin/,0
     # Comentarios comienzan con '#'
     ```

2. **Dar permisos de ejecución al script:**
   ```bash
   chmod +x script.sh
    ```
   ```bash
   sudo ./script.sh
    ```
