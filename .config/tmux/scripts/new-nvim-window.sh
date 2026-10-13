#!/usr/bin/env bash
# VIBECODED
# Open a directory picker popup, then a Neovim window in the originating session.
set -u

# Edit this list to exclude directories from the picker.
# Bare names match anywhere; absolute paths exclude only that specific tree.
# Patterns use fd's glob syntax. Keep HOME-based paths quoted for spaces.
excluded_directories=(
    # Repository internals and generated dependencies.
    .git
    node_modules
    .venv
    venv
    __pycache__
    .terraform

    # User caches, downloaded packages, installed tooling, and trash.
    "${HOME%/}/go/pkg"
    "${HOME%/}/.cache"
    "${HOME%/}/.npm"
    "${HOME%/}/.cargo/registry"
    "${HOME%/}/.cargo/git"
    "${HOME%/}/.rustup"
    "${HOME%/}/.local/share/nvim"
    "${HOME%/}/.local/share/Trash"
    "${HOME%/}/Library/Caches"
    "${HOME%/}/.Trash"

    # Virtual filesystems, runtime data, and mounted Snap packages.
    /proc
    /sys
    /dev
    /run
    /snap
)

fail() {
    printf 'New Neovim window: %s\n' "$*" >&2
    tmux display-message "New Neovim window: $*" 2>/dev/null || true
    exit 1
}

# run-shell expands formats; display-popup's command and -e values do not.
# Pass the expanded session, client, and pane path as shell-quoted arguments,
# then transfer the session ID and path to the popup's environment.
if [[ ${1:-} == --popup ]]; then
    [[ $# -eq 4 ]] || fail 'Expected a target session, client, and pane directory.'
    # Expand HOME in the popup's shell, not in this launcher.
    # shellcheck disable=SC2016
    exec tmux display-popup -c "$3" -E -w 80% -h 80% -T 'New Neovim window' \
        -e "NVIM_TMUX_TARGET_SESSION=$2" -e "NVIM_TMUX_START_DIRECTORY=$4" \
        'bash "$HOME/.config/tmux/scripts/new-nvim-window.sh"'
fi

target_session=${NVIM_TMUX_TARGET_SESSION:-}
[[ -n $target_session ]] || fail 'No target tmux session was provided.'
for dependency in fzf nvim; do
    command -v "$dependency" >/dev/null 2>&1 || fail "Missing dependency: $dependency"
done
nvim_path=$(command -v nvim)
if command -v fd >/dev/null 2>&1; then
    fd_path=$(command -v fd)
elif command -v fdfind >/dev/null 2>&1; then
    fd_path=$(command -v fdfind)
else
    fail 'Missing dependency: fd (or fdfind)'
fi
fd_exclusions=()
for directory in "${excluded_directories[@]}"; do
    fd_exclusions+=(--exclude "$directory")
done

home_directory=${HOME%/}
default_directory=${home_directory:-/}
# Was implemented to be faster, but now it is fast as is
# Use HOME itself, or the first directory below HOME containing the pane path.
# Match the directory boundary so a sibling such as /Users/alice-other does not
# count as being inside /Users/alice. Do not assume a Linux home path.
# start_directory=${NVIM_TMUX_START_DIRECTORY:-}
# start_directory=${start_directory%/}
# case "$start_directory" in
#     "$home_directory"/*)
#         relative_directory=${start_directory#"$home_directory"/}
#         default_directory="$home_directory/${relative_directory%%/*}"
#         ;;
# esac

# Only directories enter fzf. Keep absolute paths so the initial query can be
# erased to search anywhere under /, except for the exclusions above.
# Include hidden and gitignored directories unless explicitly excluded.
# NUL delimiters preserve spaces, quotes, and newlines in directory names.
# Ignore global fzf options that could enable multiple selection or other input.
if ! IFS= read -r -d '' directory < <(
    {
        # fd lists descendants, so add the filesystem root explicitly.
        printf '/\0'
        "$fd_path" --type d --hidden --no-ignore --absolute-path --print0 \
            --color never --threads 4 "${fd_exclusions[@]}" . / 2>/dev/null
    } |
        FZF_DEFAULT_OPTS='' FZF_DEFAULT_OPTS_FILE='' FZF_DEFAULT_COMMAND='' fzf \
            --read0 --print0 --no-multi --scheme=path \
            --query="$default_directory" --prompt='Directory> ' \
            --header='Enter: open Neovim | Esc/Ctrl-C: cancel | Erase the query to search from /' \
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
