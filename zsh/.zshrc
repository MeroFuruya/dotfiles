# This ZSH-Profile is originally made by MeroFuruya (github.com/MeroFuruya)

# ==== Profile-Profiling ====

if [[ -n $ZSH_PROFILE_PROFILING ]]; then
  zmodload zsh/zprof
fi

# ==== Path ====

add_to_path() {
  if [[ -d "$1" ]]; then
    export PATH="$1:$PATH"
  fi
}

add_to_path "$HOME/.local/bin/"

# ARM Toolchain
add_to_path "/Applications/ArmGNUToolchain/15.2.rel1/arm-none-eabi/bin"

# ==== Basic Env Vars ====

# XDG Folders
export XDG_CONFIG_HOME="$HOME/.config"
export C=$XDG_CONFIG_HOME

# Preferred editor
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  export EDITOR='code'
elif [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

# Android
export ANDROID_HOME="/Users/marius/Library/Android/sdk"

# ==== ZSH ====

export ZSH_CONFIG="$HOME/.zshrc"

zstyle ':omz:update' mode reminder

alias zshconfig="$EDITOR ~/.zshrc"

# prevent creation of .zcompdump files in home directory
# See https://github.com/ohmyzsh/ohmyzsh/issues/7332
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

# ==== ZLE Bindings ====

# Keep the terminal in application-keypad mode while ZLE is active so that
# terminfo key sequences are valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
  zle-line-init()   { echoti smkx }
  zle-line-finish() { echoti rmkx }

  zle -N zle-line-init
  zle -N zle-line-finish
fi

# Bind a terminfo sequence if it exists.
bind-terminfo() {
  [[ -n "$1" ]] && bindkey -M emacs "$1" "$2"
}

# Use Emacs-style line editing.
bindkey -e


# History

autoload -U up-line-or-beginning-search \
            down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# [Up] / [Down] - search history by the already typed prefix
bindkey -M emacs '^[[A' up-line-or-beginning-search
bindkey -M emacs '^[[B' down-line-or-beginning-search

bind-terminfo "${terminfo[kcuu1]}" up-line-or-beginning-search
bind-terminfo "${terminfo[kcud1]}" down-line-or-beginning-search

# [Ctrl-R] - incremental backward history search
bindkey '^r' history-incremental-search-backward


# Navigation

# [Home] / [End] - move to beginning/end of line
bind-terminfo "${terminfo[khome]}" beginning-of-line
bind-terminfo "${terminfo[kend]}"  end-of-line

# [Ctrl-Right] / [Ctrl-Left] - move by word
bindkey -M emacs '^[[1;5C' forward-word
bindkey -M emacs '^[[1;5D' backward-word

# [Shift-Tab] - move backwards through the completion menu
bind-terminfo "${terminfo[kcbt]}" reverse-menu-complete


# Editing

# [Backspace] - delete backwards
bindkey -M emacs '^?' backward-delete-char

# [Delete] - delete forwards
if [[ -n "${terminfo[kdch1]}" ]]; then
  bindkey -M emacs "${terminfo[kdch1]}" delete-char
else
  bindkey -M emacs '^[[3~' delete-char
fi

# [Ctrl-Delete] - delete the next word
bindkey -M emacs '^[[3;5~' kill-word

# [Esc-W] - kill from cursor to mark
bindkey '\ew' kill-region


# Miscellaneous

# [Space] - expand history references such as !! and !$
bindkey ' ' magic-space

# ==== Brew ====

export HOMEBREW_NO_AUTO_UPDATE=1

if [[ -f /opt/homebrew/bin/brew ]]; then
  # Initialize brew
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [[ -n "$HOMEBREW_PREFIX" ]] then
  # Initialize brew auto-completions
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

add_to_path_brew() {
  if [[ -n "$HOMEBREW_PREFIX" ]] then
    return 0;
  fi
  
  local BREW_REFIX
  if BREW_REFIX=$(brew --prefix --installed $1 2> /dev/null); then
    if [[ -n "$2" ]]; then
      add_to_path "$BREW_PREFIX/${2}";
    else
      add_to_path "$BREW_PREFIX";
    fi
  fi
}

# Reload Completion Cache

autoload -Uz compinit
compinit

# Postgres
add_to_path_brew "libpq" "bin"
add_to_path_brew "postgresql@16" "bin"


# java
local JAVA_BREW_REFIX
if JAVA_BREW_REFIX=$(brew --prefix --installed $1 2> /dev/null); then
  export JAVA_HOME="$JAVA_BREW_REFIX/"
fi

# ==== asdf ====

export ASDF_DATA_DIR="${ASDF_DATA_DIR:-"$HOME/.asdf"}"

if [[ -d "$ASDF_DATA_DIR" ]]; then
  add_to_path "${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
fi

# ==== 1Password ====

op_get_credential() {
  if [[ $# != 3 ]]; then
    echo "Usage: <account-id> <item-id> <field>" >&2
    return 1
  fi
  op item get $2 --reveal --fields label=$3 --account $1
}

local OP_PLUGINS_FILE="$XDG_CONFIG_HOME/op/plugins.sh"
if [[ -f "$OP_PLUGINS_FILE" && ! -n $OP_PLUGIN_ALIASES_SOURCED ]]; then
  source "$OP_PLUGINS_FILE"
fi

# ==== Basic Aliases ====

alias ssh="TERM=xterm-256color ssh"

alias ghostty="/Applications/Ghostty.app/Contents/MacOS/ghostty"

if type lsd &> /dev/null; then
  alias ll='lsd -lh'
  alias la='lsd -alh'
  alias tree='lsd --tree'
fi

alias q='exit'
alias relpf="exec zsh"
alias clip="pbcopy"
alias todo="code ~/Documents/TODO.md"
alias b="btop"
alias v="nvim"
alias e="$EDITOR"

alias ag='(){ alias | grep $@ }'
alias hg='(){ history | grep $@ }'

alias nx="(){npx nx \$@ --outputStyle dynamic-legacy}"
alias nxserve="(){npx nx serve \$@ --outputStyle dynamic-legacy}"

alias mc2shell="ssh personal-hetzner-mc2 ./mc/shell.sh"

# ==== Python ====
export PIP_REQUIRE_VIRTUALENV=true
function _pyvenv() {
  venv_dirname=${1:-.venv}
  if [ -n "${VIRTUAL_ENV+1}" ]; then
    echo "Deactivating currently active venv"
    deactivate
  fi

  if [ ! -d "$venv_dirname" ]; then
    echo "Create new $venv_dirname"
    virtualenv --python "$(asdf where python)/bin/python" "$venv_dirname";
  fi
  echo "Activate $venv_dirname"
  source "$venv_dirname/bin/activate"
}

alias pyvenv="_pyvenv"

# export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc.py"

# ==== git ====
export GIT_REPOS_DIR="$HOME/repos"

function git_current_branch() {
  local ref
  ref=$(__git_prompt_git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  
  local remote ref
  
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done
  
  # Fallback: try to get the default branch from remote HEAD symbolic refs
  for remote in origin upstream; do
    ref=$(command git rev-parse --abbrev-ref $remote/HEAD 2>/dev/null)
    if [[ $ref == $remote/* ]]; then
      echo ${ref#"$remote/"}; return 0
    fi
  done

  # If no main branch was found, fall back to master but return error
  echo master
  return 1
}

cdg() {
  # this must be a function to work with compdef
  cd "$GIT_REPOS_DIR/$1";
}
compdef '_files -/ -W $GIT_REPOS_DIR' cdg

alias gps="git push --set-origin"
alias glf="git pull -fp"
alias gbc="git branch --show-current"
alias gb-untracked='git fetch --prune && git branch -r | awk "{print \$1}" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk "{print \$1}"'
alias gbd-untracked='git fetch --prune && git branch -r | awk "{print \$1}" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk "{print \$1}" | xargs git branch -d'
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
alias gcmsg='git commit --message'
alias gd='git diff'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gms="git merge --squash"
alias gmff="git merge --ff-only"
alias gmom='git merge origin/$(git_main_branch)'
alias gmum='git merge upstream/$(git_main_branch)'
alias gl='git pull'
alias gp='git push'
alias gpsup='git push --set-upstream origin $(git_current_branch)'
alias gsw='git switch'
alias gswc='git switch --create'
alias gswm='git switch $(git_main_branch)'

# ==== GitHub-cli ====

function ghma() {
  echo $@
  for arg in "$@"; do
    echo "AutoMerges and Approves PR $arg"
    gh pr merge --auto -m "$arg"
    gh pr review -a "$arg"
  done
}

alias ghrepoweb="open \$(gh repo view --json url --template '{{.url}}')"
alias ghprc="gh pr create --fill -a @me"
alias ghprm="gh pr merge --auto -m"
alias ghprmadmin="gh pr merge --admin -m"

# ==== UUID ====

uuidc(){
  local uuid="{$(uuidgen)}";
  local i=1;
  
  while [[ $i -lt ${${1}:-1} ]]; do
    uuid="${uuid}\n{$(uuidgen)}";
    ((i+=1))
  done;
  echo $uuid;
  echo -n $uuid | pbcopy
}
alias uuidc="uuidc"

uuid(){
  local uuid="${$(uuidgen):l}";
  local i=1;
  
  while [[ $i -lt ${${1}:-1} ]]; do
    uuid="${uuid}\n${$(uuidgen):l}";
    ((i+=1))
  done;
  
  echo $uuid;
  echo -n $uuid | pbcopy
}
alias uuid="uuid"

alias uuidtoc='uuid="{${$(pbpaste):u}}" && echo $uuid && echo -n $uuid | pbcopy'
alias uuidfromc='uuid="${${${$(pbpaste):l}/\{}/\}}" && echo $uuid && echo -n $uuid | pbcopy'

# ==== deepl-cli ====

# this tool can be installed via:
# brew install kojix2/brew/deepl-cli

if type deepl &> /dev/null; then
  deepl() {
    if [[ ! -n "$DEEPL_AUTH_KEY" ]]; then
      export DEEPL_AUTH_KEY="$(op item get jvcbeehd466j6eemmt7fkhvc6u --reveal --fields label=credential --account RYFUCHTX2RDM5BHXFVCGANRZAY)"
    fi
    /usr/bin/env deepl $@
  }
  alias deepl="deepl"

  deepl-en() {
    local VALUE="${1:-"$(</dev/stdin)"}"
    echo -n $VALUE | deepl -t en
  }
  alias deepl-en="deepl-en"
fi

# ==== Image Helpers ====

imgcopy() {
  local file
  file="$(realpath "$1")" || return

  osascript -e "set the clipboard to (read (POSIX file \"$file\") as JPEG picture)"
}

qrgen() {
  if ! type qrencode &> /dev/null; then
    echo "qrencode is required; Can be installed via \"brew install qrencode\""
    return 1
  fi

  local OUT_FILE="$TMPDIR/zsh_qrcode_image_$(uuidgen).jpeg"

  if ! qrencode -o "$OUT_FILE" $@; then
    return $?
  fi

  if type viu &> /dev/null; then
    viu -w 30 "$OUT_FILE"
  fi

  imgcopy "$OUT_FILE"
}

# ==== AWS ====

export AWS_DEFAULT_OUTPUT="json"

# ==== Docker ====

export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export DOCKER_HOST="unix://${XDG_CONFIG_HOME}/colima/default/docker.sock"

# ==== Completion ====
# if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' "$ZSH_COMPDUMP" 2>/dev/null)" ]; then
#   compinit
# else
#   compinit -C
# fi

eval "$(starship init zsh)"

# ==== Profile-Profiling ====

if [[ -n $ZSH_PROFILE_PROFILING ]]; then
  zprof
fi

