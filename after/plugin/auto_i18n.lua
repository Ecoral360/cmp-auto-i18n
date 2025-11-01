local i18n = require "auto_i18n"

vim.api.nvim_create_user_command('I18nRefresh',
  function() i18n.refresh_keys() end, {}
)

i18n.refresh_keys()

require('cmp').register_source('i18n', i18n.source.new())
