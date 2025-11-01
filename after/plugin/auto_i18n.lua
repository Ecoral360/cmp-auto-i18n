-- local i18n = require "auto_i18n"
--
-- vim.api.nvim_create_user_command('I18nRefresh',
--   function() i18n.refresh_keys() end, {}
-- )
--
-- i18n.refresh_keys()
--
require('cmp').register_source('i18n', require("auto_i18n").new())

-- local auto_i18n = vim.api.nvim_create_augroup("auto_i18n", {})
--
-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
--   pattern = { "*.ts", "*.tsx" },
--   callback = function()
--     print "refresh"
--     require("auto_i18n"):refresh()
--   end,
--   group = auto_i18n
-- })
