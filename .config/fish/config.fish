fish_add_path -g '$HOME/.cargo/bin'
fish_add_path -g $HOME/go/bin
fish_add_path -g $HOME/apps
fish_add_path -g $HOME/.krew/bin
source $__fish_config_dir/env.fish
if status is-interactive
    set -g fish_greeting
    set -g fish_key_bindings fish_vi_key_bindings

    alias vim=nvim

    function _smart_commit_msg
        set branch (git branch --show-current)
        set result ""
        if functions -q work_commit_msg
            set result (work_commit_msg $branch)
        end
        echo "commit -m \"$result%\""
    end

    abbr -a k kubectl
    abbr -a kx kubectx
    abbr -a ku kubie ctx
    abbr -a lg lazygit
    abbr -a g git
    abbr -a --command git st status
    abbr -a --command git ch checkout
    abbr -a --command git ct checkout trunk
    abbr -a --command git p push
    abbr -a --command git pl "pull >/dev/null"
    abbr -a --command git clean "clean -d -x -f"
    abbr -a --command git a --set-cursor "add ./%"
    abbr -a --command git --set-cursor co -f _smart_commit_msg
    abbr -a --command git d diff
    abbr -a rsc "source ~/.config/fish/config.fish"

    abbr -a v --set-cursor "vim ./%"

    alias ls "eza --color=always -1 -l --no-filesize --no-user --no-permissions --icons=always --no-time --group-directories-first"
    alias lso="eza --color=never"
    alias l="eza --icons=always --color=always --group-directories-first"
    alias lsg="eza --color=always -1 -l --git --no-filesize --no-user --no-permissions --icons=always --no-time --group-directories-first"
    alias lst="eza --color=always -1 -l --no-filesize --no-user --no-permissions --icons=always -T -L 2 --no-time --group-directories-first"
    alias lsw="eza --color=always -1 -l --git --icons=always -T -L 2 --no-time --group-directories-first"
    set -gx BAT_THEME "Monokai Extended Origin"

    function starship_transient_prompt_func
        if test "$CMD_DURATION" -ge 3000
            set res ""
            set secs (math floor (math $CMD_DURATION / 1000))
            set hrs (math floor (math $secs / 3600))
            if not test "$hrs" = 0
                set secs (math $secs - (math $hrs \* 3600))
                set st h
                set res "$hrs$st"
            end
            set mins (math floor (math $secs / 60))
            if not test "$mins" = 0
                set secs (math $secs - (math $mins \* 60))
                set st m
                set res "$res$mins$st"
            end

            set st s
            set_color yellow
            echo "$res$secs$st"

            set CMD_DURATION 0
        end
        # somehow $status can't be read here and always equals zero
        # if not test "$status" = 0
        #     set_color red
        #     echo "a❯"
        # else
        starship module character
        # end
    end
    function starship_transient_rprompt_func
        starship module time
    end
    starship init fish | source
    enable_transience

    function notify_long_tasks --on-event fish_postexec
        if type -q osascript
            # for now works only on mac and only on local machine
            if [ "$CMD_DURATION" -gt 3000 ]
                set cmd (string split " " -- $argv)[1]
                # to make it work on mac first time - open Script editor, run a command inside quotes and
                # allow notifications from the editor
                if ! string match -r 'k9s|vim|sleep|lazygit|git|ivm-login|kubie|python' "$cmd" -q
                    osascript -e "display notification \"$argv\" with title \"$cmd\""
                end
            end
        end
    end
    fzf_configure_bindings

    if test -e $HOME/work-dotfiles/work_config.fish
        source $HOME/work-dotfiles/work_config.fish
    end
end
