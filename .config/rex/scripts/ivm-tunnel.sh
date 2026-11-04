#!/usr/bin/env bash
# Run in a local Mac Rex terminal. Each attempt loads the existing ivm alias.
set -u
trap 'exit 0' INT TERM
while true; do
    printf '\nConnecting to IVM; Ctrl-C stops automatic reconnection.\n'
    /bin/zsh -lic 'ivm -o ExitOnForwardFailure=yes -o ServerAliveInterval=15 -o ServerAliveCountMax=3 -o ConnectTimeout=15 -L 44333:localhost:44333'
    result=$?
    printf '\nIVM connection ended (status %s). Retrying in 30 seconds.\n' "$result"
    sleep 30
done
