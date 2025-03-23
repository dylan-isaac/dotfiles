# ==========================================================
# Modern ZSH Configuration
# Optimized for performance and developer happiness
# ==========================================================

# -----------------------------
# 1. Core ZSH Configuration
# -----------------------------
# Better history
setopt HIST_VERIFY
setopt EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Better directory navigation
setopt AUTO_CD              # cd by just typing directory
setopt AUTO_PUSHD          # push directories on every cd
setopt PUSHD_IGNORE_DUPS   # don't push duplicates

# -----------------------------
# 2. Package Management
# -----------------------------
# Ensure Homebrew commands are available
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null

# -----------------------------
# 3. Environment Variables
# -----------------------------
export EDITOR='vim'
export VISUAL='vim'
export PROJECTS=~/Projects

# Use bat as manpager for colored man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# -----------------------------
# 4. Path Configuration
# -----------------------------
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# -----------------------------
# 5. Tool Configuration
# -----------------------------

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf
)
source $ZSH/oh-my-zsh.sh

# Homebrew
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
    autoload -Uz compinit
    compinit
fi

# Node Version Manager (NVM)
export NVM_DIR="$HOME/.nvm"
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
    # Lazy load nvm for faster shell startup
    nvm() {
        unset -f nvm
        source "/opt/homebrew/opt/nvm/nvm.sh"
        source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
        nvm "$@"
    }
fi

# Python Environment
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null && {
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
}

# -----------------------------
# 6. Modern CLI Alternatives
# -----------------------------
# Modern ls replacement (eza)
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --group-directories-first'

# Modern cat replacement (bat)
alias cat='bat --paging=never'

# Modern cd replacement (zoxide)
eval "$(zoxide init zsh)"

# FZF Configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# -----------------------------
# 7. Custom Functions
# -----------------------------
# Quick project navigation
function p() {
    cd "$PROJECTS/$1"
}

# Create and enter directory
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
function extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)          echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# -----------------------------
# 8. Local Configuration
# -----------------------------
# Source local configuration if it exists
[ -f ~/.localrc ] && source ~/.localrc

# iTerm2 Integration
[ -f "${HOME}/.iterm2_shell_integration.zsh" ] && source "${HOME}/.iterm2_shell_integration.zsh"

# -----------------------------
# 9. Starship Prompt
# -----------------------------
# Initialize starship prompt
eval "$(starship init zsh)"

# -----------------------------
# 10. Custom Configuration
# -----------------------------
# Add your custom configurations below this line