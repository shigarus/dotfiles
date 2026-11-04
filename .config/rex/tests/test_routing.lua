-- Run from the repository root: lua .config/rex/tests/test_routing.lua
local actions, calls, clients, process, context
local home_id = "client:home"
local target_id = "client:target"
local app = { kind = "app", label = "my-mac", platform = "macos", name = "Rex Beta" }

local function record(server, method, args)
  calls[#calls + 1] = { server = server, method = method, args = args }
end

local function api(server)
  local result = { session = {} }
  result.call = function(method, args)
    record(server, method, args)
    if method == "client.inspect" then
      error("Do not inspect a home client ID through the target connection")
    elseif method == "client.perform" then
      assert(server == "target" and args.client_id == target_id)
      assert(args.action == "session.select" and args.session_id == "session:target")
      assert(args.args.session_id == "session:target" and args.args.window_id == "window:new")
      return {}
    elseif method == "client.list" then
      assert(server == "target")
      return { clients = clients }
    elseif method == "block.method" then
      assert(args.session_id == "session:target" and args.block_id == "block:target")
      assert(args.method == "process")
      return process
    end
    error("Unexpected method: " .. method)
  end
  for _, method in ipairs({ "new_window", "describe_block", "new_layer" }) do
    result.session[method] = function(args)
      record(server, method, args)
      assert(args.session_id == "session:target", "Session ID must always be explicit")
      if method == "describe_block" then
        assert(args.block_id == "block:target")
        return { block = { window_id = "window:target" } }
      end
      return { block_ids = { "block:new" }, window_id = "window:new", layer_id = "layer:new" }
    end
  end
  return result
end

local home, remote = api("home"), api("target")
rex = {
  action = function(action) actions[action.name] = action.run end,
  bind = function() end,
  server = function(label) assert(label == "remote-host"); return remote end,
  layout = { block = function(value) return { block = value } end },
  client = { queue = function(action, args)
    assert(action == "session.select")
    record("app", action, args)
  end },
  call = home.call,
  session = home.session,
}

local function reset()
  actions, calls = {}, {}
  clients = { { client_id = target_id, info = app, connection_state = "connected", session_ids = { "session:target" } } }
  process = { foreground = { cwd = "/remote/project" }, home = "/remote/home" }
  context = { server = "remote-host", session_id = "session:target", block_id = "block:target", client_id = home_id }
  dofile(".config/rex/init.lua")
end

local function last(method)
  for i = #calls, 1, -1 do
    if calls[i].method == method then return calls[i] end
  end
  error("Missing call: " .. method)
end

local function fails(action, pattern)
  local ok, err = pcall(actions[action], context)
  assert(not ok and tostring(err):match(pattern), tostring(err))
  for _, call in ipairs(calls) do
    assert(call.method ~= "new_layer" and call.method ~= "new_window")
  end
end

local tests = {
  remote_tabs = function()
    for _, action in ipairs({ "nvim_terminal_here", "shell_here", "pi_here" }) do
      reset()
      actions[action](context)
      for _, call in ipairs(calls) do assert(call.server == "target") end
      local selection = last("client.perform")
      assert(selection.args.client_id == target_id)
      assert(selection.args.args.session_id == "session:target" and selection.args.args.window_id == "window:new")
      assert(last("new_window").args.focus == true)
      local options = last("new_window").args.layout.block.options
      assert(options.cwd == "/remote/project")
      if action == "shell_here" then assert(options.command == nil)
      elseif action == "pi_here" then assert(options.command[3] == "terminal pi")
      else assert(options.command[3] == "terminal") end
    end
  end,
  local_tab = function()
    context.server = nil
    actions.nvim_terminal_here(context)
    for _, call in ipairs(calls) do assert(call.server == "home" or call.server == "app") end
    assert(last("session.select").args.window_id == "window:new")
  end,
  remote_directory_fallback = function()
    process.foreground = nil
    actions.shell_here(context)
    assert(last("new_window").args.layout.block.options.cwd == "/remote/home")
  end,
  missing_directory_fails = function()
    process = {}
    fails("shell_here", "Cannot determine")
  end,
  remote_tab_picker = function()
    actions.nvim_directory_tab(context)
    local call = last("new_layer")
    assert(call.server == "target" and call.args.window_id == "window:target")
    local command = call.args.layout.block.options.command
    assert(command[3]:find('${XDG_CONFIG_HOME:-$HOME/.config}', 1, true))
    assert(command[5] == "window" and command[6] == "session:target" and command[7] == target_id)
  end,
  remote_session_picker = function()
    -- Ignore stale app connections, even if their device label matches.
    clients[#clients + 1] = { client_id = "client:old", info = app, connection_state = "lost", session_ids = { "session:target" } }
    actions.nvim_directory_session(context)
    local command = last("new_layer").args.layout.block.options.command
    assert(command[5] == "session" and command[7] == target_id)
    assert(command[7] ~= home_id)
  end,
  local_session_picker = function()
    context.server = nil
    actions.nvim_directory_session(context)
    assert(last("new_layer").args.layout.block.options.command[7] == home_id)
  end,
  ambiguous_client_fails = function()
    clients[#clients + 1] = { client_id = "client:duplicate", info = app, connection_state = "connected", session_ids = { "session:target" } }
    fails("nvim_directory_session", "Multiple Rex apps")
  end,
  absent_client_fails = function()
    clients = {}
    fails("nvim_directory_session", "No connected Rex app")
  end,
  ambiguous_direct_tab_fails_before_creation = function()
    clients[#clients + 1] = { client_id = "client:other", info = app, connection_state = "connected", session_ids = { "session:target" } }
    fails("nvim_terminal_here", "Multiple Rex apps")
  end,
  unrelated_session_is_ignored = function()
    clients[#clients + 1] = { client_id = "client:other", info = app, connection_state = "connected", session_ids = { "session:other" } }
    actions.nvim_directory_tab(context)
    assert(last("new_layer").args.layout.block.options.command[7] == target_id)
  end,
  exact_target_client_disambiguates = function()
    context.client_id = target_id
    clients[#clients + 1] = { client_id = "client:other", info = app, connection_state = "connected", session_ids = { "session:target" } }
    actions.nvim_directory_tab(context)
    assert(last("new_layer").args.layout.block.options.command[7] == target_id)
  end,
  missing_context_fails = function()
    context.block_id = nil
    fails("nvim_terminal_here", "Focus a terminal")
  end,
}

local count = 0
for name, test in pairs(tests) do
  reset()
  test()
  count = count + 1
  print("PASS " .. name)
end
print(count .. " routing tests passed")
