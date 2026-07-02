#! bash oh-my-bash.module

_omb_theme_nekolight_version='1.0.0'
_omb_theme_nekolight_symbol=""

# Catppuccin Mocha
_omb_theme_mauve="203;166;247"
_omb_theme_peach="242;205;205"
_omb_theme_green="166;227;161"
_omb_theme_red="243;139;168"
_omb_theme_base="30;30;46"

function _omb_theme_nekolight_git_info() {
  if _omb_prompt_git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch
    branch=$(
      _omb_prompt_git symbolic-ref --short HEAD 2>/dev/null ||
        _omb_prompt_git rev-parse --short HEAD 2>/dev/null
    )

    local bg

    if _omb_prompt_git diff --quiet 2>/dev/null &&
      _omb_prompt_git diff --cached --quiet 2>/dev/null; then
      bg="${_omb_theme_green}"
    else
      bg="${_omb_theme_red}"
    fi

    printf "\[\e[38;2;%sm\]\[\e[48;2;%sm\e[38;2;%sm\] %s %s \[\e[38;2;%sm\e[49m\]\[\e[0m\]" \
      "$bg" \
      "$bg" \
      "${_omb_theme_base}" \
      "$_omb_theme_nekolight_symbol" \
      "$branch" \
      "$bg"
  fi
}

function _omb_theme_PROMPT_COMMAND() {

  local display_dir

  display_dir="\[\e[38;2;${_omb_theme_peach}m\]\
\[\e[48;2;${_omb_theme_peach}m\e[38;2;${_omb_theme_base}m\] 󰉋 \w \
\[\e[38;2;${_omb_theme_peach}m\e[49m\]\
\[\e[0m\]"

  local git_status
  git_status=$(_omb_theme_nekolight_git_info)

  PS1="${display_dir}"

  [[ -n $git_status ]] && PS1+=" ${git_status}"

  PS1+="\n\[\e[38;2;${_omb_theme_mauve}m\]• \[\e[0m\]"
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
