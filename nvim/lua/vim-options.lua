-- Tambahkan di vim-options.lua
vim.g.neovide_opacity = 0.9 -- Mengatur transparansi Neovide
vim.g.neovide_scale_factor = 1.0 -- Mengatur skala font
vim.g.neovide_cursor_vfx_mode = "sonicboom" -- Menambahkan efek visual pada kursor
vim.opt.guifont = "JetBrainsMono Nerd Font:h12"

-- ORIGINAL
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.g.have_nerd_font = true

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.autoindent = true
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.scrolloff = 10
vim.opt.confirm = true
