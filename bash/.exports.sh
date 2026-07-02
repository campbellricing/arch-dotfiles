export KITTY_SHELL_INTEGRATION="no"

export EDITOR=nvim
export TERMINAL=kitty
export BROWSER=chromium

# History settings
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=10000
export HISTFILESIZE=20000
shopt -s histappend

# zoxide
eval "$(zoxide init bash)"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# bash_completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# claude
export PATH="$HOME/.local/bin:$PATH"
