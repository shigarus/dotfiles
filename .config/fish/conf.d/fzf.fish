# fzf.fish is only meant to be used in interactive mode. If not in interactive mode and not in CI, skip the config to speed up shell startup
if not status is-interactive && test "$CI" != true
    exit
end

fzf --fish | source

# Because of scoping rules, to capture the shell variables exactly as they are, we must read
# them before even executing _fzf_search_variables. We use psub to store the
# variables' info in temporary files and pass in the filenames as arguments.
# This variable is global so that it can be referenced by fzf_configure_bindings and in tests
set --global _fzf_search_vars_command '_fzf_search_variables (set --show | psub) (set --names | psub)'

# Install the default bindings, which are mnemonic and minimally conflict with fish's preset bindings
fzf_configure_bindings

# Doesn't erase autoloaded _fzf_* functions because they are not easily accessible once key bindings are erased
function _fzf_uninstall --on-event fzf_uninstall
    _fzf_uninstall_bindings

    set --erase _fzf_search_vars_command
    functions --erase _fzf_uninstall _fzf_migration_message _fzf_uninstall_bindings fzf_configure_bindings
    complete --erase fzf_configure_bindings

    set_color cyan
    echo "fzf.fish uninstalled."
    echo "You may need to manually remove fzf_configure_bindings from your config.fish if you were using custom key bindings."
    set_color normal
end

if not set -q fzf_preview_dir_cmd
    set -gx fzf_preview_dir_cmd eza --tree --color=always {} | head -200
end

alias fzf='fzf -m --preview "bat --color=always {}"'
alias nf='fzf -m --preview "bat --color=always {}" --bind "enter:become(nvim {+})"'
if not type -q rg
    set -gx FZF_DEFAULT_COMMAND "rg --no-follow --glob '!{/proc,/sys,$(go env GOPATH),**/.git/*,**/bazel.+/**}' --hidden --files"
    fi
    set -gx FZF_CTRL_T_OPTS "--preview '$show_file_or_dir_preview'"
    set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"
end

# fzf theme generator https://vitormv.github.io/fzf-themes#eyJib3JkZXJTdHlsZSI6InJvdW5kZWQiLCJib3JkZXJMYWJlbCI6IiIsImJvcmRlckxhYmVsUG9zaXRpb24iOjAsInByZXZpZXdCb3JkZXJTdHlsZSI6InJvdW5kZWQiLCJwYWRkaW5nIjoiMCIsIm1hcmdpbiI6IjAiLCJwcm9tcHQiOiI+ICIsIm1hcmtlciI6Ij4iLCJwb2ludGVyIjoi4peGIiwic2VwYXJhdG9yIjoi4pSAIiwic2Nyb2xsYmFyIjoi4pSCIiwibGF5b3V0IjoiZGVmYXVsdCIsImluZm8iOiJkZWZhdWx0IiwiY29sb3JzIjoiZmc6I2ZkZmZmMSxmZys6I2QwZDBkMCxiZys6IzJlMmYyNyxobDojNjZkOWVmLGhsKzojZmQ5NzFmLGluZm86I2FmYWY4NyxtYXJrZXI6I2Y5MjY3Mixwcm9tcHQ6I2E2ZTIyZSxzcGlubmVyOiM2NmQ5ZWYscG9pbnRlcjojYWY1ZmZmLGhlYWRlcjojODdhZmFmLGJvcmRlcjojMTYxNjEzLHNlcGFyYXRvcjoxZDFlMTksbGFiZWw6I2FlYWVhZSxxdWVyeTojZDlkOWQ5In0=
set -gx FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS'
  --color=fg:#fdfff1,fg+:#d0d0d0,bg:-1,bg+:#2e2f27
  --color=hl:#66d9ef,hl+:#fd971f,info:#afaf87,marker:#f92672
  --color=prompt:#a6e22e,spinner:#66d9ef,pointer:#af5fff,header:#87afaf
  --color=border:#161613,label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"'
