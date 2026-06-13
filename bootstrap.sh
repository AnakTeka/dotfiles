#!/usr/bin/env bash
# Stow the right dotfiles packages for this host.
#
# Tiers:
#   - shared packages: identical on every machine
#   - i3-<machine> / zsh-<machine>: tracked, machine-specific (conda root, displays, ...)
#   - ~/.zshrc.local: untracked secrets (see zsh/.zshrc.local.example)
#
# Usage: ./bootstrap.sh            # detect machine from hostname, stow everything
#        MACHINE=pc ./bootstrap.sh # force a machine role
set -euo pipefail
cd "$(dirname "$0")"
DOTFILES="$PWD"

# --- the repo must live at ~/.dotfiles: the shared symlinks assume this path ---
if [ "$DOTFILES" != "$HOME/.dotfiles" ]; then
  echo "WARNING: expected this repo at ~/.dotfiles, but it is at $DOTFILES." >&2
  echo "         Stow links and some configs assume ~/.dotfiles. Continue at your own risk." >&2
fi

# --- detect machine role ---
MACHINE="${MACHINE:-}"
if [ -z "$MACHINE" ]; then
  case "$(hostname)" in
    thinkpad-dipo) MACHINE=laptop ;;
    rumah-arch)    MACHINE=pc ;;
    *) echo "Unknown host '$(hostname)'; defaulting to MACHINE=pc." >&2
       echo "  Add a case for this hostname, and create zsh-<machine>/i3-<machine> packages if its paths differ." >&2
       MACHINE=pc ;;
  esac
fi
echo "==> Machine role: $MACHINE ($(hostname))"

# --- hard requirement: stow ---
if ! command -v stow >/dev/null 2>&1; then
  echo "ERROR: GNU Stow is not installed. Install it first (e.g. pacman -S stow)." >&2
  exit 1
fi

# --- soft requirements: warn loudly, because the shared .zshrc sources them unconditionally ---
missing=()
command -v zsh  >/dev/null 2>&1 || missing+=("zsh")
[ -d "$HOME/.oh-my-zsh" ]        || missing+=("oh-my-zsh (~/.oh-my-zsh)")
command -v fzf  >/dev/null 2>&1 || missing+=("fzf (>=0.48, for 'fzf --zsh')")
command -v uv   >/dev/null 2>&1 || missing+=("uv (.zshrc sources ~/.local/bin/env + uv completions)")
if [ "${#missing[@]}" -gt 0 ]; then
  echo "WARNING: these are used by the shared .zshrc and will throw errors on shell start until installed:" >&2
  for m in "${missing[@]}"; do echo "   - $m" >&2; done
fi

# --- create the untracked secrets file from the template if absent ---
if [ ! -e "$HOME/.zshrc.local" ]; then
  cp "$DOTFILES/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
  chmod 600 "$HOME/.zshrc.local"
  echo "==> Created ~/.zshrc.local from template — fill in your secrets (it is NOT tracked by git)."
fi

# --- stow ---
# bin needs --no-folding so ~/.local/bin stays a real dir (coexists with unmanaged binaries)
run_stow() {
  if ! stow "$@"; then
    echo "ERROR: stow failed for: $* " >&2
    echo "  Most likely a real file already exists at the target. Back it up and remove it, e.g.:" >&2
    echo "    mv ~/.zshrc ~/.zshrc.bak   # then re-run" >&2
    echo "  (Or 'stow --adopt' to pull the existing file INTO the repo — review the diff after!)" >&2
    exit 1
  fi
}

run_stow --no-folding bin
run_stow i3 nvim rofi terminator tmux zsh looking-glass
run_stow "i3-$MACHINE" "zsh-$MACHINE"
if [ "$MACHINE" = laptop ]; then
  run_stow wireplumber
fi

echo "==> Done. Stowed dotfiles for $MACHINE. Restart your shell (exec zsh) to pick up changes."
