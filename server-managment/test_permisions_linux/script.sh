#!/bin/bash
archivo="test.txt"

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
                echo "success in $usuario $modo $ruta"
            else
                echo "fail in $usuario $modo $ruta"
            fi
        else
            if [[ "$esperado" == "1" ]]; then
                echo "fail in $usuario $modo $ruta"
            else
                echo "success in $usuario $modo $ruta"
            fi
        fi
    elif [[ "$modo" == "w" ]]; then
        # Probar si el usuario tiene permisos de escritura
        if sudo -u "$usuario" test -w "$ruta"; then
            if [[ "$esperado" == "1" ]]; then
                echo "success in $usuario $modo $ruta"
            else
                echo "fail in $usuario $modo $ruta"
            fi
        else
            if [[ "$esperado" == "1" ]]; then
                echo "fail in $usuario $modo $ruta"
            else
                echo "success in $usuario $modo $ruta"
            fi
        fi
    fi
done < "$archivo"

