
#!/bin/bash
archivo="newusers.txt"

# Colores
COLOR_SUCCESS='\033[0;32m'  # Verde para éxito
COLOR_FAIL='\033[0;31m'     # Rojo para fallo
COLOR_RESET='\033[0m'       # Restablecer el color al valor predeterminado

# user(0) mode to try(1) path(2) expected result(3)
while IFS= read -r line; do
    # Ignorar líneas vacías
    if [[ -z "$line" ]]; then
        continue
    fi

    # Procesar líneas comentadas
    if [[ "${line:0:1}" == "#" ]]; then
        continue
    fi

    # Dividir la línea en partes
    IFS=',' read -r -a entry <<< "$line"
    usuario="${entry[0]}"
    modo="${entry[1]}"
    ruta="${entry[2]}"
    esperado="${entry[3]}"

    if [[ "$modo" == "l" ]]; then
        # Probar si el usuario tiene permisos de lectura
        if sudo -u "$usuario" test -r "$ruta"; then
            if [[ "$esperado" == "1" ]]; then
                echo -e "${COLOR_SUCCESS}success in $usuario $modo $ruta${COLOR_RESET}"
            else
                echo -e "${COLOR_FAIL}fail in $usuario $modo $ruta${COLOR_RESET}"
            fi
        else
            if [[ "$esperado" == "1" ]]; then
                echo -e "${COLOR_FAIL}fail in $usuario $modo $ruta${COLOR_RESET}"
            else
                echo -e "${COLOR_SUCCESS}success in $usuario $modo $ruta${COLOR_RESET}"
            fi
        fi
    elif [[ "$modo" == "w" ]]; then
        # Probar si el usuario tiene permisos de escritura
        if sudo -u "$usuario" test -w "$ruta"; then
            if [[ "$esperado" == "1" ]]; then
                echo -e "${COLOR_SUCCESS}success in $usuario $modo $ruta${COLOR_RESET}"
            else
                echo -e "${COLOR_FAIL}fail in $usuario $modo $ruta${COLOR_RESET}"
            fi
        else
            if [[ "$esperado" == "1" ]]; then
                echo -e "${COLOR_FAIL}fail in $usuario $modo $ruta${COLOR_RESET}"
            else
                echo -e "${COLOR_SUCCESS}success in $usuario $modo $ruta${COLOR_RESET}"
            fi
        fi
    fi
done < "$archivo"
