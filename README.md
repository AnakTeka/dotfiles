# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/),
shared across multiple machines (a desktop `rumah-arch` and a laptop
`thinkpad-dipo`).

## Architecture

Config is split into three tiers so the same repo works on every machine
without constant merge conflicts:

| Tier | Lives in | Tracked? | Examples |
|------|----------|----------|----------|
| **Shared** | base packages (`zsh`, `i3`, `nvim`, …) | ✅ git | prompt, keybinds, history, scripts — identical everywhere |
| **Per-machine** | `zsh-<machine>` / `i3-<machine>` | ✅ git | conda root, gcloud path, monitor/xrandr, touchpad |
| **Secrets** | `~/.zshrc.local` | ❌ untracked | API keys, work-only helpers (never committed) |

The shared `zsh/.zshrc` is byte-identical on every machine. At the end it sources
`~/.config/zsh/machine.zsh` (the per-machine package) and then `~/.zshrc.local`
(secrets). i3's shared `config` ends with `include ~/.config/i3/config.local`,
which each machine provides via its `i3-<machine>` package.

## Packages

```
bin            ~/.local/bin scripts (i3 helpers, etc.)
i3             shared i3 config, scripts, i3blocks
i3-pc          PC i3 overrides     (xrandr, wallpaper)
i3-laptop      laptop i3 overrides (touchpad, power, suspend)
zsh            shared .zshrc (+ .zshrc.local.example template)
zsh-pc         PC machine.zsh      (miniconda3, gcloud paths)
zsh-laptop     laptop machine.zsh  (miniforge3, gcloud paths)
nvim           Neovim / AstroNvim config
rofi           rofi theme
terminator     terminator config
tmux           tmux config
looking-glass  Looking Glass client config
wireplumber    laptop-only audio profile auto-switch (Intel SOF)
```

## Prerequisites

Install these **before** stowing — the shared `.zshrc` references them
unconditionally and will error on every shell start otherwise:

- **GNU Stow** — the symlink manager (required to install at all)
- **zsh** + **[Oh My Zsh](https://ohmyz.sh/)** at `~/.oh-my-zsh`
- **[fzf](https://github.com/junegunn/fzf)** ≥ 0.48 (the `.zshrc` runs `fzf --zsh`)
- **[uv](https://docs.astral.sh/uv/)** (the `.zshrc` sources `~/.local/bin/env` + uv completions)

Optional, per package you use:

- **i3** suite: `i3`, `i3blocks`, `rofi`, `picom`, `dunst`, `feh`, `xidlehook`, plus
  `xorg-xrandr` / `xorg-xinput`. Some i3blocks scripts expect `pritunl-client` / `nordvpn`.
- **Neovim ≥ 0.12** for the `nvim` package (AstroNvim v6; aerial is pinned for 0.12).
- **conda** (miniconda3 on PC / miniforge3 on laptop) if you want the conda hook.

## Installation

```bash
# 1. Clone to ~/.dotfiles  (this exact path matters — links assume it)
git clone git@github.com:AnakTeka/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Install the prerequisites above.

# 3. Back up any pre-existing dotfiles that would collide (see Gotchas).
#    e.g.  mv ~/.zshrc ~/.zshrc.bak

# 4. Stow everything for this machine (auto-detects hostname):
./bootstrap.sh

# 5. Fill in secrets (bootstrap created ~/.zshrc.local from the template):
$EDITOR ~/.zshrc.local

# 6. Reload:
exec zsh
```

`bootstrap.sh` picks the right `i3-<machine>` / `zsh-<machine>` (and
`wireplumber` on the laptop) from the hostname, warns about missing
prerequisites, and creates `~/.zshrc.local` if absent.

### Manual stow (without bootstrap)

```bash
stow --no-folding bin                       # bin MUST use --no-folding (see Gotchas)
stow i3 nvim rofi terminator tmux zsh looking-glass
stow i3-pc zsh-pc                            # or i3-laptop zsh-laptop
stow wireplumber                            # laptop only
```

## Adding a new machine

1. Add a `case` arm for its hostname in `bootstrap.sh` mapping it to a role.
2. Create `zsh-<machine>/.config/zsh/machine.zsh` and
   `i3-<machine>/.config/i3/config.local` (copy an existing one and adjust the
   machine-specific paths: conda root, gcloud SDK location, monitor name,
   wallpaper, input devices).
3. Run `./bootstrap.sh`.

## Gotchas

- **Stow refuses to overwrite existing real files.** A fresh machine usually
  already has `~/.zshrc`, `~/.tmux.conf`, `~/.config/nvim`, etc. Stow aborts with
  *"existing target is neither a link nor a directory"*. Move them aside first
  (`mv ~/.zshrc ~/.zshrc.bak`). `stow --adopt` is the alternative but it pulls the
  **existing** file's contents into the repo — review `git diff` before committing.
- **`bin` must be stowed with `--no-folding`.** Otherwise stow turns
  `~/.local/bin` into a single symlink into the repo, which breaks coexistence
  with non-dotfiles binaries installed there.
- **The repo must live at `~/.dotfiles`.** Shared symlinks and configs assume
  this path; cloning elsewhere needs `stow --target=$HOME` and may still break.
- **`~/.zshrc.local` is untracked by design.** It holds secrets (API keys) and
  work-only tooling. `bootstrap.sh` seeds it from `zsh/.zshrc.local.example`.
  **Never commit it** — the repo is public. Back it up out-of-band (password
  manager / private gist), since git won't.
- **Unknown hostnames default to `pc`.** `bootstrap.sh` prints a warning; add a
  `case` arm before relying on it.
- **Per-machine paths are absolute.** `zsh-<machine>/machine.zsh` hardcodes conda
  roots (`miniconda3` vs `miniforge3`) and gcloud SDK locations; the i3
  `config.local` hardcodes the monitor name (`DP-0`) and `~/Pictures/wallpaper.png`.
  A new machine needs its own values — these intentionally do **not** auto-detect.
- **Neovim 0.12+ required** for the `nvim` package (AstroNvim v6).
- **`wireplumber` is laptop-only** (Intel SOF headphone auto-switch). Don't stow
  it elsewhere; `bootstrap.sh` already skips it off the laptop.
- **Prerequisites are load-bearing.** Missing `fzf`/`uv`/`oh-my-zsh` won't just
  disable a feature — they throw errors on every new shell because `.zshrc`
  sources them unconditionally.
