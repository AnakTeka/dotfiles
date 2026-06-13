# Machine-specific zsh config (laptop role). Tracked via stow:zsh-laptop.

# conda (managed by 'conda init')
__conda_setup="$('/home/yoga/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/yoga/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/home/yoga/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/home/yoga/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup

# Looking Glass client
alias lgc=/home/yoga/Downloads/looking-glass-B7-4-afbd844b/client/build/looking-glass-client

# Google Cloud SDK
if [ -f '/home/yoga/stuff/scripts/google-cloud-sdk/path.zsh.inc' ]; then . '/home/yoga/stuff/scripts/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/home/yoga/stuff/scripts/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/yoga/stuff/scripts/google-cloud-sdk/completion.zsh.inc'; fi
