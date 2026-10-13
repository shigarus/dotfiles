#!/usr/bin/env bash
# VIBECODED
# Open a directory picker popup, then a Neovim window in the originating session.
set -u

fail() {
    printf 'New Neovim window: %s\n' "$*" >&2
    tmux display-message "New Neovim window: $*" 2>/dev/null || true
    exit 1
}

# run-shell expands formats; display-popup's command and -e values do not.
# Pass the expanded session and client IDs into this launcher as shell-quoted
# arguments, then transfer the literal session ID to the popup's environment.
if [[ ${1:-} == --popup ]]; then
    [[ $# -eq 3 ]] || fail 'Expected a target session and client.'
    # Expand HOME in the popup's shell, not in this launcher.
    # shellcheck disable=SC2016
    exec tmux display-popup -c "$3" -E -w 80% -h 80% -T 'New Neovim window' \
        -e "NVIM_TMUX_TARGET_SESSION=$2" \
        'bash "$HOME/.config/tmux/scripts/new-nvim-window.sh"'
fi

target_session=${NVIM_TMUX_TARGET_SESSION:-}
[[ -n $target_session ]] || fail 'No target tmux session was provided.'
for dependency in find fzf nvim; do
    command -v "$dependency" >/dev/null 2>&1 || fail "Missing dependency: $dependency"
done
nvim_path=$(command -v nvim)

# Only directories enter fzf. Keep absolute paths so the initial home query can
# be erased to search anywhere under /. Do not traverse virtual filesystems.
# NUL delimiters preserve spaces, quotes, and newlines in directory names.
# Ignore global fzf options that could enable multiple selection or other input.
if ! IFS= read -r -d '' directory < <(
    find / \( -path /proc -o -path /sys -o -path /dev \) -prune -o -type d -print0 2>/dev/null |
        FZF_DEFAULT_OPTS='' FZF_DEFAULT_OPTS_FILE='' FZF_DEFAULT_COMMAND='' fzf \
            --read0 --print0 --no-multi --scheme=path \
            --query="${HOME%/}/" --prompt='Directory> ' \
            --header='Enter: open Neovim | Esc/Ctrl-C: cancel | Erase the home query to search from /' \
            --layout=reverse --border=none
); then
    # Cancellation or no selection must not create a window.
    exit 0
fi

[[ -d $directory && -x $directory ]] || fail "Directory is no longer accessible: $directory"

# Multiple command arguments make tmux execute Neovim directly, without shell
# interpolation. Both Neovim and its terminal shell inherit this directory.
if ! error=$(tmux new-window -t "${target_session}:" -c "$directory" \
    "$nvim_path" -c terminal -c startinsert 2>&1); then
    fail "Could not create the Neovim window: $error"
fi
