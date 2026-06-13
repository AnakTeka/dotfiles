## Setup

```bash
# For most packages
stow <package-name>

# For bin package - use --no-folding to prevent ~/.local/bin from becoming a symlink
stow --no-folding bin
```

**Note:** The `bin` package requires `--no-folding` to ensure `~/.local/bin` remains a real directory and coexists with unmanaged binaries.