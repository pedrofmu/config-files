#!/bin/bash
archivo="newusers.txt"

# user(0) pawwd(1) groups(2) home(3) shell(4)
while IFS= read -r linea; do
  IFS=':' read -r -a array <<< "$linea"
  IFS=',' read -r -a group_array <<< "${array[2]}"
    for grp in "${group_array[@]}"; do
       getent group "$grp" || groupadd "$grp" 
    done
  useradd -s "${array[4]}" -G "${array[2]}" "${array[0]}"
  echo "${array[0]}:${array[1]}" | chpasswd

  IFS=',' read -r -a home_array <<< "${array[3]}"
  if [ "${home_array[0]}" == "1" ]; then
        mkdir -p "${home_array[1]}"
        chmod -R "${array[0]}" "${home_array[1]}"
  fi
done < "$archivo" 
