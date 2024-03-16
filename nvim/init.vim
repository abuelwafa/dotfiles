" Abuelwafa's Neovim init.vim config

set nocompatible

" download vim-plug if its not present
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC | q!
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC | q | q!
\| endif

call plug#begin()
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'ANGkeith/telescope-terraform-doc.nvim'
Plug 'lpoto/telescope-docker.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'nvim-telescope/telescope-ui-select.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'phaazon/hop.nvim'
Plug 'lbrayner/vim-rzip'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'christoomey/vim-tmux-navigator'
Plug 'rest-nvim/rest.nvim'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'moll/vim-bbye'
Plug 'ntpeters/vim-better-whitespace'
Plug 'prisma/vim-prisma'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
Plug 'christoomey/vim-system-copy'
Plug 'numToStr/Comment.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'tinted-theming/base16-vim'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'mattn/emmet-vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-lualine/lualine.nvim'
Plug 'nacro90/numb.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'szw/vim-maximizer'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-neo-tree/neo-tree.nvim'
Plug 'akinsho/bufferline.nvim', { 'tag': 'v3.*' }
Plug 'jparise/vim-graphql'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'f-person/git-blame.nvim'
Plug 'eandrju/cellular-automaton.nvim'
Plug 'rcarriga/nvim-notify'
Plug 'preservim/tagbar'
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'kristijanhusak/vim-dadbod-completion'
Plug 'jackMort/ChatGPT.nvim'
Plug 'stevearc/dressing.nvim'
Plug 'folke/trouble.nvim'
Plug 'j-hui/fidget.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'windwp/nvim-ts-autotag'

Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'WhoIsSethDaniel/mason-tool-installer.nvim'
Plug 'folke/todo-comments.nvim'
Plug 'stevearc/conform.nvim'

Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-cmdline'
Plug 'petertriho/cmp-git'
Plug 'SergioRibera/cmp-dotenv'
Plug 'onsails/lspkind.nvim'

Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*', 'do': 'make install_jsregexp'}
Plug 'saadparwaiz1/cmp_luasnip'
" Plug 'rafamadriz/friendly-snippets'
" Plug 'rmagatti/goto-preview'

" Plug 'mfussenegger/nvim-dap'
" Plug 'rcarriga/nvim-dap-ui'
" Plug 'nvim-telescope/telescope-dap.nvim'

" Plug 'mfussenegger/nvim-lint'

" Plug 'pwntester/octo.nvim'

" Plug 'zbirenbaum/copilot.lua'
" Plug 'zbirenbaum/copilot-cmp'

"-- to be explored
" Plug 'numToStr/FTerm.nvim'

function! UpdateRemotePlugins(...)
    " Needed to refresh runtime files
    let &rtp=&rtp
    UpdateRemotePlugins
endfunction

" Plug 'gelguy/wilder.nvim', { 'do': function('UpdateRemotePlugins') }

call plug#end()

"===================================================
" basic vim configuration

set t_Co=256
set termguicolors
syntax on
set ruler
set lazyredraw
set nofsync

" Indentation
set autoindent
set smartindent
set cindent

" Search
set incsearch
" set gdefault
set showmatch

set colorcolumn=101

" disable code folding
set foldenable
set foldmethod=indent
set foldnestmax=10
set foldlevel=20
set foldminlines=2

set lbr

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

set nopaste


set completeopt="menuone,noinsert,noselect"

" sets backspace key functions, allows it to backspace over end of line
" characters, start of line, and indentation
set backspace=indent,eol,start

" movement keys will take you to the next or previous line
set whichwrap+=<,>,h,l

" remember more commands and search history
set history=9999
" use many much of levels of undo  "
set undolevels=9999

" hide buffers instead of closing them, allows for changing files without saving
set hidden

" disable backup and swap files
set backup
set noswapfile
set nowritebackup
set backupdir^=~/.nvim/_backup/
set directory=~/.nvim/_temp/
set undodir=~/.nvim/_undo/

" File name tab completion functions like bash, it gives you a list of
" options instead of automatically filling in the first possible match.
set wildmenu
" It will however, with this option, complete up to the first character of ambiguity.
set wildmode=list:longest

" Disable archive files
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz
" Ignore bundler and sass cache
set wildignore+=*/vendor/gems/*,*/vendor/cache/*,*/.bundle/*,*/.sass-cache/*
" Ignore rails temporary asset caches
set wildignore+=*/tmp/cache/assets/*/sprockets/*,*/tmp/cache/assets/*/sass/*
" Disable temp and backup files
set wildignore+=*.swp,*~,._*

" don't give |ins-completion-menu| messages.
set shortmess+=c

" Better display for messages
" set cmdheight=2

" makes cursor on the beginning of tab characters. makes it behaves like other editors
" view tabs with pipe character and three spaces to proper view indent guides
set listchars+=extends:>
set listchars+=trail:\ ,tab:\|\ ,nbsp:␣
match errorMsg /\s\+$/

" set mouse shape to block in insert mode
set guicursor=i:block

" editor config configuration
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
au FileType gitcommit let b:EditorConfig_disable = 1

" " remove vim background - makes it transparent if the colorscheme has no background
" highlight nonText ctermbg=NONE


" " git blame configuration
" Plug 'f-person/git-blame.nvim'
" let g:gitblame_date_format = '%d %b %y'
" let g:gitblame_message_when_not_committed = ''


" disable automatic comment insertion on newlines after a comment
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" available mappings
" R
" Z
" g
" ,
" nmap <leader>,
" <leader>,
" <leader>i
" <leader>c
inoremap <silent><script><expr> <leader><space> copilot#Accept()
let g:copilot_no_tab_map = v:true

set background=dark
if filereadable(expand("~/.vimrc_background"))
    let base16colorspace=256
    source ~/.vimrc_background
endif

if !executable('pbcopy') && executable('xclip')
    " change system-copy plugin copy commands to use xclip when not on macos
    let g:system_copy#copy_command='xclip -sel clipboard'
    let g:system_copy#paste_command='xclip -sel clipboard -o'
endif

" ===================================================================================
" lua configuration
lua << EOF
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.number = true
vim.opt.showmode = false
vim.o.updatetime = 50
vim.opt.timeoutlen = 1000
vim.opt.cursorline = true
vim.opt.scrolloff = 6
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.signcolumn = 'yes'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.inccommand = 'split'
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<Esc><Esc>', '<C-w>w', { desc = 'Exit Documentation' })

-- plugins
require('hop').setup()
require('Comment').setup()
require('gitsigns').setup()
require('numb').setup()
require("chatgpt").setup()
require('colorizer').setup({ '*' }, {
    RGB = true;
    RRGGBB = true;
    RRGGBBAA = true;
    names = true;
    rgb_fn = true;
    hsl_fn = true;
    css = true;
    css_fn = true;
})
require'nvim-treesitter.configs'.setup({ autotag = { enable = true } })
require('dressing').setup()
require('trouble').setup()
require('fidget').setup()
require("nvim-autopairs").setup()
require("todo-comments").setup()
require("conform").setup({
    notify_on_error = true,
    format_on_save = { timeout_ms = 500, lsp_fallback = true },
    formatters_by_ft = {
        lua = { "stylua" },
        go = { "goimports", "golines", { "gofumpt", "gofmt" } },
        rust = { "rustfmt" },
        python = { "isort", "ruff_format" },
        javascript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        sh = { "shfmt" },
        css = { "stylelint" },
        sql = { "sqlfluff" },
        tf = { "terraform_fmt" },
        yaml = { "yamlfmt" },
        html = { "djlint" },
        java = { "google-java-format" },
        ["_"] = { "trim_whitespace" },
    },
})

require('nvim-treesitter.configs').setup({
    ensure_installed = {
        "astro",
        "bash",
        "c",
        "c_sharp",
        "cmake",
        "comment",
        "cpp",
        "css",
        "diff",
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "graphql",
        "groovy",
        "html",
        "htmldjango",
        "http",
        "java",
        "javascript",
        "jq",
        "jsdoc",
        "json",
        "json5",
        "jsonc",
        "kotlin",
        "lua",
        "luadoc",
        "make",
        "markdown",
        "markdown_inline",
        "php",
        "phpdoc",
        "po",
        "prisma",
        "python",
        "query",
        "regex",
        "rust",
        "scss",
        "sql",
        "terraform",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "vue",
        "yaml"
    },
    auto_install = true,
    sync_install = false,
    ignore_install = {},
    highlight = {
        enable = true,
        disable = {},
        additional_vim_regex_highlighting = false
    },
    indent = { enable = true }
})

function fxJSONFormat(content)
    return vim.fn.system({ "fx", "." }, content)
end

require("rest-nvim").setup({
    result_split_horizontal = false,
    result_split_in_place = true,
    skip_ssl_verification = true,
    encode_url = true,
    highlight = { enabled = true, timeout = 1000 },
    result = {
        show_url = true,
        show_http_info = true,
        show_headers = true,
        formatters = {
            json = fxJSONFormat,
            vnd = fxJSONFormat,
            html = function(body)
                return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
            end,
        }
    },
    jump_to_request = false,
    env_file = '.env',
    custom_dynamic_variables = {},
    yank_dry_run = true,
})

vim.diagnostic.config({ virtual_text = false })
vim.cmd [[autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focus = false, border = 'single' })]]

------------------------------------------------
-- lsp config

local ensure_installed = {
    'actionlint', 'ansiblels', 'astro', 'bash-debug-adapter', 'bashls', 'chrome-debug-adapter',
    'clangd', 'cmake', 'cssls', 'cssmodules_ls', 'debugpy', 'delve', 'djlint',
    'docker_compose_language_service', 'dockerls', 'eslint', 'eslint_d', 'flake8', 'gofumpt',
    'goimports', 'golangci-lint', 'golangci_lint_ls', 'golines', 'gomodifytags',
    'google-java-format', 'gopls', 'gotests', 'gradle_ls', 'graphql', 'groovyls', 'harper-ls',
    'helm_ls', 'html', 'intelephense', 'isort', 'java-debug-adapter', 'java-test', 'jdtls',
    'js-debug-adapter', 'jsonlint', 'jsonls', 'kotlin-debug-adapter', 'kotlin_language_server',
    'lua_ls', 'marksman', 'mdx_analyzer', 'omnisharp', 'prettierd', 'prismals', 'pylint', 'pyright',
    'ruff', 'ruff-lsp', 'rust-analyzer', 'shfmt', 'sqlfluff', 'stylelint', 'stylua',
    'tailwindcss', 'taplo', 'templ', 'terraformls', 'tflint', 'tsserver', 'vale', 'vale-ls',
    'vimls', 'vint', 'volar', 'yamlfmt' , 'yamllint', 'yamlls', 'zls',
}

require("mason").setup()
require('mason-tool-installer').setup({
    auto_update = true,
    run_on_start = true,
    ensure_installed = ensure_installed
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, { border = "single" }
)

function show_documentation()
    vim.lsp.buf.hover()
    vim.lsp.buf.hover()
end
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach-group', { clear = true }),
    callback = function(event)
        local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end
        --  To jump back, press <C-T>.
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        -- Jump to the type definition
        map('gD', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        -- Goto Declaration. For example, in C this would take you to the header
        map('<leader>D', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        -- Find references for the word under your cursor.
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]references')
        -- Rename the variable under your cursor
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        -- Execute a code action
        map('<leader>a', vim.lsp.buf.code_action, '[C]ode [A]ction')
        -- Opens a documentation popup
        map('K', show_documentation, 'Hover Documentation')

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                callback = vim.lsp.buf.clear_references,
            })
        end
    end,
})

require("mason-lspconfig").setup({
    handlers = {
        function(server_name)
            require('lspconfig')[server_name].setup({})
        end,
        -- overrides
        -- ["lsp_name"] = function ()
        --     require("lspconfig").setup()
        -- end
    }
})

local cmp = require 'cmp'
cmp.setup({
    formatting = {
        format = require('lspkind').cmp_format({ show_labelDetails = true })
    },
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end,
        ['<s-tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end,
        ['<s-k>'] = function(fallback)
            if cmp.visible() then
                cmp.scroll_docs(-2)
            else
                fallback()
            end
        end,
        ['<s-j>'] = function(fallback)
            if cmp.visible() then
                cmp.scroll_docs(2)
            else
                fallback()
            end
        end,
        ['<esc>'] = function(fallback)
            if cmp.visible() then
                cmp.abort()
            else
                fallback()
            end
        end,
        ['<cr>'] = cmp.mapping.confirm({ select = false }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'dotenv', option = { load_shell = false, show_content_on_docs = false } },
    })
})

cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'git' },
    }, {
        { name = 'buffer' },
    })
})

cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

vim.cmd [[autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })]]

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

-- telescope setup
require('telescope').setup({
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
        ["ui-select"] = {
            require('telescope.themes').get_dropdown(),
        },
        file_browser = { hijack_netrw = true },
    },
    defaults = {
        file_ignore_patterns = { "^.git/", "yarn.lock" },
        mappings = {
            i = {
                ["jj"] = { "<esc>", type = "command" },
                ["<C-j>"] = require('telescope.actions').move_selection_next,
                ["<C-k>"] = require('telescope.actions').move_selection_previous,
                ["J"] = require('telescope.actions').preview_scrolling_down,
                ["K"] = require('telescope.actions').preview_scrolling_up,
                ["H"] = require('telescope.actions').preview_scrolling_left,
                ["L"] = require('telescope.actions').preview_scrolling_right,
            },
            n = {
                ["<C-j>"] = require('telescope.actions').move_selection_next,
                ["<C-k>"] = require('telescope.actions').move_selection_previous,
                ["J"] = require('telescope.actions').preview_scrolling_down,
                ["K"] = require('telescope.actions').preview_scrolling_up,
                ["H"] = require('telescope.actions').preview_scrolling_left,
                ["L"] = require('telescope.actions').preview_scrolling_right,
            }
        },
        layout_strategy = 'flex',
        sorting_strategy = "ascending",
        layout_config = { width = 0.95, prompt_position = 'top', scroll_speed = 1 },
    },
    pickers = {
        buffers = { sort_lastused = true },
        find_files = { hidden = true, no_ignore = false },
    },
})

vim.keymap.set('n', '?', function()
    local builtin = require 'telescope.builtin'
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })

function vim.getVisualSelection()
    vim.cmd('noau normal! "vy"')
    local text = vim.fn.getreg('v')
    vim.fn.setreg('v', {})

    text = string.gsub(text, "\n", "")
    if #text > 0 then
        return text
    else
        return ''
    end
end

vim.keymap.set('n', '<leader>fb', function()
    vim.cmd('normal! viw')
    local text = vim.getVisualSelection()
    require('telescope.builtin').live_grep({ default_text = text, initial_mode = 'normal' })
end, { noremap = true, silent = true })

vim.keymap.set('v', '<leader>fb', function()
    local text = vim.getVisualSelection()
    require('telescope.builtin').live_grep({ default_text = text, initial_mode = 'normal' })
end, { noremap = true, silent = true })

-- live grep using Telescope inside the current directory under
-- the cursor (or the parent directory of the current file)
local function grep_in()
    local api = require('nvim-tree.api')
    local node = api.tree.get_node_under_cursor()

    if not node then
        return
    end

    local path = node.absolute_path or uv.cwd()
    if node.type ~= 'directory' and node.parent then
        path = node.parent.absolute_path
    end

    require('telescope.builtin').live_grep({
        search_dirs = { path },
        prompt_title = string.format('Grep in [%s]', vim.fs.basename(path)),
    })
end

require('telescope').load_extension('terraform_doc')
require("telescope").load_extension("docker")
require("telescope").load_extension("file_browser")
require("telescope").load_extension("ui-select")
require('telescope').load_extension('fzf')

-- nvim-tree setup
require("nvim-tree").setup {
    hijack_cursor = true,
    hijack_netrw = false,
    reload_on_bufenter = true,
    update_focused_file = { enable = true },
    git = { enable = true },
    filters = {
        git_ignored = false,
        git_clean = false,
        dotfiles = false,
    },
    modified = { enable = true },
    actions = {
        expand_all = {
            exclude = { ".git", "node_modules", "dist", "build" }
        },
    },

    diagnostics = {
        enable = false,
        show_on_dirs = true,
        show_on_open_dirs = true,
    },
    on_attach = function(bufnr)
        local api = require('nvim-tree.api')

        local function opts(desc)
            return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
        vim.keymap.set('n', 'R', api.tree.reload, opts('Refresh'))
        vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
        vim.keymap.set('n', 'c', api.fs.cut, opts('Cut'))
        vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))
        vim.keymap.set('n', 'y', api.fs.copy.node, opts('Copy'))
        vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))
        vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
        vim.keymap.set('n', 'E', api.tree.expand_all, opts('Expand all'))
        vim.keymap.set('n', 'X', api.tree.collapse_all, opts('Collapse all'))
        vim.keymap.set('n', 'x', api.node.navigate.parent_close, opts('Close Directory'))
        vim.keymap.set('n', '<', api.node.navigate.parent_close, opts('Close Directory'))
        vim.keymap.set('n', ']', api.tree.change_root_to_node, opts('CD'))
        vim.keymap.set('n', '[', api.tree.change_root_to_parent, opts('Up'))
        vim.keymap.set('n', 'K', api.node.show_info_popup, opts('Info'))
        vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
        vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
        vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open: Horizontal Split'))
        vim.keymap.set('n', '<C-s>', api.node.open.horizontal, opts('Open: Horizontal Split'))
        vim.keymap.set('n', 'O', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', 'o', api.node.open.no_window_picker, opts('Open: No Window Picker'))
        vim.keymap.set('n', '<CR>', api.node.open.no_window_picker, opts('Open: No Window Picker'))
        vim.keymap.set('n', '>', api.node.open.no_window_picker, opts('Open: No Window Picker'))
        vim.keymap.set('n', '<2-LeftMouse>', api.node.open.no_window_picker, opts('Open: No Window Picker'))
        vim.keymap.set('n', '<C-f>', grep_in, opts('Search in directory'))
    end,
    view = {
        centralize_selection = false,
        width = { min = 32, max = -1, padding = 1 },
        side = "left",
    },
    renderer = {
        highlight_git = true,
        add_trailing = true,
        full_name = true,
        group_empty = false,
        highlight_opened_files = "all",
        highlight_modified = "all",
        root_folder_label = ":t:r",
        special_files = {},
        indent_markers = {
            enable = true,
        },
        icons = {
            git_placement = "after",
            modified_placement = "before",
            show = { file = false, folder = true },
        },
    },
}

-- Indent blankline
local hooks = require "ibl.hooks"
hooks.register(
    hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
    end
)

require("ibl").setup {
    indent = {
        char = "│",
        highlight =  {
            "RainbowRed",
            "RainbowYellow",
            "RainbowBlue",
            "RainbowOrange",
            "RainbowGreen",
            "RainbowViolet",
            "RainbowCyan",
        },
    },
    whitespace = { remove_blankline_trail = true },
    scope = { enabled = false },
    exclude = { filetypes = { "dbout" } },
}

-- winbar setup
vim.o.winbar = "%{expand(\"%:~:.\")} %m%=%{'ddddddddd'} "

-- status line setup
require('lualine').setup {
    options = {
        theme = 'everforest', -- other values: powerline, powerline_dark, gruvbox_dark
        icons_enabled = false,
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' }
    },
}

require('bufferline').setup({
    options = {
        mode = "buffers",
        indicator = { style = 'none' },
        enforce_regular_tabs = false,
        buffer_close_icon = 'x',
        close_icon = 'x',
        show_buffer_icons = false,
        show_buffer_default_icon = false,
        left_trunc_marker = '..',
        right_trunc_marker = '..',
        diagnostics = "nvim_lsp",
        separator_style = {"", ""},
        name_formatter = function(buf)
            return '' .. buf.name .. ' '
        end,
        always_show_bufferline = true,
        max_name_length = 50,
        tab_size = 2,
        offsets = {
            {
                filetype = "NvimTree",
                text = "Explorer",
                highlight = "Directory",
                separator = '',
                text_align = "left"
            }
        },
    },
})

EOF

let g:tmux_navigator_no_mappings = 1
let g:tmux_navigator_disable_when_zoomed = 1
nnoremap <silent> <c-h> :<C-U>TmuxNavigateLeft<cr>
nnoremap <silent> <c-d> :<C-U>TmuxNavigateDown<cr>
nnoremap <silent> <c-u> :<C-U>TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :<C-U>TmuxNavigateRight<cr>

" Quickly go to normal mode
inoremap jj <Esc>

" adding new lines from normal mode - for speed factoring and cleaning
nnoremap <CR> o<esc>
nnoremap <leader><return> O<esc>
inoremap <leader><return> <esc>O

" make enter behave normally for quickfix
augroup QuickFix
     au FileType qf map <buffer> <CR> <CR>
augroup END

" faster movoment - multiple line jumping
nmap <C-j> 10j
vmap <C-j> 10j
nmap <C-k> 10k
vmap <C-k> 10k

" single and double quotes in normal mode navigate forward and backwards 24 lines
nnoremap ' 20j
nnoremap " 20k

"split resizing
" increase vertically
nnoremap == <C-w>3+
" decrease vertically
nnoremap -- <C-w>3-
" increase horizontally
nnoremap <leader>] <C-w>4>
" decrease horizontally
nnoremap <leader>[ <C-w>4<

" leader+tab inserts a literal tab character in insert mode
inoremap <leader><Tab> <C-V><Tab>

nnoremap <Tab> za

nnoremap <leader>sr <Plug>RestNvim

" w moves to the end of word not the beginning of it
noremap w e

" e and r act as home and end keys
nnoremap e ^
vnoremap e ^
onoremap e ^
nnoremap r $
vnoremap r $
onoremap r $

" Remap j and k to act as expected when used on long, wrapped, lines
nnoremap <silent> j gj
vnoremap <silent> j gj
nnoremap <silent> k gk
vnoremap <silent> k gk
nnoremap <silent> <down> gj
vnoremap <silent> <down> gj
nnoremap <silent> <up> gk
vnoremap <silent> <up> gk

" redo with capital U
noremap U <C-r>

nnoremap <leader>g :enew<cr> " open new buffer

" search for selection
" use * for words under cursor
vnoremap <leader>f y/<C-R>"<cr>

" map leader+space to execute q macro quickly
nnoremap <leader><space> @q
vnoremap <leader><space> @q

" duplicate lines after
" without separator line
nnoremap <leader>d YP`[v`]<esc>l
vnoremap <leader>d YP`[v`]<esc>l

" swapping lines down and up respecting the top and bottom of the buffer
nnoremap <silent> H :m .+1<cr>==
vnoremap <expr><silent> H max([line('.'),line('v')]) < line('$') ? ':m ''>+1<cr>gv=gv' : ''
nnoremap <silent> L :m .-2<cr>==
vnoremap <expr><silent> L min([line('.'),line('v')]) > 1 ? ':m ''<-2<cr>gv=gv' : ''

"easier colons in normal mode
noremap <space> :

" enabling paste - note that this mapping doesn't work when paste is on
nnoremap <leader>v :set<space>invpaste<cr>
inoremap <leader>v <esc>:set<space>invpaste<cr>
vnoremap <leader>v <esc>:set<space>invpaste<cr>

" arrow mappings
:autocmd FileType js,javascript,blade,typescript,javascriptreact,typescriptreact,rust,php,go inoremap >> =>
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact imap afkj () => {
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact imap logkj console.log(
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact imap imkj import  from '
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact imap ifkj if () {<cr><esc>k$2hi
inoremap xx $
inoremap vv ``<esc>i

" mappings for speed buffer switching
nnoremap <leader>b :bprevious<CR>
nnoremap <leader>n :bnext<CR>

"mappings for saving files
nnoremap <leader>w :w<cr>
vnoremap <leader>w <esc>:w<cr>
inoremap <leader>w <esc>:w<cr>

" close current buffer without messing up with splits
function! DeleteBuffer()
    if &buftype ==# 'terminal'
        Bdelete!
    else
        Bdelete
    endif
endfunction

nnoremap <leader>q :call DeleteBuffer()<cr>
vnoremap <leader>q <esc>:call DeleteBuffer()<cr>
inoremap <leader>q <esc>:call DeleteBuffer()<cr>

" force close current buffer without saving and without messing up with splits
nnoremap <leader>z :Bdelete!<cr>
vnoremap <leader>z <esc>:Bdelete!<cr>
inoremap <leader>z <esc>:Bdelete!<cr>

" quit vim
nnoremap qqq <esc>:NvimTreeClose<cr>:q<CR>

" force quit vim
nnoremap <leader>fq <esc>:NvimTreeClose<CR>:q!<CR>

nmap <leader><leader>w :HopWord<cr>

"make < > keep selection after indentenation
vnoremap < <gv
vnoremap > >gv

" use single key stroke to indent single lines instead of double
nnoremap > >>
nnoremap < <<

" keeps what's yanked after pasting(putting)
nnoremap <expr> p 'p`[' . strpart(getregtype(), 0, 1) . '`]y'
vnoremap <expr> p 'p`[' . strpart(getregtype(), 0, 1) . '`]y'
nnoremap <leader>m :MaximizerToggle<cr>


" move splits
nnoremap <silent> <leader>h <c-w>H
nnoremap <silent> <leader>u <c-w>K

nnoremap <C-p> <cmd>lua require"telescope.builtin".find_files({ hidden = true })<CR>
nnoremap <C-o> <cmd>Telescope buffers<CR>
nnoremap <C-f> <cmd>Telescope live_grep<CR>
nnoremap <leader>o <cmd>Telescope file_browser path=%:p:h select_buffer=true initial_mode=normal<CR>

" toggle tag bar
nnoremap <leader>i <cmd>TagbarToggle<CR>

nnoremap ff :NvimTreeToggle<cr>
" nnoremap ff :Neotree source=filesystem position=left toggle reveal<cr>

" quickly switch currently open buffers
nnoremap <silent><leader>1 <Cmd>BufferLineGoToBuffer 1<CR>
nnoremap <silent><leader>2 <Cmd>BufferLineGoToBuffer 2<CR>
nnoremap <silent><leader>3 <Cmd>BufferLineGoToBuffer 3<CR>
nnoremap <silent><leader>4 <Cmd>BufferLineGoToBuffer 4<CR>
nnoremap <silent><leader>5 <Cmd>BufferLineGoToBuffer 5<CR>
nnoremap <silent><leader>6 <Cmd>BufferLineGoToBuffer 6<CR>
nnoremap <silent><leader>7 <Cmd>BufferLineGoToBuffer 7<CR>
nnoremap <silent><leader>8 <Cmd>BufferLineGoToBuffer 8<CR>
nnoremap <silent><leader>9 <Cmd>BufferLineGoToBuffer 9<CR>

" Save file with sudo
command! -nargs=0 WriteWithSudo :w !sudo tee % >/dev/null
" Use :ww instead of :WriteWithSudo
cnoreabbrev ww WriteWithSudo

" database UI
let g:db_ui_save_location = '~/projects/db-connections'

let g:better_whitespace_filetypes_blacklist=['NvimTree', 'diff', 'git', 'gitcommit', 'unite', 'qf', 'help', 'markdown', 'fugitive', 'dbout']

command! Qfall call s:quickFixOpenAll()
function! s:quickFixOpenAll()
  let files = {}
  for entry in getqflist()
    let filename = bufname(entry.bufnr)
    let files[filename] = 1
  endfor

  for file in keys(files)
    silent exe "edit ".file
  endfor
endfunction

hi FloatBorder ctermfg=Cyan
