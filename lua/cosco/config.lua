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
local M = {}

M.default = config
---@diagnostic disable-next-line: missing-fields
M.options = {}

function M.setup(opts)
   M.options = vim.tbl_deep_extend('keep', M.default, opts or {})
end

return M
