# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

#key mode 
bindkey -v

precmd_functions+=reset-cursor

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/pedrofm/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

#Apartir de aqui esta escrito por pedrofm
#instalar plugins
source $HOME/.zsh-plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

#Remapear / para que haga una búsqueda inversa en el historial (Ctrl + r)
bindkey -M vicmd '/' history-incremental-search-backward

bindkey -M vicmd 'j' backward-char
bindkey -M vicmd 'k' down-line-or-history 
bindkey -M vicmd 'l' up-line-or-history 
bindkey -M vicmd 'ñ' forward-char 

bindkey -M visual 'j' backward-char
bindkey -M visual 'k' down-line-or-history 
bindkey -M visual 'l' up-line-or-history 
bindkey -M visual 'ñ' forward-char 

# Configuraciones para cambiar el cursor según el modo
function zle-keymap-select {
    case $KEYMAP in
        vicmd|visual)  # Modo normal y visual
            echo -ne '\e[2 q'  # Cursor bloque parpadeante
            ;;
        main|viins)  # Modo insertar
            echo -ne '\e[6 q'  # Cursor barra parpadeante
            ;;
    esac
}
zle -N zle-keymap-select

# Volver al cursor barra parpadeante al iniciar el terminal
function zle-line-init {
    echo -ne '\e[6 q'
}
zle -N zle-line-init

# Mantener el cursor barra parpadeante al terminar la línea
function zle-line-finish {
    echo -ne '\e[6 q'
}
zle -N zle-line-finish

# Resetear el cursor al cerrar la terminal
function reset-cursor {
    echo -ne '\e[6 q'
}

#Hacer que se traduzcan las rutas a su acronimo ej ~ en vez de /home/pedrofm
setopt PROMPT_SUBST

#Configurar el prompt

# Función para determinar si estás en una Distrobox
function is_in_distrobox {
  if [[ -n "$CONTAINER_ID" ]]; then
    return 0
  else
    return 1
  fi
}

# Configura el prompt basado en si estamos en una Distrobox
function set_prompt {
  local prompt_root="%F{yellow}%n@%m %F{blue}%~%f # "
  local prompt_user="%F{green}%n@%m %F{blue}%~%f $ "
  
  if [[ -n "$CONTAINER_ID" ]]; then
    prompt_root="%F{yellow}📦[%n@$CONTAINER_ID]%F %F{blue}%~%f # "
    prompt_user="%F{green}📦[%n@$CONTAINER_ID]%F %F{blue}%~%f $ "
  fi

  if [ $EUID -eq 0 ]; then
    PS1=$prompt_root
  else
    PS1=$prompt_user
  fi
}

# Llama a la función para establecer el prompt
set_prompt

# Asegúrate de llamar a set_prompt cuando cambies de directorio
autoload -U add-zsh-hook
add-zsh-hook chpwd set_prompt

# Cambiar el path
export PATH="$PATH:/home/pedrofm/.local/bin"
