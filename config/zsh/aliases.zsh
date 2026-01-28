# Aliases

# Fabric AI alias (installed via Homebrew as fabric-ai)
alias fabric='fabric-ai'

# Claude AI shortcuts - all support: `cmd`, `cmd c` (--continue), `cmd <uuid>` (-r <uuid>)
unalias cld cldo cldy cldyo 2>/dev/null

cld() {
  if [[ $# -eq 0 ]]; then
    claude
  elif [[ "$1" == "c" ]]; then
    claude --continue
  elif [[ "$1" =~ ^[0-9a-f-]{36}$ ]]; then
    claude -r "$1"
  else
    claude "$@"
  fi
}

cldo() {
  if [[ $# -eq 0 ]]; then
    claude --model opus
  elif [[ "$1" == "c" ]]; then
    claude --model opus --continue
  elif [[ "$1" =~ ^[0-9a-f-]{36}$ ]]; then
    claude --model opus -r "$1"
  else
    claude --model opus "$@"
  fi
}

cldy() {
  if [[ $# -eq 0 ]]; then
    claude --dangerously-skip-permissions
  elif [[ "$1" == "c" ]]; then
    claude --dangerously-skip-permissions --continue
  elif [[ "$1" =~ ^[0-9a-f-]{36}$ ]]; then
    claude --dangerously-skip-permissions -r "$1"
  else
    claude --dangerously-skip-permissions "$@"
  fi
}
# cldyo function: supports `cldyo`, `cldyo c` (--continue), `cldyo <uuid>` (-r <uuid>)
cldyo() {
  if [[ $# -eq 0 ]]; then
    claude --model opus --dangerously-skip-permissions
  elif [[ "$1" == "c" ]]; then
    claude --model opus --dangerously-skip-permissions --continue
  elif [[ "$1" =~ ^[0-9a-f-]{36}$ ]]; then
    claude --model opus --dangerously-skip-permissions -r "$1"
  else
    claude --model opus --dangerously-skip-permissions "$@"
  fi
}

# Enablement Hub alias
alias eh='/Users/dylanisaac/enablement-hub'

# Terminal utilities
alias ls='eza'
alias ll='eza -l'
alias la='eza -la'
alias tree='eza --tree'
alias cat='bat'  # If bat is installed

# Directory navigation with zoxide
alias cd='z'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# pickOS - navigate and open claude (opus + skip permissions)
alias pickOS='cd /Users/dylanisaac/Projects/pickOS && cldyo'
alias pickos='pickOS'

# Playlist sync functions
# Usage: sync-list <playlist-name> [--enhance] [concurrency]
# Wrapper around `gobbler batch youtube-playlist` for configured playlists
# Add --enhance flag to run AI enhancement on new transcripts after sync
sync-list() {
  local playlist="$1"
  local enhance=false
  local concurrency=3
  local pickos_dir="/Users/dylanisaac/Projects/pickOS"
  local output_dir=""
  
  # Parse arguments
  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --enhance|-e)
        enhance=true
        shift
        ;;
      *)
        concurrency="$1"
        shift
        ;;
    esac
  done
  
  case "$playlist" in
    ai)
      output_dir="$pickos_dir/📺 Content/📹 Youtube/AI"
      gobbler batch youtube-playlist \
        "https://www.youtube.com/playlist?list=PLRI6w0OgqPh3wSjXMjt7VpzJblH6HKg8_" \
        -o "$output_dir" \
        --timestamps \
        --concurrency "$concurrency"
      ;;
    philosophy)
      output_dir="$pickos_dir/📺 Content/📹 Youtube/Philosophy"
      gobbler batch youtube-playlist \
        "https://www.youtube.com/playlist?list=PLRI6w0OgqPh3Q0KZvnZ92kufxYIEjatG1" \
        -o "$output_dir" \
        --timestamps \
        --concurrency "$concurrency"
      ;;
    psychology)
      output_dir="$pickos_dir/📺 Content/📹 Youtube/Psychology"
      gobbler batch youtube-playlist \
        "https://www.youtube.com/playlist?list=PLRI6w0OgqPh0cFyR6u5j5KHV_emq2VbkB" \
        -o "$output_dir" \
        --timestamps \
        --concurrency "$concurrency"
      ;;
    *)
      echo "Unknown playlist: $playlist"
      echo "Available playlists: ai, philosophy, psychology"
      echo ""
      echo "Usage: sync-list <playlist> [--enhance] [concurrency]"
      echo "  --enhance, -e  Run AI enhancement on new transcripts"
      echo ""
      echo "Or use gobbler directly:"
      echo "  gobbler batch youtube-playlist <url> -o <output-dir> [--timestamps] [-c 3]"
      return 1
      ;;
  esac
  
  # Run enhancement if requested
  if [[ "$enhance" == true && -n "$output_dir" ]]; then
    echo ""
    echo "Running AI enhancement on transcripts..."
    uv run "$pickos_dir/z_scripts/enhance_transcripts.py" "$output_dir"
  fi
}

# VPS access
alias vps='ssh hetzner'

# Quick directory access
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Utility shortcuts
alias reload='source ~/.zshrc'
alias dotfiles='cd ~/dotfiles'

# Fix Antigravity hijacking file type defaults (run after app updates)
alias fix-antigravity="sed -i '' 's/<string>Default<\/string>/<string>Alternate<\/string>/g' /Applications/Antigravity.app/Contents/Info.plist && /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/Antigravity.app && echo 'Antigravity demoted to Alternate handler rank'"