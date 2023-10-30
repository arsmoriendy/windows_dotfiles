-- OPTIONS [[
-- vanilla vim options (set only)
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.showmode = false
opt.termguicolors = true
opt.expandtab = true
opt.list = true
opt.cursorline = true
opt.ignorecase = true
opt.smartcase = true
opt.wrap = false
opt.timeout = false
opt.autoread = true
opt.softtabstop = 2
opt.shiftwidth = 2
opt.updatetime = 100
opt.listchars:append("trail:•")
-- ]]

-- VARIABLES [[
-- vanilla vim variables
vim.g.mapleader = "\\"
-- disable <C-C> maps on sql files
vim.g.omni_sql_no_default_maps = 1
-- ]]

-- COMMANDS [[
-- vanilla vim ex-commands

  -- command abbreviations [[
  vim.cmd.cabbrev("h help")
  vim.cmd.cabbrev("th tab help")
  -- ]]

-- ]]

-- LUA APIS [[
vim.diagnostic.config({
  update_in_insert = true
})
-- ]]

-- AUTO GROUP/CMDS -- [[

  -- [[ auto(load/make) views on normal buffer types
  local autoview_augroup = vim.api.nvim_create_augroup("autoview", {clear = true})

  -- mkview autocmd on window leave
  vim.api.nvim_create_autocmd("BufWinLeave", {
    group = autoview_augroup,
    callback = function ()
      if (vim.o.buftype == "") then
        vim.cmd("mkview")
      end
    end
  })

  -- loadview autocmd on window enter
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = autoview_augroup,
    callback = function ()
      if (vim.o.buftype == "") then
        vim.cmd("silent! loadview")
      end
    end
  })
  -- ]]

-- ]]

-- KEYMAPS [[
-- Consists of mappings that are not dependent on plugins
-- plugin dependent maps are stored in plugins.lua
local kms = vim.keymap.set

-- turn off search highlight until next search action (i.e. new search, next search, prev search)
kms({"n", "i", "x"}, "<C-f>", vim.cmd.nohlsearch)

-- tab navigation [[
kms({"n", "i", "x"}, "<C-Tab>", vim.cmd.tabnext)
kms({"n", "i", "x"}, "<C-S-Tab>", vim.cmd.tabprevious)
kms({"n", "i", "x"}, "<PageDown>", vim.cmd.tabnext)
kms({"n", "i", "x"}, "<PageUp>", vim.cmd.tabprevious)
-- ]]

-- window resize [[
kms("n", "<C-w>h", "<CMD>vertical resize -5<CR>")
kms("n", "<C-w>j", "<CMD>resize +5<CR>")
kms("n", "<C-w>k", "<CMD>resize -5<CR>")
kms("n", "<C-w>l", "<CMD>vertical resize +5<CR>")
-- ]]

-- navigate saves [[
kms({"n", "i", "x"}, "<C-M-u>", "<CMD>earlier 1f<CR>")
kms({"n", "i", "x"}, "<C-M-r>", "<CMD>later 1f<CR>")
-- ]]

kms({"n"}, "<Leader>f", "za") -- toggle fold

-- reload config
kms("n", "<F5>", "<CMD>source ~/.config/nvim/init.vim<CR>")

-- exit
kms("n", "<S-q>", "<CMD>qa!<CR>")
-- kms("n", "<C-w><C-q>", "<CMD>q!<CR>")

-- save / write file [[
kms({"n", "v", "o"}, "<C-s>", "<CMD>w<CR>")
-- separate insert mode mapping for going back to normal mode after saving
kms({"i"}, "<C-s>", "<ESC><CMD>w<CR>")
-- ]]

-- delete
kms("i", "<C-l>", "<DEL>")

-- "indent all lines
-- function IndentAll()
--   return "gg=G" . line(".") . "G"
-- endfunction
-- nnoremap <expr> == IndentAll()

-- windows [[
  -- navigate windows [[
  kms("n", "<C-h>", "<C-w>h", {remap = false})
  kms("n", "<C-j>", "<C-w>j", {remap = false})
  kms("n", "<C-k>", "<C-w>k", {remap = false})
  kms("n", "<C-l>", "<C-w>l", {remap = false})
  -- ]]
-- close window
kms({"n", "v", "o"}, "<C-q>", "<C-w>q")
-- ]]

-- diagnostics [[
kms("n", "<Enter>", "<CMD>lua vim.diagnostic.open_float()<CR>", {silent = true})
kms("n", "<Tab>", "<CMD>lua vim.diagnostic.goto_next()<CR>", {silent = true})
kms("n", "<S-Tab>", "<CMD>lua vim.diagnostic.goto_prev()<CR>", {silent = true})
-- ]]

-- lsp rename
kms("n", "<Leader>r", "<CMD>lua vim.lsp.buf.rename()<CR>")

-- lsp format
kms("n", "<Leader>i", "<CMD>lua vim.lsp.buf.format()<CR>")

-- lsp hover
kms("n", "<Leader>k", "<CMD>lua vim.lsp.buf.hover()<CR>")

-- lsp go to definition
kms("n", "<Leader>d", "<CMD>lua vim.lsp.buf.definition()<CR>");
--
-- lsp action
kms("n", "<Leader>a", "<CMD>lua vim.lsp.buf.code_action()<CR>");
-- ]]

-- FUNCTIONS [[

-- table to string
-- https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
-- @param o table to be stringified
function dump(o)
   if type(o) == 'table' then
      local s = '{ \n'
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ',\n'
      end
      return s .. '} '
   else
      return "'" .. tostring(o) .. "'"
   end
end

-- ]]

require("plugins") -- load plugins

