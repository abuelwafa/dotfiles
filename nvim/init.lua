--[[
  ▄▄   █                    ▀▀█                    ▄▀▀
  ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
 █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
 █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
█    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
Abuelwafa's Neovim config
--]]
-- -------------------------------------------------------------
-- -------------------------------------------------------------
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- initial default configs
vim.opt.termguicolors = true
vim.opt.syntax = "on"
vim.opt.ruler = true
vim.opt.lazyredraw = true

-- indentation
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = true

-- search
vim.opt.incsearch = true
vim.opt.showmatch = true

vim.opt.colorcolumn = "99"

vim.opt.foldenable = true
vim.opt.foldmethod = "indent"
vim.opt.foldnestmax = 10
vim.opt.foldlevel = 20
vim.opt.foldminlines = 2

vim.opt.lbr = true
vim.opt.autoread = true
vim.cmd([[autocmd FocusGained,BufEnter * silent! checktime]])

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.completeopt = { "menuone", "noinsert", "noselect" }

vim.opt.history = 9999
vim.opt.undolevels = 9999

-- sets backspace key functions, allows it to backspace over end of line characters, start of line, and indentation
vim.opt.backspace = { "indent", "eol", "start" }

-- hide buffers instead of closing them, allows for changing files without saving
vim.opt.hidden = true

vim.opt.backup = true
vim.opt.swapfile = false

vim.opt.wildmenu = true
vim.opt.wildmode = "list:longest"
vim.opt.wildignore:append({
    -- Disable archive files
    "**.tar.gz",
    "*.tar.bz2",
    "*.rar",
    "*.tar.xz",

    -- Ignore bundler and sass cache
    "*/vendora/gems/*",
    "*/vendora/cache/*",
    "*/.bundlae/*",
    "*/.sass-acache/*",

    -- Ignore rails temporary asset caches
    "*/tmp/cache/assets/*/sprockets/*",
    "*/tmp/cache/assets/*/sass/*",

    -- Disable temp and backup files
    "*.swp",
    "*~",
    "._*",
})

-- don't give |ins-completion-menu| messages.
vim.opt.shortmess:append("c")

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.number = true
vim.opt.showmode = false
vim.o.updatetime = 50
vim.opt.timeoutlen = 1000
vim.opt.cursorline = true
vim.opt.scrolloff = 6
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.wrap = true
vim.opt.signcolumn = "yes"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.inccommand = "split"
vim.opt.hlsearch = true
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- winbar setup
vim.opt.winbar = "%{expand(\"%:~:.\")} %m%=%{'ddddddddd'} "

-- disable automatic comment insertion on newlines after a comment
vim.cmd("autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o")

-- available mappings
-- R
-- Z
-- g
-- ,
-- nmap <leader>,
-- <leader>,
-- <leader>i
-- <leader>c

if vim.fn.executable("pbcopy") == 0 and vim.fn.executable("xclip") then
    -- change system-copy plugin copy commands to use xclip when not on macos
    vim.g["system_copy#copy_command"] = "xclip -sel clipboard"
    vim.g["system_copy#paste_command"] = "xclip -sel clipboard -o"
end

vim.notify = require("notify")

-- -------------------------------------------------------------
-- -------------------------------------------------------------
-- plugins setup
require("lazy").setup({
    spec = {
        {
            "nvim-telescope/telescope.nvim",
            tag = "0.1.8",
            dependencies = { "nvim-lua/plenary.nvim" },
        },
        {
            "smoka7/hop.nvim",
            version = "*",
            opts = {
                keys = "etovxqpdygfblzhckisuran",
            },
        },
        {
            -- Plug 'numToStr/Comment.nvim'
            -- require("Comment").setup()
        },
        {
            "lewis6991/gitsigns.nvim",
            opt = { signs = { add = { text = "+" } }, word_diff = true },
        },
        { "stevearc/dressing.nvim", opts = {} },
        {
            "nvim-lualine/lualine.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            opts = {
                options = {
                    theme = "everforest", -- other values: powerline, powerline_dark, gruvbox_dark
                    icons_enabled = false,
                    section_separators = { left = "", right = "" },
                    component_separators = { left = "", right = "" },
                },
            },
        },
        {
            "kristijanhusak/vim-dadbod-ui",
            dependencies = {
                { "tpope/vim-dadbod", lazy = true },
                { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
            },
            cmd = {
                "DBUI",
                "DBUIToggle",
                "DBUIAddConnection",
                "DBUIFindBuffer",
            },
            init = function()
                vim.g.db_ui_save_location = "~/projects/db-connections"
                vim.g.db_ui_tmp_query_location = "~/.db-queries"
                -- vim.g.db_ui_use_nvim_notify = 1
                vim.g.db_ui_use_nerd_fonts = 1
                vim.g.db_ui_show_database_icon = 1
                vim.g.db_ui_win_position = "left"
                vim.g.db_ui_execute_on_save = 0

                vim.cmd(
                    [[autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })]]
                )
            end,
        },
    },

    -- automatically check for plugin updates
    checker = { enabled = true },
})
