#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
support="$HOME/Library/Application Support"

link() {
  local src="$1" dest="$2"

  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "skip $dest (exists and is not a symlink)" >&2
    return
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "link $dest -> $src"
}

link "$root/nvim" "$HOME/.config/nvim"
link "$root/lazygit/config.yml" "$support/lazygit/config.yml"
link "$root/lazydocker/config.yml" "$support/lazydocker/config.yml"

echo "note terminal/Basic.terminal must be imported via Terminal > Settings > Profiles"
