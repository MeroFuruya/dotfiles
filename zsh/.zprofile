# This ZSH-Profile is originally made by Marius Kehl (github.com/MeroFuruya)

# tools used:
# - brew
#   - oh-my-posh
#   - lsd (aka lsd-rs)
#   - nvm

# Keybinds
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# oh-my-posh
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(oh-my-posh --init --shell zsh --config $(brew --prefix oh-my-posh)/themes/catppuccin_frappe.omp.json)"

# nvm setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# lsd aliases
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