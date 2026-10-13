#!/usr/bin/env bash
# VIBECODE:
# Open a directory picker popup, then a Neovim window or a new Neovim session.
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

create_mode=${NVIM_TMUX_CREATE_MODE:-window}

fail() {
    printf 'New Neovim %s: %s\n' "$create_mode" "$*" >&2
    tmux display-message "New Neovim $create_mode: $*" 2>/dev/null || true
    exit 1
}

# run-shell expands formats; display-popup's command and -e values do not.
# Pass the expanded session, client, and pane path as shell-quoted arguments,
# then transfer them and the creation mode to the popup's environment.
if [[ ${1:-} == --popup || ${1:-} == --popup-session ]]; then
    [[ $# -eq 4 ]] || fail 'Expected a target session, client, and pane directory.'
    create_mode=window
    [[ $1 != --popup-session ]] || create_mode=session
    # Expand HOME in the popup's shell, not in this launcher.
    # shellcheck disable=SC2016
    exec tmux display-popup -c "$3" -E -w 80% -h 80% -T "New Neovim $create_mode" \
        -e "NVIM_TMUX_TARGET_SESSION=$2" -e "NVIM_TMUX_START_DIRECTORY=$4" \
        -e "NVIM_TMUX_TARGET_CLIENT=$3" -e "NVIM_TMUX_CREATE_MODE=$create_mode" \
        'bash "$HOME/.config/tmux/scripts/new-nvim-window.sh"'
fi

[[ $create_mode == window || $create_mode == session ]] || fail 'Invalid creation mode.'
target_session=${NVIM_TMUX_TARGET_SESSION:-}
target_client=${NVIM_TMUX_TARGET_CLIENT:-}
[[ -n $target_session ]] || fail 'No target tmux session was provided.'
if [[ $create_mode == session && -z $target_client ]]; then
    fail 'No target tmux client was provided.'
fi
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
    # Cancellation or no selection must not create a window or session.
    exit 0
fi

[[ -d $directory && -x $directory ]] || fail "Directory is no longer accessible: $directory"

# Multiple command arguments make tmux execute Neovim directly, without shell
# interpolation. Both Neovim and its terminal shell inherit this directory.
if [[ $create_mode == session ]]; then
    # fd adds trailing slashes. Remove them, but preserve the filesystem root.
    session_name=${directory%/}
    session_name=${session_name:-/}
    case "$session_name" in
        "${home_directory:-/}") session_name='~' ;;
        "$home_directory"/*) session_name=${session_name#"$home_directory"/} ;;
    esac
    # Match tmux's name normalization before checking for an existing session.
    session_name=${session_name//./_}
    session_name=${session_name//:/_}

    # Exact matching avoids switching to a different session with a shared prefix.
    if tmux has-session -t "=$session_name" 2>/dev/null; then
        if ! new_session=$(tmux display-message -p -t "=$session_name" '#{session_id}' 2>&1); then
            fail "Could not find the existing session: $new_session"
        fi
    else
        # Create it detached, then switch only the client that opened the picker;
        # never attach a nested tmux client.
        if ! new_session=$(tmux new-session -d -P -F '#{session_id}' -s "$session_name" \
            -c "$directory" "$nvim_path" -c terminal -c startinsert 2>&1); then
            fail "Could not create the Neovim session: $new_session"
        fi
    fi
    if ! error=$(tmux switch-client -c "$target_client" -t "$new_session" 2>&1); then
        fail "Could not switch to session $session_name ($new_session): $error"
    fi
else
    if ! error=$(tmux new-window -t "${target_session}:" -c "$directory" \
        "$nvim_path" -c terminal -c startinsert 2>&1); then
        fail "Could not create the Neovim window: $error"
    fi
fi
