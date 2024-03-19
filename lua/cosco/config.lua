---@class Options
---@field ignore_comments boolean
---@field ignored_filetypes string[]
---@field overriden_filetypes string[]
local config = {
   ignore_comments = true,
   ignored_filetypes = {},
   overriden_filetypes = {},
}

---@class CoscoConfig
---@field options Options
local M = {}

function M.setup(opts)
   M.options = vim.tbl_deep_extend('keep', config, opts or {})
end

return M
