#!/bin/bash
archivo="newusers.txt"

# user(0) pawwd(1) groups(2) home(3) shell(4)
while IFS= read -r linea; do
  IFS=':' read -r -a array <<< "$linea"
  IFS=',' read -r -a group_array <<< "${array[2]}"
    for grp in "${group_array[@]}"; do
       getent group "$grp" || groupadd "$grp" 
    done
  useradd -s "${array[4]}" -G "${array[2]}" -p "${array[1]}" "${array[0]}"

  if [ "${array[3]}" == "1" ]; then
        mkdir -p "/home/${array[0]}"
  fi
done < "$archivo" 
