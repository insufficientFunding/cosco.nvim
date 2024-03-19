local config = require('cosco.config')
local lib = require('cosco.lib')

local M = {}

function M.print_context()
   local context = lib.get_line_context()

   vim.notify(vim.inspect(context), vim.log.levels.INFO, { timeout = 5000 })
end

return M
