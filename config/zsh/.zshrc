# Zsh Configuration - No Framework
# Managed by dotfiles

# History configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# Completion
autoload -Uz compinit
compinit

# Emacs mode (default keybindings)
bindkey -e

# Useful emacs-style keybindings:
# Ctrl+A - Beginning of line
# Ctrl+E - End of line
# Ctrl+W - Delete word backward
# Ctrl+U - Delete to beginning
# Ctrl+K - Delete to end
# Ctrl+R - Search history (handled by atuin)

# PATH configuration
export PATH="$HOME/.local/bin:$PATH"

# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Java configuration
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# Load aliases
source "$HOME/dotfiles/config/zsh/aliases.zsh"

# Load functions
for func in "$HOME/dotfiles/config/zsh/functions"/*.zsh; do
  [ -r "$func" ] && source "$func"
done

# Initialize Starship prompt
eval "$(starship init zsh)"

# Initialize utilities (loaded after starship to avoid conflicts)
# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide
eval "$(zoxide init zsh)"

# atuin
eval "$(atuin init zsh --disable-up-arrow)"

# carapace completions
source <(carapace _carapace)

# Additional completion configuration
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
# bun completions
[ -s "/Users/dylanisaac/.bun/_bun" ] && source "/Users/dylanisaac/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export AWS_PROFILE=uic

# Machine-specific secrets (not in git)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Added by Antigravity
export PATH="/Users/dylanisaac/.antigravity/antigravity/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/dylanisaac/.lmstudio/bin"
# End of LM Studio CLI section


fpath+=~/.zfunc; autoload -Uz compinit; compinit
export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"

# bookclub shell completion
eval "$(bookclub completion zsh)"
