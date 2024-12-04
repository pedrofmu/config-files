#!/bin/bash
archivo="test.txt"

# Colores
COLOR_SUCCESS='\033[0;32m'  
COLOR_FAIL='\033[0;31m'     
COLOR_RESET='\033[0m'       

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
        # Probar si el usuario puede hacer ls en el directorio 
        sudo -u "$usuario" ls "$ruta"
        if [ $? -eq 0 ]; then
            if [[ "$esperado" == "1" ]]; then
                echo -e "${COLOR_SUCCESS}success in $usuario $modo $ruta${COLOR_RESET} expected ${esperado}"
            else
                echo -e "${COLOR_FAIL}fail in $usuario $modo $ruta${COLOR_RESET} expected ${esperado}"
            fi
        else
            if [[ "$esperado" == "1" ]]; then
                echo -e "${COLOR_FAIL}fail in $usuario $modo $ruta${COLOR_RESET} expected ${esperado}"
            else
                echo -e "${COLOR_SUCCESS}success in $usuario $modo $ruta${COLOR_RESET} expected ${esperado}"
            fi
        fi
    elif [[ "$modo" == "w" ]]; then
        sudo -u "$usuario" touch "${ruta}{$usuario}ñalskjdf134"
        # Probar si el usuario tiene permisos de escritura
        if $? -eq 0; then
            if [[ "$esperado" == "1" ]]; then
                echo -e "${COLOR_SUCCESS}success in $usuario $modo $ruta${COLOR_RESET} expected ${esperado}"
            else
                echo -e "${COLOR_FAIL}fail in $usuario $modo $ruta${COLOR_RESET} expected ${esperado}"
            fi
        else
            if [[ "$esperado" == "1" ]]; then
                echo -e "${COLOR_FAIL}fail in $usuario $modo $ruta${COLOR_RESET} expected ${esperado}"
            else
                echo -e "${COLOR_SUCCESS}success in $usuario $modo $ruta${COLOR_RESET} expected ${esperado}"
            fi
        fi
        sudo -u "$usuario" rm "${ruta}{$usuario}ñalskjdf134"
    fi
done < "$archivo"
