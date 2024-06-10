# This ZSH-Profile is originally made by Marius Kehl (github.com/MeroFuruya)

# tools used:
# - oh-my-zsh
# - brew
#   - lsd (aka lsd-rs) - `brew install lsd`
#   - fnm - `brew install fnm`
#   - deepl-cli - `brew install kojix2/brew/deepl-cli`


export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="apple"

zstyle ':omz:update' mode reminder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git kitty)

source $ZSH/oh-my-zsh.sh

# User configuration

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='nano'
fi

alias zshconfig="$EDITOR ~/.zshrc"
alias ohmyzsh="mate ~/.oh-my-zsh"

# brew
eval "$(/opt/homebrew/bin/brew shellenv)"

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
fi

# fnm setup
eval "$(fnm env --use-on-cd)"

# lsd aliases - brew install lsd
alias ld='lsd'
alias ll='lsd -l'
alias la='lsd -al'
alias tree='lsd --tree'

# uuid aliases
alias uuidc='uuid="{$(uuidgen)}" && echo $uuid && echo -n $uuid | pbcopy'
alias uuid='uuid="${$(uuidgen):l}" && echo $uuid && echo -n $uuid | pbcopy'
alias uuidtoc='uuid="{${$(pbpaste):u}}" && echo $uuid && echo -n $uuid | pbcopy'
alias uuidfromc='uuid="${${${$(pbpaste):l}/\{}/\}}" && echo $uuid && echo -n $uuid | pbcopy'

# cd aliases
alias ccd='cmd="cd $(pwd)" && echo $cmd && echo -n $cmd | pbcopy'
alias cdgh='(){cd ~/Documents/GitHub/$1 ;}'

# general aliases
alias q='exit'
alias relpf="exec zsh"
alias clip="pbcopy"

# brew install kojix2/brew/deepl-cli
alias en="(){echo -n \${1:-\$(</dev/stdin)} | deepl -t en ;}"
export DEEPL_AUTH_KEY="2065d661-906c-a50b-f643-6631412a044b:fx"
