---@class Cosco
local M = {}

---@param opts Options?
function M.setup(opts)
   M.config = require('cosco.config')
   M.config.setup(opts)
end

return M
