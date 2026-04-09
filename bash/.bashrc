# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load exports
if [ -f ~/.config/bash/.exports ]; then
  . ~/.config/bash/.exports
fi

# Enable bash completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi

# Load theme
if [ -f ~/.config/bash/ohmybash.sh ]; then
  . ~/.config/bash/ohmybash.sh
fi

# ble.sh syntax highlighting
[[ $- == *i* ]] && source /usr/share/blesh/ble.sh
bleopt prompt_status_line=
bleopt exec_errexit_mark=

# Load aliases
if [ -f ~/.config/bash/.aliases ]; then
  . ~/.config/bash/.aliases
fi
