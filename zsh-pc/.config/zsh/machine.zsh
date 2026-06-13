# Machine-specific zsh config for rumah-arch (PC). Tracked via stow:zsh-pc.

# conda (managed by 'conda init')
__conda_setup="$('/home/yoga/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/yoga/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/yoga/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/yoga/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# Looking Glass client
alias lgc=/home/yoga/stuff/git_repository/LookingGlass/client/build/looking-glass-client

# Google Cloud SDK
if [ -f '/home/yoga/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/home/yoga/Downloads/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/home/yoga/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/yoga/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
