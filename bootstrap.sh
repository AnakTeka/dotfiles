#!/usr/bin/env bash
# Stow the right dotfiles packages for this host.
#
# Tiers:
#   - shared packages: identical on every machine
#   - i3-<machine> / zsh-<machine>: tracked, machine-specific (conda root, displays, ...)
#   - ~/.zshrc.local: untracked secrets (see zsh/.zshrc.local.example)
set -euo pipefail
cd "$(dirname "$0")"

case "$(hostname)" in
  thinkpad-dipo) MACHINE=laptop ;;
  rumah-arch)    MACHINE=pc ;;
  *) echo "Unknown host '$(hostname)'; defaulting to pc" >&2; MACHINE=pc ;;
esac

# bin needs --no-folding so ~/.local/bin stays a real dir (coexists with unmanaged binaries)
stow --no-folding bin

stow i3 nvim rofi terminator tmux zsh looking-glass
stow "i3-$MACHINE" "zsh-$MACHINE"

if [ "$MACHINE" = laptop ]; then
  stow wireplumber
fi

echo "Stowed dotfiles for $MACHINE ($(hostname))."
