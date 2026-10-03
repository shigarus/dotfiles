Nvimide = {
  debug_restart = false,
  debug = true,
  log_fh = nil,
  log = function(...)
    if Nvimide.debug then
      local objects = {}
      for i = 1, select('#', ...) do
        local v = select(i, ...)
        table.insert(objects, vim.inspect(v))
      end
      Nvimide.log_fh:write(table.concat(objects, '\n') .. '\n')
      Nvimide.log_fh:flush()
    end
  end,
  script_path = function()
    return debug.getinfo(2, 'S').source:sub(2)
  end,
}
if Nvimide.debug then
  Nvimide.log_fh = io.open('/tmp/nvim.' .. os.getenv 'USER' .. '.log', Nvimide.debug_restart and 'w' or 'a')
  print(Nvimide.log_fh)
end

return Nvimide.log
