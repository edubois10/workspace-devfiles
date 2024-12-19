#!/bin/bash

echo "Starting Base Entrypoint"

source kubedock_setup

# /home/user/ will be mounted to by a PVC if persistUserHome is enabled
mountpoint -q /home/user/; HOME_USER_MOUNTED=$?

# Note: Sometimes stow does not create the symbolic links as expected. Investigate the reason if issues arise.
# This file will be created after stowing, to guard from executing stow everytime the container is started
STOW_COMPLETE=/home/user/.stow_zsh_completed

if [ $HOME_USER_MOUNTED -eq 0 ] && [ ! -f $STOW_COMPLETE ]; then

    if [ ! -f /home/user/.oh-my-zsh/oh-my-zsh.sh ]; then
        mkdir -p /home/user/.oh-my-zsh
        echo "Executing stow for oh-my-zsh configuration" | tee -a /tmp/entrypoint.log
        stow . -t /home/user/.oh-my-zsh -d /home/tooling/.oh-my-zsh --no-folding -v 2 > /tmp/stow-zsh.log 2>&1
        echo "Stow operation completed for oh-my-zsh configuration. Logs available at /tmp/stow-zsh.log" | tee -a /tmp/entrypoint.log
    fi

    touch $STOW_COMPLETE
    echo "Stow zsh operations completed and stow completion marker created." | tee -a /tmp/entrypoint.log
fi

if [ -z "$1" ]; then
  exec tail -f /dev/null
else
  exec "$@"
fi