# enable aliases
shopt -s expand_aliases

# system
alias reboot='reboot --no-wall'
alias poweroff='poweroff --no-wall'

# utils
alias ff='fastfetch'

# directories
alias cd='z'
alias ll='ls -l --color=always | grep -v ".DS_Store"'
alias la='ls -a --color=always | grep -v ".DS_Store"'
alias lla='ls -la --color=always | grep -v ".DS_Store"'

# git
alias gs='git status'
alias gd='git diff'
alias gaa='git add .'
alias ga='git add'
alias gr='git restore'
alias gl='git log'
alias gll='git log --oneline -n 10'
alias gf='git fetch'
alias gb='git branch'
alias gbd='git branch -d'
alias gc='git checkout'
alias gcb='git checkout -b'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gra='git restore .'
alias gst='git stash -u'

# yarn
alias yd='yarn dev --host'
alias yf='yarn format'
alias yl='yarn lint'
alias ylf='yarn lint --fix'
alias yb='yarn build'
alias ylb='yarn lint && yarn build'
