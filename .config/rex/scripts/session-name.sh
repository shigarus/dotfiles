#!/usr/bin/env bash
# Source this file to derive a session label in REPLY without filesystem access.
rex_session_name() {
    local directory=${1%/} home_directory=${2%/}
    directory=${directory:-/}
    home_directory=${home_directory:-/}
    local comparable_directory=$directory comparable_home=$home_directory name

    # macOS exposes its writable volume through both paths. Normalize only
    # for HOME comparison; preserve the selected path outside HOME.
    case "$comparable_directory" in
        /System/Volumes/Data/*) comparable_directory=${comparable_directory#/System/Volumes/Data} ;;
    esac
    case "$comparable_home" in
        /System/Volumes/Data/*) comparable_home=${comparable_home#/System/Volumes/Data} ;;
    esac
    case "$comparable_directory" in
        "$comparable_home") name='~' ;;
        "$comparable_home"/*) name=${comparable_directory#"$comparable_home"/} ;;
        *)
            name=$directory
            if [[ $comparable_home == / ]]; then name=${comparable_directory#/}; fi
            ;;
    esac
    # Keep the existing tmux-compatible punctuation normalization.
    name=${name//./_}
    name=${name//:/_}
    REPLY=$name
}
