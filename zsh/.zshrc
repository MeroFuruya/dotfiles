# This ZSH-Profile is originally made by MeroFuruya (github.com/MeroFuruya)

# ==== Path ====

add_to_path() {
  if [[ -d "$1" ]]; then
    export PATH="$1:$PATH"
  fi
}

add_to_path "$HOME/.local/bin/"

# ARM Toolchain
add_to_path "/Applications/ArmGNUToolchain/15.2.rel1/arm-none-eabi/bin"

export ANDROID_HOME="/Users/marius/Library/Android/sdk"

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

# ==== ZSH ====

export ZSH_CONFIG="$HOME/.zshrc"

zstyle ':omz:update' mode reminder

alias zshconfig="$EDITOR ~/.zshrc"

# ==== Oh My ZSH ===

export ZSH="$XDG_CONFIG_HOME/oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="apple"

# prevent creation of .zcompdump files in home directory
# See https://github.com/ohmyzsh/ohmyzsh/issues/7332
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Add wisely, as too many plugins slow down shell startup.
plugins=(git 1password)

# Actually load and initialize OMZ
source $ZSH/oh-my-zsh.sh

# ==== Brew ====

export HOMEBREW_NO_AUTO_UPDATE=1

if [[ -f /opt/homebrew/bin/brew ]]; then
  # Initialize brew
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [[ -n "$HOMEBREW_PREFIX" ]] then
  # Initialize brew auto-completions
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
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

alias gps="git push --set-origin"
alias glf="git pull -fp"
alias gbc="git branch --show-current"
alias gb-untracked='git fetch --prune && git branch -r | awk "{print \$1}" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk "{print \$1}"'
alias gbd-untracked='git fetch --prune && git branch -r | awk "{print \$1}" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk "{print \$1}" | xargs git branch -d'

cdg() {
  # this must be a function to work with compdef
  cd "$GIT_REPOS_DIR/$1";
}
compdef '_files -/ -W $GIT_REPOS_DIR' cdg
alias cdg="cdg"

# ==== GitHub-cli ====

function ghma() {
  echo $@
  for arg in "$@"; do
    echo "AutoMerges and Approves PR $arg"
    gh pr merge --auto -m "$arg"
    gh pr review -a "$arg"
  done
}
alias ghma="ghma"

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
