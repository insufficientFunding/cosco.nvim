local lib = require('cosco.lib')

--------------------------------------------------------------------------------
--- Constants ------------------------------------------------------------------
--------------------------------------------------------------------------------
local LINE_ENDINGS_REGEX = vim.regex('[;,]')

--------------------------------------------------------------------------------
-- Public API ------------------------------------------------------------------
--------------------------------------------------------------------------------
---@class LineEndings
local M = {}

---Removes the line endings from the current line (, or ;)
---@param context LineContext
function M.remove_line_endings(context)
   if LINE_ENDINGS_REGEX:match_str(context.current_line_last) then
      vim.cmd('s/[,;]\\?$//e')
   end
end

---Converts the current line ending to a semicolon
---@param context LineContext
function M.convert_to_semicolon(context)
   if context.current_line_last == ':' then return end
   vim.cmnd('s/[,;]\\?$/;/e')
end

---Converts the current line ending to a comma
---@param context LineContext
function M.convert_to_comma(context)
   if context.current_line_last == ',' then return end
   vim.cmd('s/[,;]\\?$/,/e')
end

---Adds a line ending to the current line
function M.add_line_ending()
   if vim.bo.readonly then return end
   if lib.should_ignore_file() then return end

   local context = lib.get_line_context()

   if lib.should_skip_lines(context) then return end

   if context.prev_line_last == ',' then
      if context.next_line_last == ',' then
         M.convert_to_comma(context)
      elseif context.next_line_indent < context.current_line_indent then
         M.convert_to_semicolon(context)
      elseif context.next_line_indent == context.current_line_indent then
         M.convert_to_comma(context)
      end
   elseif context.prev_line_last == ';' then
      M.convert_to_semicolon(context)
   elseif context.prev_line_last == '{' then
   end
end

return M
