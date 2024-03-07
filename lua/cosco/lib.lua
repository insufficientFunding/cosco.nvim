local fn = vim.fn

---@class LineContext
---@field starting_line integer
---@field current_line string
---@field current_line_first_char string
---@field current_line_last_char string
---@field current_line_indent integer
---@field original_cursor_pos integer[]
---@field next_line string
---@field prev_line string
---@field next_line_indent integer
---@field prev_line_indent integer
---@field next_line_first_char string
---@field prev_line_last_char string
---@field next_line_last_char string

-- Globals --
local current_line_last_char_regex = vim.regex('[{[(]')
local COMMENT_REGEX = vim.regex([[\ccomment]])

---@class Lib
---Contains utility functions for cosco.nvim
local M = {}

---Returns the input string with all leading and trailing whitespace removed
---@param str string
---@return string
function M.strip(str)
   return vim.fn.substitute(str, [[^\s*\(.\{-}\)\s*$]], '\1', '')
end

---Returns the line number of the next non-blank line
---@param lineNum integer
---@return integer
function M.get_next_non_blank_line_num(lineNum)
   return M.get_future_non_blank_line_num(lineNum, 1, vim.fn.line('$'))
end

---Returns the line number of the previous non-blank line
---@param lineNum integer
---@return integer
function M.get_prev_non_blank_line_num(lineNum)
   return M.get_future_non_blank_line_num(lineNum, -1, 1)
end

---Returns the next non-blank line
---@param lineNum integer
---@return string
function M.get_next_non_blank_line(lineNum)
   return vim.fn.getline(M.get_next_non_blank_line_num(lineNum))
end

---Returns the previous non-blank line
---@param lineNum integer
---@return string
function M.get_prev_non_blank_line(lineNum)
   return vim.fn.getline(M.get_prev_non_blank_line_num(lineNum))
end

---Returns the line number of the next non-blank line, or -1 if the limit is reached
---@param lineNum integer The starting line number
---@param direction integer The direction to search in (1 or -1)
---@param limit integer The line number to stop at
---@return integer
function M.get_future_non_blank_line_num(lineNum, direction, limit)
   if lineNum == limit then return -1 end

   local futureLineNum = lineNum + (1 * direction)
   local futureLine = M.strip(vim.fn.getline(futureLineNum))

   if futureLine == '' then
      return M.get_future_non_blank_line_num(futureLineNum, direction, limit)
   end

   return futureLineNum
end

---Returns true if the following lines should be skipped
---@param context LineContext
---@return boolean
function M.should_skip_lines(context)
   local cosco = require('cosco.config')
   if cosco.options.ignore_comments then
      local isComment = COMMENT_REGEX:match_str(
         fn.synIDattr(fn.synID(fn.line('.'), fn.col('.'), 1), 'name')
      )

      if isComment then return true end
   end

   if context.next_line_first_char == '{' then return true end

   if
      M.strip(context.current_line) == ''
      or current_line_last_char_regex:match_str(context.current_line_last_char)
   then
      return true
   end

   return false
end

---Returns true if the file should be ignored, based on the file's extension
---and the user's configured whitelist and blacklist
---@return boolean
function M.should_ignore_file()
   local cosco = require('cosco.config')
   local filetype = vim.bo.filetype

   if vim.tbl_contains(cosco.options.overriden_filetypes, filetype) then
      return false
   elseif vim.tbl_contains(cosco.options.ignored_filetypes, filetype) then
      return true
   end

   return false
end

---Gets the context of the current line
---@return LineContext
function M.get_line_context()
   local context = {}

   context.starting_line = fn.line('.')
   context.current_line = fn.getline(context.starting_line)
   context.current_line_last_char = fn.matchstr(context.current_line, '.$')
   context.current_line_first_char = fn.matchstr(context.current_line, '^.')
   context.current_line_indent = fn.indent(context.starting_line)

   context.original_cursor_pos = fn.getpos('.')

   context.next_line = M.get_next_non_blank_line(context.starting_line)
   context.prev_line = M.get_prev_non_blank_line(context.starting_line)

   context.next_line_indent =
      fn.indent(M.get_next_non_blank_line_num(context.starting_line))
   context.prev_line_indent =
      fn.indent(M.get_prev_non_blank_line_num(context.starting_line))

   context.prev_line_last_char = fn.matchstr(context.prev_line, '.$')
   context.next_line_last_char = fn.matchstr(context.next_line, '.$')
   context.next_line_first_char = fn.matchstr(context.next_line, '^.')

   return context
end

return M
