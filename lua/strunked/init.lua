local M = {} -- M stands for module, a naming convention

function M.setup(opts)

  opts = opts or {}

  if not opts.hotkey then
    opts.hotkey = "<Leader>x"
  end

  vim.keymap.set("n", opts.hotkey, function()
    if opts.name then
      print("hello, " .. opts.name)
    else
      print("hello")
      vim.notify('hotkey pressed: ' .. 'hello')
    end
  end)

end


return M

