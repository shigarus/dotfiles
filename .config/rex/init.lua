-- Install on the device's home server. Reload with: rex config reload
local shell = "com.superlogical.terminal.shell"

local function checked(result, err)
  if result == nil then error(err or "Rex call failed", 0) end
  return result
end

local function target(ctx)
  if not ctx.session_id or not ctx.block_id then
    error("Focus a terminal pane before using this shortcut", 0)
  end
  if ctx.server and ctx.server ~= "" then return rex.server(ctx.server) end
  return rex
end

local function current_directory(api, ctx)
  -- Read the target's foreground process. Never fall back to the home server.
  local process = checked(api.call("block.method", {
    session_id = ctx.session_id, block_id = ctx.block_id, method = "process",
  }))
  local cwd = (process.foreground and process.foreground.cwd)
    or (process.child and process.child.cwd) or process.home
  if not cwd or cwd == "" then error("Cannot determine the target pane's directory", 0) end
  return cwd
end

local function terminal(cwd, command)
  return rex.layout.block{
    flavor = shell,
    options = { cwd = cwd, command = command },
  }
end

local function target_client(api, ctx)
  if not ctx.client_id then error("This shortcut needs a Rex app client", 0) end
  if not ctx.server or ctx.server == "" then return ctx.client_id end

  -- Do not inspect a home-server client ID on the target. Some Rex versions
  -- also route bare rex.call through the target while a remote pane is focused.
  local clients = checked(api.call("client.list", {})).clients or {}
  local matches = {}
  for _, client in ipairs(clients) do
    if client.connection_state == "connected" and (client.info or {}).kind == "app" then
      for _, session_id in ipairs(client.session_ids or {}) do
        if session_id == ctx.session_id then
          -- If the context already supplies a target-local ID, use it exactly.
          if client.client_id == ctx.client_id then return client.client_id end
          matches[#matches + 1] = client.client_id
          break
        end
      end
    end
  end
  if #matches == 0 then error("No connected Rex app is attached to the target session", 0) end
  if #matches > 1 then
    error("Multiple Rex apps are attached to the target session; cannot identify the invoking app", 0)
  end
  return matches[1]
end

local function new_tab(ctx, command)
  local api = target(ctx)
  local client_id
  if ctx.server and ctx.server ~= "" then client_id = target_client(api, ctx) end
  local window = checked(api.session.new_window{
    session_id = ctx.session_id,
    focus = true,
    layout = terminal(current_directory(api, ctx), command),
  })
  local selection = { session_id = ctx.session_id, window_id = window.window_id }
  if client_id then
    -- Send selection through the same target connection that owns the tab.
    -- A home-server queue does not reliably retain the remote-server context.
    local _, err = api.call("client.perform", {
      client_id = client_id, action = "session.select", args = selection,
      session_id = ctx.session_id,
    })
    if err then error("Created tab " .. window.window_id .. ", but could not select it: " .. err, 0) end
  else
    rex.client.queue("session.select", selection)
  end
  return window
end

rex.action{
  name = "nvim_terminal_here",
  title = "New Neovim Terminal Here",
  run = function(ctx) return new_tab(ctx, { "nvim", "-c", "terminal", "-c", "startinsert" }) end,
}
rex.action{
  name = "shell_here",
  title = "New Shell Here",
  run = function(ctx) return new_tab(ctx) end,
}
rex.action{
  name = "pi_here",
  title = "New Pi in Neovim Here",
  run = function(ctx) return new_tab(ctx, { "nvim", "-c", "terminal pi", "-c", "startinsert" }) end,
}

local function picker(ctx, mode)
  local api = target(ctx)
  local client_id = target_client(api, ctx)
  -- Resolve HOME/XDG_CONFIG_HOME in the target terminal's shell, not here.
  local command = {
    "bash", "-c",
    'exec bash "${XDG_CONFIG_HOME:-$HOME/.config}/rex/scripts/new-nvim.sh" "$@"',
    "rex-directory-picker", mode, ctx.session_id, client_id,
  }
  -- Pin the popup to the invoking pane's window, even if the active tab changes.
  local block = checked(api.session.describe_block{
    session_id = ctx.session_id, block_id = ctx.block_id,
  })
  return checked(api.session.new_layer{
    session_id = ctx.session_id,
    window_id = block.block.window_id,
    bounds = { 0.1, 0.1, 0.8, 0.8 },
    focus = true,
    layout = terminal(current_directory(api, ctx), command),
  })
end

rex.action{
  name = "nvim_directory_tab",
  title = "Choose Directory for Neovim Tab",
  run = function(ctx) return picker(ctx, "window") end,
}
rex.action{
  name = "nvim_directory_session",
  title = "Choose Directory for Neovim Session",
  run = function(ctx) return picker(ctx, "session") end,
}

rex.bind("ctrl+space>c", "nvim_terminal_here")
rex.bind("ctrl+space>shift+c", "nvim_directory_tab")
rex.bind("ctrl+space>v", "nvim_directory_session")
rex.bind("ctrl+space>shift+v", "shell_here")
rex.bind("ctrl+space>a", "pi_here")
-- Send the prefix itself to terminal programs by pressing it twice.
rex.bind("ctrl+space>ctrl+space", "pane.send_key", { key = "ctrl+space" })
