local M = {} -- M stands for module, a naming convention

vim.notify('lua/strunked/init.lua')

function M.setup(opts)
  vim.notify('setup')
  opts = opts or {}

  if not opts.hotkey then
    vim.notify('assign opts.hotkey:', '<Leader>h')
    opts.hotkey = "<Leader>h"
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

vim.notify(M)

return M

