autoload -Uz +X compinit && compinit -u
autoload -U +X bashcompinit && bashcompinit

# pesonal cli apps folder
export PATH=/Users/shigarus/.cargo/bin:/Users/shigarus/go/bin:/Users/shigarus/apps:$PATH

export EDITOR=nvim
# slow af
# eval $(thefuck --alias fk)

# k9s settings
export K9S_CONFIG_DIR="$HOME/.config/k9s"
export K9S_LOGS_DIR="$HOME/.config/k9s"

# set up fzf
source <(fzf --zsh)

if type rg &> /dev/null; then
    export FZF_DEFAULT_COMMAND="rg --no-follow --glob '!{/proc,/sys,$(go env GOPATH),**/.git/*,**/bazel.+/**}' --hidden --files"
fi
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}
# fzf theme generator https://vitormv.github.io/fzf-themes#eyJib3JkZXJTdHlsZSI6InJvdW5kZWQiLCJib3JkZXJMYWJlbCI6IiIsImJvcmRlckxhYmVsUG9zaXRpb24iOjAsInByZXZpZXdCb3JkZXJTdHlsZSI6InJvdW5kZWQiLCJwYWRkaW5nIjoiMCIsIm1hcmdpbiI6IjAiLCJwcm9tcHQiOiI+ICIsIm1hcmtlciI6Ij4iLCJwb2ludGVyIjoi4peGIiwic2VwYXJhdG9yIjoi4pSAIiwic2Nyb2xsYmFyIjoi4pSCIiwibGF5b3V0IjoiZGVmYXVsdCIsImluZm8iOiJkZWZhdWx0IiwiY29sb3JzIjoiZmc6I2ZkZmZmMSxmZys6I2QwZDBkMCxiZys6IzJlMmYyNyxobDojNjZkOWVmLGhsKzojZmQ5NzFmLGluZm86I2FmYWY4NyxtYXJrZXI6I2Y5MjY3Mixwcm9tcHQ6I2E2ZTIyZSxzcGlubmVyOiM2NmQ5ZWYscG9pbnRlcjojYWY1ZmZmLGhlYWRlcjojODdhZmFmLGJvcmRlcjojMTYxNjEzLHNlcGFyYXRvcjoxZDFlMTksbGFiZWw6I2FlYWVhZSxxdWVyeTojZDlkOWQ5In0=
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#fdfff1,fg+:#d0d0d0,bg:-1,bg+:#2e2f27
  --color=hl:#66d9ef,hl+:#fd971f,info:#afaf87,marker:#f92672
  --color=prompt:#a6e22e,spinner:#66d9ef,pointer:#af5fff,header:#87afaf
  --color=border:#161613,label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"'
export BAT_THEME="Monokai Extended Origin"

# rg ignore unneded
alias rg="rg --no-follow --glob '!{/proc,/sys,$(go env GOPATH),**/.git/*}' --hidden --files"

bindkey "^[b" backward-word
bindkey "^[f" forward-word
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line

if [[ "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select" || \
      "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select-wrapped" ]]; then
    zle -N zle-keymap-select "";
fi

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"

alias k=kubectl
alias vim=nvim
alias kx=kubectx
alias cd=z
alias ls="eza --color=always -1 -l --no-filesize --no-user --no-permissions --icons=always --no-time --group-directories-first"
alias lg=lazygit
alias g="git"

alias v="nvim ."
alias nf='fzf -m --preview "bat --color=always {}" --bind "enter:become(nvim {+})"'
alias fzf='fzf -m --preview "bat --color=always {}"'
alias st="git status"
alias lso="eza --color=never"
alias l="eza --icons=always --color=always --group-directories-first"
alias lsg="eza --color=always -1 -l --git --no-filesize --no-user --no-permissions --icons=always --no-time --group-directories-first"
alias lst="eza --color=always -1 -l --no-filesize --no-user --no-permissions --icons=always -T -L 2 --no-time --group-directories-first"
alias lsw="eza --color=always -1 -l --git --icons=always -T -L 2 --no-time --group-directories-first"

alias rsz="source ~/.zshrc"

source ~/work-dotfiles/zshrc

eval "$(starship init zsh)"
