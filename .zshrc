
autoload -Uz +X compinit && compinit -u
autoload -U +X bashcompinit && bashcompinit

# export DOCKER_HOST="${HOME}.colima/docker.sock"
export NEBO=$HOME/nebo

# CGO_ENABLED=0
# GO111MODULE=on
# export GOROOT=/Users/aleksandrstovbyra/.ya/tools/v4/4773521027
# GOARCH=arm64
# export PATH=$GOROOT/bin:$PATH
export PATH=/Users/shigarus/.cargo/bin:/Users/shigarus/go/bin:/Users/shigarus/apps:$PATH
# export PSSH_AUTH_SOCK="/private/var/tmp/pssh-agent.sock"
alias dalaran="nssh --no-yubikey --ycp-profile sandbox-nemax shigarus-vm.dalaran-vm.nemax-sandbox.nebiuscloud.net"
alias ya=/Users/shigarus/nebo/ya
alias k=kubectl
alias ku='kubectl --kubeconfig ~/temp/user-kube.conf --insecure-skip-tls-verify'
alias nsshi="nssh --no-yubikey --ycp-profile israel"
alias nsshn="nssh --no-yubikey --ycp-profile nemax"
alias nsshnu="nsshn --user $USER"
alias br="bazel run --ui_event_filters=-info,-debug,-warning,-stderr,-stdout --noshow_progress --logging=0"
alias brc="bazel run --ui_event_filters=-info,-debug,-warning,-stderr,-stdout --noshow_progress --logging=0 //api/tools/cli --"
alias clear-dns="sudo killall -HUP mDNSResponder"

alias vim=nvim
alias cz="vim ~/.zshrc"
alias rsz="source ~/.zshrc"
alias l="eza --icons=always --color=always --group-directories-first"
alias ls="eza --color=always -1 -l --git --no-filesize --no-user --no-permissions --icons=always --no-time --group-directories-first"
alias lst="eza --color=always -1 -l --git --no-filesize --no-user --no-permissions --icons=always -T -L 2 --no-time --group-directories-first"
alias lso=ls
# slow af
# eval $(thefuck --alias fk)

# k9s settings
export K9S_CONFIG_DIR="$HOME/.config/k9s"
export K9S_LOGS_DIR="$HOME/.config/k9s"
alias k9l="k9s --context kind-capi-mgmt-local"
alias k9t="k9s --context ik8s-testing-management"
alias k9tc="k9s --context root-bastion-ik8s-beta"
alias k9mp="k9s --context ik8s-man-prod-management"
alias k9mpc="k9s --context root-bastion-common-prod"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

alias npcl="NPC_OVERRIDE_RESOLVERS='nebius.mk8s.*=localhost:30080' npc --profile default --skip-tls-verification"
alias npcts="npc --profile testing -I serviceaccount-e0tmk8s-dev"
alias npct="npc --profile testing"
alias npcmp="npc --profile man-prod"
alias npcmps="npc --profile man-prod -I serviceaccount-e00mk8s-manager-sa"

# set up fzf
source <(fzf --zsh)

if type rg &> /dev/null; then
    export FZF_DEFAULT_COMMAND="rg --no-follow --glob '!{/proc,/sys,$(go env GOPATH),**/.git/*,**/bazel.+/**}' --hidden --files"
fi
alias nf='fzf -m --preview "bat --color=always {}" --bind "enter:become(nvim {+})"'
alias fzf='fzf -m --preview "bat --color=always {}"'
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

alias lg=lazygit

function npc {
  pushd $NEBO &> /dev/null
  local npcbin="$HOME/apps/npc"
  local lastBuildCommitPath="$HOME/.npc-last-build-commit"
  local lastBuildCommit=$(cat $lastBuildCommitPath)
  local currentCommit=$(arc rev-parse HEAD)
  if [[ "$lastBuildCommit" != "$currentCommit" ]]; then
    bazel build --stamp //api/tools/cli
    echo $currentCommit > $lastBuildCommitPath
    ln -fs "$(dirname $(bazel info output_path))/$(bazel cquery //api/tools/cli --output=files)" "$npcbin"
  fi
  popd &> /dev/null
  $npcbin $@
}
function ito {
  token=$(npc iam get-access-token | grep "v1.")
  echo $token
  export token
}
function tsh-login {
  tsh kube login -n mk8s mk8s-mgmt-testing
  tsh kube login -n mk8s mk8s-mgmt-prod
  tsh kube login -n mk8s ik8s-beta
  tsh kube login -n mk8s common-prod
}

bindkey "[D" backward-word
bindkey "[C" forward-word

# The next line updates PATH for Nebius CLI.
if [ -f '/Users/shigarus/.nebius/path.bash.inc' ]; then source '/Users/shigarus/.nebius/path.bash.inc'; fi
# The next line enables shell command completion for Nebius CLI.
if [ -f '/Users/shigarus/.nebius/completion.zsh.inc' ]; then source '/Users/shigarus/.nebius/completion.zsh.inc'; fi
eval "$(starship init zsh)"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
alias cd=z
