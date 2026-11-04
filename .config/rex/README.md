# Rex shortcuts

Press **Ctrl-Space**, release it, then press the second key:

| Key | Behavior |
| --- | --- |
| `c` | New tab: Neovim terminal in the current pane's directory. |
| `C` (Shift-C) | Floating fzf directory picker, then a Neovim terminal tab. |
| `v` | Floating fzf directory picker, then create or select a Neovim session. |
| `V` (Shift-V) | New plain shell tab in the current pane's directory. |
| `a` | New tab: pi inside a Neovim terminal in the current pane's directory. |
| Ctrl-Space | Send Ctrl-Space to the current terminal. |

The pickers use native Rex floating layers at 80% width and height. Escape or
Ctrl-C cancels without creating a tab or session. Errors remain visible in the
floating terminal until you press Enter. Older fzf versions run without the
optional `--scheme=path` scoring option.

The directory list, exclusions, and initial HOME query match
`.config/tmux/scripts/new-nvim-window.sh`. Clear the query to search from `/`.
Session labels are relative to the target's HOME on Linux and macOS. The macOS
paths `/Users/alice/project` and `/System/Volumes/Data/Users/alice/project`
both become `project` when HOME is `/Users/alice`. Selecting HOME itself gives
`~`. Paths outside HOME stay absolute. The actual directory path is unchanged.
Session selection uses an exact label match. Ambiguous duplicate labels fail
without switching. Keep directory exclusions in both scripts synchronized.

## Setup

Shortcut definitions come from the device's **home server**, not necessarily
from the server hosting the focused terminal. On the Mac, run `rex home --json`
in a local terminal to identify that home server.

- Install `init.lua` as `~/.config/rex/init.lua` on the home server (normally the
  Mac). If a configuration already exists, merge the contents; do not overwrite
  unrelated bindings.
- Install both `scripts/new-nvim.sh` and `scripts/session-name.sh` in
  `~/.config/rex/scripts/` on **each target machine** where directory pickers
  will run. This Linux checkout is already linked at `~/.config/rex`.
- Use `$XDG_CONFIG_HOME/rex` instead when that environment variable is set. The
  picker resolves this path inside the target terminal's shell. A custom
  `REX_CONFIG` can locate `init.lua` elsewhere, but does not move the picker.

The actions route through `ctx.server` and explicitly pass the focused session
and block IDs. Tabs, floating terminals, directory searches, Neovim, and pi run
on the target. Only the shortcut definitions need to live on the home server.

Required on each target: `rex`, `nvim`, `fzf`, `fd` (or `fdfind`), `jq`, and `bash`.
The `a` shortcut also requires `pi` on the Neovim terminal shell's PATH.
The Rex app must support floating layers, key sequences, and cross-server Lua
calls. Remote tab selection and picker-based selection require Remote Control
in the app. Direct local tabs queue `session.select`. Direct remote tabs call
`client.perform` through the target server with the exact returned window ID.
Server-side focus alone is insufficient.

Client IDs are server-local. Remote actions use the context's client ID if it
matches a connected target app attached to the focused session. Otherwise,
exactly one app must be connected and attached to that session. A missing or
ambiguous connection fails before creating a tab or picker. This deliberately
refuses to guess when several apps share the target session and the context
only provides a home-server ID. It never inspects a home-server ID on the target.
The picker script receives the resolved target-server client ID. It does not
hold a home-server action open while fzf runs.

On the **home-server machine**, validate and reload:

```sh
rex config check
rex config reload
rex keymap
```

Reloading only the Linux target does not install shortcuts on a Mac whose home
server is local. If Ctrl-Space is reserved for input-source switching in macOS,
disable or change that system shortcut before testing.

## Persistent IVM tunnel on the Mac

`nix/hosts/mac-serios/home.nix` makes the existing `shigarus-ivm` launch agent
ensure a local Rex session named **IVM tunnel** at login and every 30 seconds.
It replaces the old background SSH process; do not run both tunnel owners.
The agent needs `rex` and `jq` on the local login shell's PATH. Nix bundles
`ensure-ivm-session.sh` and `ivm-tunnel.sh` into the store during the rebuild.
Track these new scripts in Git before rebuilding the Git-backed flake.

The session runs your existing `ivm` zsh alias, preserving its port forwards,
and adds `44333:localhost:44333` for Rex. Do not also add port 44333 to the
alias. SSH keepalives detect an unresponsive connection after approximately
45 seconds. A failed initial forward ends the attempt. The visible terminal
prints errors and retries after 30 seconds, including after a normal logout.
It supports interactive authentication. It does not select the session or
change the app's current view.

Apply the Mac Nix configuration to replace the launch agent. Open **IVM tunnel**
in Rex to inspect SSH output or complete authentication. Closing this session
causes the agent to recreate it within approximately 30 seconds. To stop it
permanently, disable the launch agent before closing the session.

Add the forwarded IVM Rex server once from a **local Mac terminal**:

```sh
rex hosts add ivm http://localhost:44333
rex -S ivm ls
```

If `ivm` is already registered, check its endpoint instead of adding it again.
The IVM must already serve Rex on its loopback port 44333. Select that remote
host's sessions in the Mac app for persistent IVM tabs and panes. The local
**IVM tunnel** session only carries SSH; it does not move remote terminals.

## Tests

From the dotfiles repository:

```sh
rex config check .config/rex/init.lua
lua .config/rex/tests/test_routing.lua
shellcheck -x .config/rex/scripts/*.sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s .config/rex/tests -v
```

The Lua tests mock both servers and verify routing, explicit IDs, target-side
paths, local behavior, and missing or ambiguous app connections. The script
tests mock fzf and Rex. They cover cancellation, directory quoting, creation
failures, missing directories, and new, existing, or ambiguous sessions.
