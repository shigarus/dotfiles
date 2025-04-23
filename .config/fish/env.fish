set -qU XDG_CONFIG_HOME; or set -Ux XDG_CONFIG_HOME $HOME/.config
set -qU XDG_DATA_HOME; or set -Ux XDG_DATA_HOME $HOME/.local/share
set -qU XDG_CACHE_HOME; or set -Ux XDG_CACHE_HOME $HOME/.cache
set -gx EDITOR nvim
set -gx K9S_CONFIG_DIR "$HOME/.config/k9s"
set -gx K9S_LOGS_DIR "$HOME/.config/k9s"
