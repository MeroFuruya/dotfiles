# This ZSH-Profile is originally made by Marius Kehl (github.com/MeroFuruya)

# tools used:
# - oh-my-zsh
# - brew
#   - lsd (aka lsd-rs) - `brew install lsd`
#   - fnm - `brew install fnm`
#   - asdf - `brew install asdf`
#   - deepl-cli - `brew install kojix2/brew/deepl-cli`

export XDG_CONFIG_HOME="$HOME/.config"
export C=$XDG_CONFIG_HOME
export ZSH="$XDG_CONFIG_HOME/oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="apple"

# prevent creation of .zcompdump files in home directory
# See https://github.com/ohmyzsh/ohmyzsh/issues/7332
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

zstyle ':omz:update' mode reminder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git kitty 1password)

source $ZSH/oh-my-zsh.sh

# User configuration

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

alias zshconfig="$EDITOR ~/.zshrc"
alias ohmyzsh="$EDITOR ~/.oh-my-zsh"

# brew
eval "$(/opt/homebrew/bin/brew shellenv)"

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
fi

# asdf setup
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
# . /opt/homebrew/opt/asdf/libexec/asdf.sh

# fastfetch
FETCH_TERMS=(ghostty)
if (($FETCH_TERMS[(Ie)$TERM_PROGRAM])) then
  fastfetch
fi

# spacetimedb
export PATH="/Users/marius/.local/bin:$PATH"

# ARM Toolchain
export PATH="/Applications/ArmGNUToolchain/15.2.rel1/arm-none-eabi/bin:$PATH"

# java
export JAVA_HOME=$(brew --prefix java)/

# ssh alias
alias ssh="TERM=xterm-256color ssh"

# ghostty
alias gtty="/Applications/Ghostty.app/Contents/MacOS/ghostty"

# python aliases
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

export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc.py"

# git aliases
alias gps="git push --set-origin"
alias glf="git pull -fp"
alias gbc="git branch --show-current"
alias gb-untracked='git fetch --prune && git branch -r | awk "{print \$1}" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk "{print \$1}"'
alias gbd-untracked='git fetch --prune && git branch -r | awk "{print \$1}" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk "{print \$1}" | xargs git branch -d'

# gh aliases
function _ghma() {
  echo $@
  for arg in "$@"; do
    echo "AutoMerges and Approves PR $arg"
    gh pr merge --auto -m "$arg"
    gh pr review -a "$arg"
  done
}
alias ghma="_ghma"
alias ghrepoweb="open \$(gh repo view --json url --template '{{.url}}')"
alias ghprc="gh pr create --fill -a @me"
alias ghprm="gh pr merge --auto -m"
alias ghprmadmin="gh pr merge --admin -m"

# lsd aliases - brew install lsd
alias ll='lsd -lh'
alias la='lsd -alh'
alias tree='lsd --tree'

# uuid aliases
# alias uuidc='uuid="{$(uuidgen)}" && echo $uuid && echo -n $uuid | pbcopy'
uuidc(){uuid="{$(uuidgen)}";i=1;while [[ $i -lt ${${1}:-1} ]];do uuid="${uuid}\n{$(uuidgen)}";((i+=1))done;echo $uuid;echo -n $uuid | pbcopy}
alias uuidc="uuidc"
# alias uuid='uuid="${$(uuidgen):l}" && echo $uuid && echo -n $uuid | pbcopy'
uuid(){uuid="${$(uuidgen):l}";i=1;while [[ $i -lt ${${1}:-1} ]];do uuid="${uuid}\n${$(uuidgen):l}";((i+=1))done;echo $uuid;echo -n $uuid | pbcopy}
alias uuid="uuid"
alias uuidtoc='uuid="{${$(pbpaste):u}}" && echo $uuid && echo -n $uuid | pbcopy'
alias uuidfromc='uuid="${${${$(pbpaste):l}/\{}/\}}" && echo $uuid && echo -n $uuid | pbcopy'

# cd aliases
alias ccd='cmd="cd $(pwd)" && echo $cmd && echo -n $cmd | pbcopy'

cdgh(){cd ~/Documents/GitHub/$1; } # this must be a function to work with compdef
compdef '_files -/ -W ~/Documents/GitHub' cdgh
alias cdgh="cdgh"

# grep alias
alias ag='(){ alias | grep $@ }'

# grep history
alias hg='(){ history | grep $@ }'

# general aliases
alias q='exit'
alias relpf="exec zsh"
alias clip="pbcopy"
alias todo="code ~/Documents/TODO.md"
alias b="btop"
alias v="nvim"

# nx
alias nx="(){npx nx \$@ --outputStyle dynamic-legacy}"
alias nxserve="(){npx nx serve \$@ --outputStyle dynamic-legacy}"

alias mc2shell="ssh personal-hetzner-mc2 ./mc/shell.sh"

# brew install kojix2/brew/deepl-cli
alias en="(){echo -n \${1:-\$(</dev/stdin)} | deepl -t en ;}"
export DEEPL_AUTH_KEY="2065d661-906c-a50b-f643-6631412a044b:fx"

# image pbcopy
impbcopy() {osascript -e 'set the clipboard to (read (POSIX file '\"$PWD/$1\"') as JPEG picture)'}

# qr-gen-copy
qrgen(){ qrencode -o /tmp/qrencodecopy "$1" && viu /tmp/qrencodecopy && osascript -e 'set the clipboard to (read (POSIX file '\"/tmp/qrencodecopy\"') as JPEG picture)' }

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export ANDROID_HOME="/Users/marius/Library/Android/sdk"
