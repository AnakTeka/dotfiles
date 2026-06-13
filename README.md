# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/),
shared across multiple machines (a desktop and a laptop) via per-machine
packages.

## Notable scripts

Beyond the standard configs, the repo includes a number of custom scripts:

- `bin/.local/bin/i3-grouped-switcher.sh` — a grouped window switcher for i3
  (bound to `$mod+Tab`). It groups windows with a `jq` transform over the i3
  tree: configurable apps group by class, titles matching configurable regexes
  collapse into one entry, and selecting a multi-window group enters an i3 mode
  where `n`/`p` cycle through that group's windows.

- `bin/.local/bin/xm5-toggle` — toggles Sony WH-1000XM5 headphones between LDAC
  and mSBC/HFP profiles, then migrates active audio streams to the new endpoint
  (skipping portal/echo-cancel/monitor streams) and reports the active codec.

- `wireplumber/.../autoswitch-headphones-profile.lua` — a WirePlumber event hook
  that switches between Speaker and Headphones *profiles* on Intel SOF cards,
  where the two outputs sit on separate profiles (stock auto-switch only changes
  routes within one profile). Sets the target profile via a SPA Pod.

- `bin/.local/bin/cf`, `cf-x11` — copy real files to the X11 clipboard so a paste
  in a chat app attaches the file rather than its path. Sets multiple clipboard
  MIME targets and percent-encodes the URIs; `cf-x11` is a PEP 723 `uv` inline
  script that declares its own PyQt5 dependency.

- `zsh/.zshrc` (`zshaddhistory`) — commands starting with `rm` / `sudo rm` are
  saved to history prefixed with `#`, so they stay searchable but are not
  re-executed by recalling history. Paired with `rm -I` and `rm_star_wait`.

- `i3/.config/i3/scripts/pritunl-block` — i3blocks block for the Pritunl VPN
  client: maps profile IDs to readable names, supports click-to-toggle and a rofi
  menu, and opens the SSO auth URL in a designated browser profile.

- `i3/.config/i3/scripts/volume-pipewire` — cycles the default PipeWire sink among
  outputs with available ports and migrates active streams to it. An optional
  persistent mode uses a bash `coproc` to multiplex `pactl subscribe` events with
  click events.

- `i3/.config/i3/scripts/keyhint` — generates a rofi keybinding reference from the
  running i3 config by parsing `bindsym` lines, so it stays in sync with the
  actual bindings.

- `bin/.local/bin/i3-focus-next-output.sh` and siblings — multi-monitor focus and
  move helpers with wrap-around ordering; the workspace mover warps the pointer
  to the target output.

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

# 4. Stow everything for this machine. The first run asks for a role
#    (pc/laptop) and remembers it in ~/.dotfiles-machine:
./bootstrap.sh                  # or: MACHINE=pc ./bootstrap.sh

# 5. Fill in secrets (bootstrap created ~/.zshrc.local from the template):
$EDITOR ~/.zshrc.local

# 6. Reload:
exec zsh
```

`bootstrap.sh` resolves the machine **role** (from `$MACHINE`, the untracked
`~/.dotfiles-machine` file, or a one-time prompt), stows the matching
`i3-<role>` / `zsh-<role>` packages (and `wireplumber` for the laptop role),
warns about missing prerequisites, and creates `~/.zshrc.local` if absent.
Roles are derived from the `zsh-<role>` packages present, so no hostnames live
in the repo.

### Manual stow (without bootstrap)

```bash
stow --no-folding bin                       # bin MUST use --no-folding (see Gotchas)
stow i3 nvim rofi terminator tmux zsh looking-glass
stow i3-pc zsh-pc                            # or i3-laptop zsh-laptop
stow wireplumber                            # laptop only
```

## Adding a new machine

1. Create `zsh-<role>/.config/zsh/machine.zsh` and
   `i3-<role>/.config/i3/config.local` (copy an existing role and adjust the
   machine-specific paths: conda root, gcloud SDK location, monitor name,
   wallpaper, input devices). The new `<role>` is picked up automatically.
2. Run `./bootstrap.sh` and enter `<role>` when prompted (or
   `MACHINE=<role> ./bootstrap.sh`).

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
- **The machine role is local, not derived from hostname.** It's stored in the
  untracked `~/.dotfiles-machine` (or passed via `MACHINE=`), so no personal
  hostnames end up in a public repo. An unset/unknown role makes `bootstrap.sh`
  prompt and list the available roles.
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
