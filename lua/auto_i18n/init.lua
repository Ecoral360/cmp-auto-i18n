-- Path to your locale file
local locale_paths = { "/src/locales/en.json", "/assets/locales/en/translation.json" }

---
---@param keys table<string> | nil
---@return table<string>
local function load_keys(keys)
  local f
  for _, path in ipairs(keys or locale_paths) do
    local f_, err = io.open(vim.fn.getcwd() .. path, "r")
    if err == nil then
      f = f_
    end
  end
  if not f then return {} end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  if not ok then return {} end

  -- flatten nested keys like { home: { title: "..." } } → "home.title"
  local keys = {}
  local function recurse(tbl, prefix)
    for k, v in pairs(tbl) do
      local path = prefix and (prefix .. "." .. k) or k
      if type(v) == "table" then
        recurse(v, path)
      else
        table.insert(keys, path)
      end
    end
  end
  recurse(data, nil)
  return keys
end

local i18n = { get_keys = load_keys }

---@class setupOpts
---@field paths table<string> the paths where to look for your translation files
---@field sources table<string> the cmp sources

-- ---comment
-- ---@param opts setupOpts
-- local function setup(opts)
-- local cmp = require("cmp")

local source = { i18n = i18n }

vim.api.nvim_create_user_command('I18nRefresh',
  function() source:refresh() end, {}
)

function source:refresh()
  self.i18n.cache_keys = self.i18n.get_keys()
end

function source.new()
  return setmetatable({}, { __index = source })
end

-- function source:get_keyword_pattern()
--   -- return [[(\w|\.|-)+]] -- letters, digits, _, ., -
-- end
--

function source:get_keyword_pattern()
  return [[\%(\h\w*\%[-\._\w\]*\)]]
end

-- function source:is_available()
--   local row, col = unpack(vim.api.nvim_win_get_cursor(0))
--   local line = vim.api.nvim_get_current_line()
--   local before_cursor = line:sub(1, col)
--
--   -- match t(" ... ") or t(' ... ')
--   local _, start_quote = before_cursor:find('t%s*%(%s*["\']')
--   return start_quote ~= nil
-- end

function source:is_available()
  return true
end

function source:complete(params, callback)
  vim.print("called")
  local input = string.sub(params.context.cursor_before_line, params.offset)

  -- match t(" ... ") or t(' ... ')
  local match = input:match('t%s*%(%s*["\']')
  if match == nil then
    return callback({ items = {} })
  end

  if not self.i18n.cache_keys then
    self:refresh()
  end

  local items = {}
  for _, key in ipairs(self.i18n.cache_keys) do
    table.insert(items, { label = key, kind = vim.lsp.protocol.CompletionItemKind.Value })
  end
  return callback({ items = items })
end

return source

-- cmp.register_source("i18n", source:new())
--
-- table.insert(opts.sources, { name = 'i18n' })
-- cmp.setup {
--   sources = opts.sources,
--
--   mapping = cmp.mapping.preset.insert({
--     ['<Tab>'] = nil,
--     ['<S-Tab>'] = nil,
--   }),
--
--   snippet = {
--     expand = function(args)
--       local luasnip = require('luasnip')
--       luasnip.lsp_expand(args.body) -- For `luasnip` users.
--     end
--   },
--   enabled = function()
--     -- disable completion in comments
--     local context = require 'cmp.config.context'
--     -- keep command mode completion enabled when cursor is in a comment
--     -- if vim.api.nvim_get_mode().mode == 'c' then
--     --   return true
--     -- else
--     --   return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
--     -- end
--     return true
--   end
-- }
--   return source:new()
-- end

-- return { setup = setup, get_keys = load_keys }
