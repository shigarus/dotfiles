#!/usr/bin/env bash
# launchd runs this on the Mac, never on the IVM.
set -euo pipefail
unset REX_SERVER REX_SESSION REX_BLOCK REX_CLIENT
: "${1:?Usage: ensure-ivm-session.sh TUNNEL_SCRIPT}"
command -v rex >/dev/null
command -v jq >/dev/null

# Keep the tunnel local even when a remote Rex session is selected in the app.
# Do not create anything if listing sessions fails.
sessions=$(rex ls --json)
count=$(printf '%s' "$sessions" | jq -er '[.sessions[] | select(.label == "IVM tunnel")] | length')
if [[ $count -gt 1 ]]; then
    printf 'Multiple IVM tunnel sessions exist; refusing to guess.\n' >&2
    exit 1
fi
if [[ $count -eq 0 ]]; then
    rex new 'IVM tunnel' --window SSH --shell=none -- bash "$1"
fi
