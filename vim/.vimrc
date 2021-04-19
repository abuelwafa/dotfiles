"Abuelwafa's vim.rc file"

set nocompatible

set runtimepath+=~/projects/dotfiles/vim
set runtimepath+=~/projects/dotfiles/vim/after

" download vim-plug if its not present
if empty(glob('~/projects/dotfiles/vim/autoload/plug.vim'))
  silent !curl -fLo ~/projects/dotfiles/vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" initiate vim-plug
call plug#begin('~/projects/dotfiles/vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'Lokaltog/vim-easymotion'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'kevinoid/vim-jsonc'
Plug 'airblade/vim-gitgutter'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'psliwka/vim-smoothie'
Plug 'sheerun/vim-polyglot'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'hail2u/vim-css3-syntax'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'jparise/vim-graphql'
Plug 'othree/yajs.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Plug 'dense-analysis/ale' " removed in favor of coc
Plug 'kien/rainbow_parentheses.vim'
Plug 'tpope/vim-git'
Plug 'mileszs/ack.vim'
Plug 'christoomey/vim-system-copy'
Plug 'editorconfig/editorconfig-vim'
Plug 'Yggdroot/indentLine'
Plug 'tomtom/tcomment_vim'
Plug 'mattn/emmet-vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'bronson/vim-trailing-whitespace'
Plug 'terryma/vim-multiple-cursors'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'Raimondi/delimitMate'
Plug 'xolox/vim-misc'
Plug 'chriskempson/base16-vim'
Plug 'ayu-theme/ayu-vim'
Plug 'morhetz/gruvbox'
Plug 'rainglow/vim'
Plug 'rust-lang/rust.vim'
Plug 'fatih/vim-go'

call plug#end()

"===================================================
" basic configuration
"===================================================

set t_Co=256
syntax on
set ruler
set ttyfast

" Indentation
set smartindent
set cindent
set autoindent

" Search
set hlsearch
set incsearch
set smartcase
set ignorecase
" set gdefault
set showmatch

set colorcolumn=101
" set relativenumber

" disable code folding
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=20

set lbr
set showmode

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
" set noexpandtab

" improve autocomplete menu color
" highlight Pmenu ctermbg=238 gui=bold

set nopaste

set number " show line numbers
set cursorline " highlight current line

set completeopt="menuone,noinsert,noselect"

" sets backspace key functions, allows it to backspace over end of line
" characters, start of line, and indentation
set backspace=indent,eol,start

" movement keys will take you to the next or previous line
set whichwrap+=<,>,h,l

" scrolls the buffer before you reach the last line of the window
set scrolloff=4

" set encoding
set fileencoding=utf8
set encoding=utf8

" remember more commands and search history
set history=1000
" use many much of levels of undo  "
set undolevels=1000
set undofile
set undodir=$TEM

" hide buffers instead of closing them, allows for changing files without saving
set hidden

" disable backup and swap files
set nobackup
set noswapfile
set nowritebackup
" set backupdir^=~/.vim/_backup//    " where to put backup files.
" set directory^=~/.vim/_temp//      " where to put swap files.

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

set signcolumn=yes

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable delays and poor user experience. try experimenting with decreasing it to 200ms and check the performance
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" Better display for messages
set cmdheight=2

" set nolist
set list
" makes cursor on the begining of tab characters. makes it behaves like other editors
set listchars=tab:\ \
" view tabs with pipe character and three spaces to proper view indent guides
" set listchars=tab:\|\
" set listchars=tab:\|.
set listchars=tab:\|-
" set listchars=tab:\|_
" set listchars=tab:\>.
" set listchars=tab:\>-
" set listchars=tab:\>\
" set listchars=tab:.\
" set listchars+=trail:.
set listchars+=extends:>

" Open new windows on the bottom and right instead of the top and left.
set splitbelow
set splitright

" ctrlp plugin configuration
" let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn|vendor|node_modules)$'
let g:ctrlp_custom_ignore = '\v[\/](node_modules|vendor|bower_components|build)|(\.(swp|ico|git|hg|svn|jpg|png|gif|ttf|otf|woff|pdf))$'
let g:ctrlp_match_window = 'order:ttb,results:100,max:10'
let g:ctrlp_show_hidden = 1
let g:ctrlp_follow_symlinks = 1
let g:ctrlp_lazy_update = 1
let g:ctrlp_cache_dir = $HOME.'/.cache/ctrlp'

nnoremap <C-r> :CtrlPBufTagAll<cr>
nnoremap <C-o> :CtrlPBuffer<cr>

" rustlang formatting on save
let g:rustfmt_autosave = 1

" mappings for easy window navigation
" don't have much of an effect now because they are configured by tmux navigation
map <C-h> <C-w>h
map <C-d> <C-w>j
map <C-u> <C-w>k
map <C-l> <C-w>l

"split resizing
nnoremap == <C-w>3+ " increase vertically
nnoremap -- <C-w>3- " decrease vertically
nnoremap <leader>] <C-w>4> " increase horizontally
nnoremap <leader>[ <C-w>4< " decrease horizontally


" let g:indent_guides_enable_on_vim_startup = 1
" let g:indent_guides_guide_size=1
" let g:indent_guides_start_level=2

" nerdtree plugin configuration
let NERDTreeShowHidden=1 " show hidden files in nerdtree file plugin
let NERDTreeQuitOnOpen=0
let NERDTreeWinSize=32
let NERDTreeCaseSensitiveSort=1
let NERDTreeNaturalSort=1
" let NERDTreeWinPos="right"
let NERDTreeAutoDeleteBuffer=1
let NERDTreeDirArrows=1
let NERDTreeMinimalUI=1
let NERDTreeCascadeOpenSingleChildDir=1
let NERDTreeCascadeSingleChildDir=0
let NERDTreeIgnore=['.DS_Store']

" make sure not to open buffers on the nerdtree buffer
autocmd BufEnter * if bufname('#') =~# "^NERD_tree_" && winnr('$') > 1 | b# | endif
let g:plug_window = 'noautocmd vertical topleft new'

" open nerdtree on opening vim
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" close vim if nerdtree is the only buffer left
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" nerdtree toggle mapping
nnoremap ff :NERDTreeToggle<CR>

" mappings for speed buffer switching
nnoremap <leader>b :bprevious<CR>
nnoremap <leader>n :bnext<CR>

"mappings for saving files
nnoremap <leader>w :w<cr>
vnoremap <leader>w <esc>:w<cr>
inoremap <leader>w <esc>:w<cr>


" close current buffer without messing up with splits
nnoremap <leader>q :NERDTreeClose<CR>:bp<CR>:bd #<cr>
vnoremap <leader>q <esc>:NERDTreeClose<CR>:bp<CR>:bd #<cr>
inoremap <leader>q <esc>:NERDTreeClose<CR>:bp<CR>:bd #<cr>

" force close current buffer without saving and without messing up with splits
nnoremap <leader>z :NERDTreeClose<CR>:bn<CR>:bd! #<cr>
vnoremap <leader>z <esc>:NERDTreeClose<CR>:bn<CR>:bd! #<cr>
inoremap <leader>z <esc>:NERDTreeClose<CR>:bn<CR>:bd! #<cr>

" nnoremap <leader>q :NERDTreeClose<CR>:bd<cr>
" vnoremap <leader>q <esc>:NERDTreeClose<CR>:bd<cr>
" inoremap <leader>q <esc>:NERDTreeClose<CR>:bd<cr>
"
" nnoremap <leader>z :NERDTreeClose<CR>:bd!<cr>
" vnoremap <leader>z <esc>:NERDTreeClose<CR>:bd!<cr>
" inoremap <leader>z <esc>:NERDTreeClose<CR>:bd!<cr>

" quit vim
nnoremap qqq :NERDTreeClose<CR>:q<CR>

" force quit vim
" nnoremap <leader>fq <esc>:NERDTreeClose<CR>:q!<CR>
nnoremap <leader>fq :NERDTreeClose<CR>:qa!<CR>

"make < > keep selection after indentenation
vnoremap < <gv
vnoremap > >gv

" use single key stroke to indent single lines instead of double
nnoremap > v><Esc>
nnoremap < v<<Esc>

" keeps what's yanked(copied) after pasting(putting)
nnoremap <expr> p 'p`[' . strpart(getregtype(), 0, 1) . '`]y'
vnoremap <expr> p 'p`[' . strpart(getregtype(), 0, 1) . '`]y'

" disable automatic comment insertion on newlines after a comment
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" enable mouse in console
set mousemodel=extend
set mouse=a
set mousehide
set mouse+=a
if &term =~ '^screen'
    " tmux knows the extended mouse mode
    set ttymouse=xterm2
endif

" setting font for gvim and macvim
if has('gui_running')
    set guifont=Meslo\ LG\ S\ for\ Powerline:h18
endif

let g:tmux_navigator_no_mappings = 1
let g:tmux_navigator_disable_when_zoomed = 1

" nnoremap <ctrl-h> :TmuxNavigateLeft<cr>
" nnoremap <ctrl-d> :TmuxNavigateDown<cr>
" nnoremap <ctrl-u> :TmuxNavigateUp<cr>
" nnoremap <ctrl-l> :TmuxNavigateRight<cr>
" nnoremap <ctrl-\> :TmuxNavigatePrevious<cr>

" enable gitgutter
let g:gitgutter_enabled = 1
" let g:gitgutter_sign_column_always = 1
" if exists('&signcolumn')  " Vim 7.4.2201
"     set signcolumn=yes
" endif
" let g:gitgutter_override_sign_column_highlight = 0
:sign define dummy
:execute 'sign place 9999 line=1 name=dummy buffer=' . bufnr('')


" vim airline configuration
set fillchars+=stl:\ ,stlnc:\
" Always show status line
set laststatus=2
set ttimeoutlen=20
let g:airline#extensions#coc#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#buffers_label = 'b'
let g:airline#extensions#tabline#tabs_label = 't'
let g:airline#extensions#tabline#show_tab_type = 1
let g:airline#extensions#whitespace#enabled = 1
" let g:airline#extensions#tabline#left_sep = ''
" let g:airline#extensions#tabline#left_alt_sep = ''
" let g:airline#extensions#tabline#right_sep = ''
" let g:airline#extensions#tabline#right_alt_sep = ''
" let g:airline_theme='light'
let g:airline_theme='powerlineish'
" let g:airline_theme='dark'
" let g:airline_theme='luna'
let g:airline_inactive_collapse=1
let g:airline_skip_empty_sections = 1
let g:airline_highlighting_cache = 1
" let g:airline_section_b = ''
" let g:airline_section_z = '%4l%#__restore__#%#__accent_bold#/%L%{g:airline_symbols.maxlinenr}%#__restore__# :%3v'

" let g:airline_left_sep=''
" let g:airline_right_sep=''

" rainbow parentheses
let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkgray',    'DarkOrchid3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['red',         'firebrick3'],
    \ ]

" rainbow parentheses
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

" " ale plugin configuration
" let g:ale_linters = {
" \   'javascript': ['eslint'],
" \   'javascript.jsx': ['eslint'],
" \   'typescript': ['eslint'],
" \   'typescriptreact': ['eslint'],
" \}
" let g:ale_fixers = {
" \   '*': ['remove_trailing_lines', 'trim_whitespace'],
" \   'javascript': ['prettier'],
" \   'javascript.jsx': ['prettier'],
" \   'typescript': ['prettier'],
" \   'typescriptreact': ['prettier'],
" \}
" let g:ale_fix_on_save = 1
" let g:ale_completion_enabled = 1
" let g:ale_sign_column_always = 1
" let g:airline#extensions#ale#enabled = 1

" enable jsx for .js files
let g:jsx_ext_required = 0

let g:editorconfig_Beautifier = $HOME.'/projects/dotfiles/vim/.editorconfig'
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

set tags=./tags

" remove vim background - makes it transparent if the colorscheme has no background
highlight nonText ctermbg=NONE

let g:javascript_plugin_jsdoc = 1

" Highlight ES6 template strings
hi link javaScriptTemplateDelim String
hi link javaScriptTemplateVar Text
hi link javaScriptTemplateString String

augroup javascript_folding
    au!
    au FileType javascript setlocal foldmethod=syntax
    au FileType javascript.jsx setlocal foldmethod=syntax
augroup END

"===============================================================================
"===============================================================================
" COC configuration

let g:coc_global_extensions = [
  \ 'coc-prettier',
  \ 'coc-tsserver',
  \ 'coc-json',
  \ 'coc-html',
  \ 'coc-css',
  \ 'coc-styled-components',
  \ 'coc-snippets',
  \ 'coc-eslint',
  \ 'coc-pairs',
  \ 'coc-db',
  \ 'coc-sql',
  \ 'coc-highlight',
  \ 'coc-clangd',
  \ 'coc-sh',
  \ 'coc-rls',
  \ 'coc-go',
  \ 'coc-java',
  \ 'coc-phpls',
  \ 'coc-svg',
  \ 'coc-yaml',
  \ 'coc-cfn-lint',
  \ 'coc-vimlsp',
  \ ]

let g:vim_json_syntax_conceal = 0
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0


function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" map leader+space to omni completion in insert mode
" inoremap <leader><space> <C-x><C-o>

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-@> coc#refresh()
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
" " show documentation tooltip on cursor hold
" autocmd CursorHold * silent call <SID>show_documentation()

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap keys for applying codeAction to the current buffer.
nmap <leader>a <Plug>(coc-codeaction)
nmap <leader>ac <Plug>(coc-codeaction-selected)
xmap <leader>ac <Plug>(coc-codeaction-selected)
" Apply AutoFix to problem on the current line.
" nmap <leader>f <Plug>(coc-fix-current)

" Add `:Format` command to format current buffer.
" command! -nargs=0 Format :call CocAction('format')

" add prettier command
command! -nargs=0 Prettier :CocCommand prettier.formatFile

"===============================================================================
"===============================================================================
"===================================
" Custom Mappings
"===================================

" let mapleader=""

" Quickly get out of insert or visual mode without your fingers having to leave the home row (either use 'jj' or '\\')
vnoremap <leader><leader> <esc>
" inoremap <Bslash><Bslash> x<bs><esc>
" inoremap jj x<bs><Esc>
inoremap <leader><leader> <esc>
inoremap jj <Esc>

" nnoremap <bs> X " make backspace work in normal mode

" keep the whitespace indentation upon leaving the insert mode on blank lines
" nnoremap o ox<bs>
" nnoremap O Ox<bs>

" adding new lines from normal mode - for speed factoring and cleaning
" nnoremap <CR> ox<bs><esc>
nnoremap <CR> o<esc>
" nnoremap <leader><return> Ox<bs><esc>
nnoremap <leader><return> O<esc>
inoremap <leader><return> <esc>o
" inoremap <CR> x<bs>

" faster movoment - multiple line jumping
nmap <C-down> 10j
vmap <C-down> 10j
nmap <C-up> 10k
vmap <C-up> 10k
nmap <C-j> 10j
vmap <C-j> 10j
nmap <C-k> 10k
vmap <C-k> 10k

" single and double quotes in normal mode navigate forward and backwards 24 lines
nnoremap ' 20j
nnoremap " 20k

" leader+tab inserts a literal tab character in insert mode
inoremap <leader><Tab> <C-V><Tab>

" w moves to the end of word not the begining of it
noremap w e

" e and r act as home and end keys
nnoremap e ^
vnoremap e ^
onoremap e ^
nnoremap r $
vnoremap r $
onoremap r $

" Remap j and k to act as expected when used on long, wrapped, lines
nnoremap j gj
nnoremap k gk
nnoremap <down> gj
nnoremap <up> gk
" vnoremap j gj
" vnoremap k gk
" vnoremap <down> gj
" vnoremap <up> gk

noremap U <C-r> " redo with capital U

nnoremap <leader>g :enew<cr> " open new buffer

" search for selection
" use * for words under cursor
vnoremap <leader>f y/<C-R>"<cr>


" map leader+space to execute q macro quickly
nnoremap <leader><space> @q
vnoremap <leader><space> @q

" duplicate lines after
" without separator line
nnoremap <S-down> YP`[v`]<esc>l
vnoremap <S-down> YP`[v`]<esc>l
nnoremap <leader>d YP`[v`]<esc>l
vnoremap <leader>d YP`[v`]<esc>l
" and with separator line

" duplicate lines before
" without separator line
nnoremap <S-up> YP
vnoremap <S-up> YP

" swapping lines down
" nnoremap = Vdp
" vnoremap = Vdp`[v`]
nnoremap H Vdp
vnoremap H Vdp`[v`]

" swapping lines up
" nnoremap - VdkP
" vnoremap - VdkP`[v`]
nnoremap L VdkP
vnoremap L VdkP`[v`]

"easier colons in normal mode
noremap <space> :

" enabling paste - note that this mapping doesn't work when paste is on
nnoremap <leader>v :set<space>invpaste<cr>
inoremap <leader>v <esc>:set<space>invpaste<cr>
vnoremap <leader>v <esc>:set<space>invpaste<cr>

" arrow mappings
:autocmd FileType php,smarty,blade inoremap ,, ->
:autocmd FileType php,js,javascript,smarty,blade,typescript,javascriptreact,typescriptreact,rust inoremap << =>
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact inoremap afkj () => {}

:autocmd FileType php,js,javascript,scss,html,smarty,blade,typescript,sh imap xx $

" folding
nnoremap <C-i> za


" available mappings
" R
" z
" Z
" g
" ,
" <leader>g
" <leader>s
" <leader>h
" <leader>,
" <leader>i
" <leader>c

"====================================
" Colorschemes configurations
"====================================

" set background=dark
" let g:gruvbox_italicize_comments=0
" let g:gruvbox_contrast_dark = 'hard'
" let g:gruvbox_contrast_light = 'hard'
" let g:airline_theme='gruvbox'
" colorscheme gruvbox
" " cursor line color
" hi Cursorline term=none cterm=none ctermbg=236
" " change background color to black or none for transparent, better for my eyes
" hi Normal term=none cterm=none ctermbg=black
" hi Normal term=none cterm=none ctermbg=none
" set background=light

" set background=light
" let g:solarized_termcolors=256
" colorscheme solarized
" highlight SignColumn ctermbg=none
" let g:airline_theme='solarized'

" colorscheme kolor
" " hi Normal ctermbg=235
" " hi Normal term=none cterm=none ctermbg=none
" hi Cursorline term=none cterm=none ctermbg=234

" colorscheme molokai

" colorscheme gotham256
" set background=dark
" let g:airline_theme='gotham256'

" colorscheme dracula
" set background=dark

set background=dark
if filereadable(expand("~/.vimrc_background"))
    let base16colorspace=256
    source ~/.vimrc_background
endif


" set background=dark
" colorscheme atom-dark-256
" hi Normal term=none cterm=none ctermbg=none

" set background=light
" colorscheme summerfruit256
" hi Cursorline term=none cterm=none ctermbg=254
" " add a rule for styling visula mode select since its not appearing on the mac

" colorscheme lucius
" hi Normal ctermbg=233
" set background=dark

" colorscheme hemisu
" set background=light

" set background=dark
" " colorscheme seti
" colorscheme base16-seti-ui

" set background=dark
" colorscheme xoria256
" " hi Normal ctermbg=none
" hi Normal ctermbg=232
" hi Cursorline term=none cterm=none ctermbg=234

" colorscheme PaperColor
" let g:airline_theme='papercolor'
" " set background=light
" set background=dark
" " hi Cursorline term=none cterm=none ctermbg=232

" colorscheme jellybeans
" set background=dark
" hi Cursorline term=none cterm=none ctermbg=236
" let g:airline_theme='jellybeans'

" " seoul256 (dark):
" "   Range:   233 (darkest) ~ 239 (lightest)
" "   Default: 237
" set background=dark
" let g:seoul256_background = 234
" colo seoul256

" seoul256 (light):
"   Range:   252 (darkest) ~ 256 (lightest)
"   Default: 253
"let g:seoul256_background = 256
"colo seoul256

"============================================================================
" old configurations

" " ycm configuration
" let g:ycm_collect_identifiers_from_tags_files = 1
" let g:ycm_seed_identifiers_with_syntax = 1
" let g:ycm_collect_identifiers_from_comments_and_strings = 1
" let g:ycm_key_list_select_completion = ['<TAB>', '<Down>', '<Enter>']
"
" " " change ultisnips default trigger
" " let g:UltiSnipsExpandTrigger="kj"
" let g:UltiSnipsExpandTrigger="<c-space>"
" imap kj <c-space>
