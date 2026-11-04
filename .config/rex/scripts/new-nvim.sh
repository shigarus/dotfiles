#!/usr/bin/env bash
# Run inside a Rex floating terminal; cancellation creates nothing.
set -euo pipefail

mode=${1:?Expected window or session}
target_session=${2:?Expected a Rex session ID}
# Both modes need the invoking app's target-server ID to select the result.
target_client=${3:-}
selection_file=''

finish() {
    local status=$?
    [[ -z $selection_file ]] || rm -f -- "$selection_file"
    if [[ $status -ne 0 && -t 0 ]]; then
        printf '\nPicker failed (exit %s). Press Enter to close.\n' "$status" >&2
        IFS= read -r _ || true
    fi
    exit "$status"
}
trap finish EXIT

fail() {
    printf 'New Neovim %s: %s\n' "$mode" "$*" >&2
    exit 1
}
[[ $mode == window || $mode == session ]] || fail 'Invalid creation mode.'
[[ -n $target_client ]] || fail 'Expected a target-server Rex client ID.'
# Rex supplies its CLI directory to terminals. Login-shell startup files can
# replace PATH, particularly when the macOS app supplies the bundled CLI.
if [[ -n ${REX_BIN_DIR:-} && -x $REX_BIN_DIR/rex ]]; then
    export PATH="$REX_BIN_DIR:$PATH"
fi
for dependency in rex jq fzf nvim; do
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

# Match the tmux picker's exclusions. Bare names match anywhere.
excluded_directories=(
    .git node_modules .venv venv __pycache__ .terraform
    "${HOME%/}/go/pkg" "${HOME%/}/.cache" "${HOME%/}/.npm"
    "${HOME%/}/.cargo/registry" "${HOME%/}/.cargo/git" "${HOME%/}/.rustup"
    "${HOME%/}/.local/share/nvim" "${HOME%/}/.local/share/Trash"
    "${HOME%/}/Library/Caches" "${HOME%/}/.Trash"
    /proc /sys /dev /run /snap
)
fd_exclusions=()
for directory in "${excluded_directories[@]}"; do
    fd_exclusions+=(--exclude "$directory")
done
home_directory=${HOME%/}
# Older fzf releases lack path scoring. It improves ranking but is optional.
fzf_options=(--read0 --print0 --no-multi)
fzf_help=$(fzf --help 2>&1) || fzf_help=''
if [[ $fzf_help == *--scheme* ]]; then
    fzf_options+=(--scheme=path)
fi
selection_file=$(mktemp "${TMPDIR:-/tmp}/rex-nvim-picker.XXXXXXXX")
# Capture fzf's status directly. Reading a process substitution hides failures
# such as an unsupported option or a terminal initialization error.
if {
    printf '/\0'
    "$fd_path" --type d --hidden --no-ignore --absolute-path --print0 \
        --color never --threads 4 "${fd_exclusions[@]}" . / 2>/dev/null
} | FZF_DEFAULT_OPTS='' FZF_DEFAULT_OPTS_FILE='' FZF_DEFAULT_COMMAND='' fzf \
    "${fzf_options[@]}" \
    --query="${home_directory:-/}" --prompt='Directory> ' \
    --header='Enter: open Neovim | Esc/Ctrl-C: cancel | Erase the query to search from /' \
    --layout=reverse --border=none > "$selection_file"; then
    fzf_status=${PIPESTATUS[1]}
else
    # Ignore fd's SIGPIPE when fzf returns early after a selection.
    fzf_status=${PIPESTATUS[1]}
fi
case "$fzf_status" in
    0) IFS= read -r -d '' directory < "$selection_file" || fail 'fzf returned no directory.' ;;
    1|130) exit 0 ;; # No match or explicit cancellation.
    *) fail "fzf failed with exit status $fzf_status (TERM=${TERM:-unset})." ;;
esac
[[ -d $directory && -x $directory ]] || fail "Directory is no longer accessible: $directory"

if [[ $mode == window ]]; then
    created=$(rex window new -s "$target_session" -c "$directory" --json -- \
        "$nvim_path" -c terminal -c startinsert)
    new_window=$(jq -er '.window_id' <<< "$created")
    rex -C "$target_client" 'do' session.select \
        session_id="$target_session" window_id="$new_window"
else
    # shellcheck source=.config/rex/scripts/session-name.sh
    source "$(dirname -- "${BASH_SOURCE[0]}")/session-name.sh"
    rex_session_name "$directory" "$home_directory"
    session_name=$REPLY
    sessions=$(rex ls --json)
    matches=$(jq --arg name "$session_name" '[.sessions[] | select(.label == $name)]' <<< "$sessions")
    count=$(jq 'length' <<< "$matches")
    [[ $count -le 1 ]] || fail "More than one session has the label: $session_name"
    if [[ $count -eq 1 ]]; then
        new_session=$(jq -er '.[0].session_id' <<< "$matches")
    else
        created=$(rex new "$session_name" -c "$directory" --json -- \
            "$nvim_path" -c terminal -c startinsert)
        new_session=$(jq -er '.session_id' <<< "$created")
    fi
    # Switch only the app that opened this picker. Never attach a nested client.
    rex -C "$target_client" 'do' session.select session_id="$new_session"
fi
