# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load exports
if [ -f ~/.config/bash/.exports.sh ]; then
  . ~/.config/bash/.exports.sh
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
[[ $- == *i* ]] && source ~/.local/share/blesh/ble.sh
bleopt prompt_status_line=
bleopt exec_errexit_mark=

# Load aliases
if [ -f ~/.config/bash/.aliases.sh ]; then
  . ~/.config/bash/.aliases.sh
fi
