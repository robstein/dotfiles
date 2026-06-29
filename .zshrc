export HISTSIZE=50000

_cmd_duration=0

git_prompt() {
  git rev-parse --is-inside-work-tree &>/dev/null || return

  local branch ahead behind modified staged deleted untracked

  branch=$(git symbolic-ref --short HEAD 2>/dev/null \
           || git rev-parse --short HEAD 2>/dev/null)
  [[ -z $branch ]] && return

  read ahead behind < <(git rev-list --count \
    --left-right "@{upstream}...HEAD" 2>/dev/null \
    | tr '\t' ' ')

  while IFS= read -r line; do
    local xy="${line:0:2}"
    case "$xy" in
      "??") (( untracked++ )) ;;
      ?M|M?) (( modified++ )) ;;
      ?D|D?) (( deleted++ )) ;;
    esac
    [[ "${xy:0:1}" =~ [MADRC] ]] && (( staged++ ))
  done < <(git status --porcelain 2>/dev/null)

  local info=""
  (( ahead ))     && info+=" %F{cyan}⇡${ahead}%f"
  (( behind ))    && info+=" %F{yellow}⇣${behind}%f"
  (( modified ))  && info+=" %F{yellow}✎${modified}%f"
  (( deleted ))   && info+=" %F{red}✗${deleted}%f"
  (( staged ))    && info+=" %F{green}+${staged}%f"
  (( untracked )) && info+=" %F{242}?${untracked}%f"
  [[ -z $info ]]  && info=" %F{242}clean%f"

  local bc="24"
  [[ "$branch" =~ ^(feat|feature)/ ]] && bc="magenta"
  [[ "$branch" =~ ^(fix|hotfix)/ ]]   && bc="red"

  echo " %F{$bc}${branch}%f %F{242}·%f${info}"
}

# Capture duration before each prompt draw
preexec() { _cmd_start=$SECONDS }
precmd() {
  if [[ -n $_cmd_start ]]; then
    _cmd_duration=$(( SECONDS - _cmd_start ))
    unset _cmd_start
  else
    _cmd_duration=0
  fi
}

cmd_duration_prompt() {
  (( _cmd_duration < 2 )) && return   # hide for fast commands
  local d=$_cmd_duration
  if   (( d >= 3600 )); then printf " %%F{red}%dh%dm%ds%%f"    $(( d/3600 )) $(( d%3600/60 )) $(( d%60 ))
  elif (( d >=   60 )); then printf " %%F{yellow}%dm%ds%%f"     $(( d/60 ))   $(( d%60 ))
  else                       printf " %%F{green}%ds%%f"          $d
  fi
}

setopt PROMPT_SUBST
PROMPT='%F{blue}%~%f$(git_prompt)$(cmd_duration_prompt)
%F{magenta}❯%f '

alias ls='lsd -a'
alias vim="nvim"

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local