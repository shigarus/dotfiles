fish_add_path -g '$HOME/.cargo/bin'
fish_add_path -g $HOME/go/bin
fish_add_path -g $HOME/apps
fish_add_path -g $HOME/.krew/bin
source $__fish_config_dir/env.fish
if status is-interactive
    set -g fish_greeting
    set -g fish_key_bindings fish_vi_key_bindings

    alias vim=nvim

    abbr -a k kubectl
    abbr -a kx kubectx
    abbr -a ku kubie ctx
    abbr -a lg lazygit
    abbr -a g git
    abbr -a --command git st status
    abbr -a --command git c checkout
    abbr -a --command git ct checkout trunk
    abbr -a --command git p pull >/dev/null
    abbr -a --command git clean clean -d -x -f

    abbr -a v --set-cursor "vim ./%"

    alias ls "eza --color=always -1 -l --no-filesize --no-user --no-permissions --icons=always --no-time --group-directories-first"
    alias lso="eza --color=never"
    alias l="eza --icons=always --color=always --group-directories-first"
    alias lsg="eza --color=always -1 -l --git --no-filesize --no-user --no-permissions --icons=always --no-time --group-directories-first"
    alias lst="eza --color=always -1 -l --no-filesize --no-user --no-permissions --icons=always -T -L 2 --no-time --group-directories-first"
    alias lsw="eza --color=always -1 -l --git --icons=always -T -L 2 --no-time --group-directories-first"
    set -gx BAT_THEME "Monokai Extended Origin"

    function starship_transient_prompt_func
        starship module character
    end
    function starship_transient_rprompt_func
        starship module time
    end
    starship init fish | source
    enable_transience

    if test -e $HOME/work-dotfiles/work_config.fish
        source $HOME/work-dotfiles/work_config.fish
    end
end
