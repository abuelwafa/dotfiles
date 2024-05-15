"   ▄▄   █                    ▀▀█                    ▄▀▀
"   ██   █▄▄▄   ▄   ▄   ▄▄▄     █   ▄     ▄  ▄▄▄   ▄▄█▄▄   ▄▄▄
"  █  █  █▀ ▀█  █   █  █▀  █    █   ▀▄ ▄ ▄▀ ▀   █    █    ▀   █
"  █▄▄█  █   █  █   █  █▀▀▀▀    █    █▄█▄█  ▄▀▀▀█    █    ▄▀▀▀█
" █    █ ██▄█▀  ▀▄▄▀█  ▀█▄▄▀    ▀▄▄   █ █   ▀▄▄▀█    █    ▀▄▄▀█
" Abuelwafa's vim config
" simple vim config without plugins for use on servers

" leader
let mapleader = '\'
let g:mapleader = '\'

set nocompatible
filetype on
filetype plugin on
filetype indent on

syntax on
set t_Co=256

set ttyfast

" encoding
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set termencoding=utf-8
set ffs=unix,dos,mac
set formatoptions+=m
set formatoptions+=B

" select & complete
set selection=inclusive
set selectmode=mouse,key

set history=2000
set undolevels=1000
set noundofile

" improve autocomplete menu color
" " highlight Pmenu ctermbg=238 gui=bold

set omnifunc=syntaxcomplete#Complete

" disable backup and swap files
set nobackup
set nowritebackup
set noswapfile

" enable mouse in console
set mousemodel=extend
set mouse+=a
set mousehide
if &term =~ '^screen'
    " tmux knows the extended mouse mode
    set ttymouse=xterm2
endif

" don't give |ins-completion-menu| messages.
set shortmess+=cI

set autoread
au FocusGained,BufEnter * silent! checktime
set magic
set title

set novisualbell
set noerrorbells
set visualbell t_vb=
set t_vb=
set tm=500
set cmdheight=1

set ruler
set lazyredraw
set fsync
set lbr
set nopaste
set showcmd
set showmode
set showmatch
set matchtime=2
set hidden
set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch
" set colorcolumn=99
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab
set shiftround
set autoindent
set smartindent
set cindent
set shiftround
set number
set cursorline
set wrap

" Open new windows on the bottom and right instead of the top and left.
set splitbelow
set splitright

set scrolloff=4

set completeopt="menuone,noinsert,noselect"

" sets backspace key functions, allows it to backspace over end of line
" characters, start of line, and indentation
set backspace=indent,eol,start

" movement keys will take you to the next or previous line
set whichwrap+=<,>,h,l

" folding
set foldenable
set foldmethod=indent
set foldlevel=99
set foldnestmax=10
set foldminlines=2

set completeopt=longest,menu
set wildmenu                           " show a navigable menu for tab completion"
set wildmode=list:longest,list,full

set list
set listchars+=extends:>
set listchars=trail:\·,tab:\»\ ,nbsp:␣
match errorMsg /\s\+$/

" Disable archive files
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz
set wildignore+=*/vendor/gems/*,*/vendor/cache/*,*/.bundle/*,*/.sass-cache/*
set wildignore+=*/tmp/cache/assets/*/sprockets/*,*/tmp/cache/assets/*/sass/*
set wildignore+=*.swp,*~,._*
set wildignore+=*.o,*~,*.pyc,*.class

set signcolumn=yes

set updatetime=50

set background=dark
colorscheme default
hi Cursorline term=none cterm=none ctermbg=238
hi CursorlineNR term=none cterm=none ctermbg=238
" change background color to black or none for transparent, better for my eyes
hi Normal term=none cterm=none ctermbg=black
" hi Normal term=none cterm=none ctermbg=none

" set mouse shape to block in insert mode
set guicursor=i:block

" remove vim background - makes it transparent if the colorscheme has no background
highlight nonText ctermbg=NONE

" set mark column color
hi! link SignColumn   LineNr
hi! link ShowMarksHLl DiffAdd
hi! link ShowMarksHLu DiffChange

" status line
set statusline=%<%f\ %h%m%r%=%k[%{(&fenc==\"\")?&enc:&fenc}%{(&bomb?\",BOM\":\"\")}]\ %-14.(%l,%c%V%)\ %P
set laststatus=2
set ttimeoutlen=20

" ===========================================================
" Custom Mappings

" Quickly go to normal mode
inoremap jj <esc>

" adding new lines from normal mode - for speed refactoring and cleaning
nnoremap <CR> o<esc>
nnoremap <leader><return> O<esc>

" make enter behave normally for quickfix
augroup QuickFix
     au FileType qf map <buffer> <CR> <CR>
augroup END

" faster movoment - multiple line jumping
nmap <C-j> 10j
vmap <C-j> 10j
nmap <C-k> 10k
vmap <C-k> 10k

" single and double quotes in normal mode navigate forward and backwards 20 lines
nnoremap ' 20j
nnoremap " 20k

" split resizing
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

" open new buffer
nnoremap <leader>gg :enew<cr>

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

" easier colons in normal mode
noremap <space> :

" enabling paste - note that this mapping doesn't work when paste is on
au InsertLeave * set nopaste
nnoremap <leader>v :set<space>paste<cr>
inoremap <leader>v <esc>:set<space>paste<cr>

" arrow mappings
:autocmd FileType js,javascript,blade,typescript,javascriptreact,typescriptreact,rust,php,go inoremap >> =>
:autocmd FileType js,javascript,blade,typescript,javascriptreact,typescriptreact,rust,php,go inoremap ,, ->
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact imap afkj () => {
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact imap logkj console.log(
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact imap imkj import  from '
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact imap ifkj if () {<cr><esc>k$2hi
inoremap xx $
inoremap vv ``<esc>i
inoremap VV ~

" mappings for speed buffer switching
nnoremap <leader>b :bprevious<CR>
nnoremap <leader>n :bnext<CR>

" mappings for saving files
nnoremap <leader>w :w<cr>
vnoremap <leader>w <esc>:w<cr>
inoremap <leader>w <esc>:w<cr>

" close current buffer without messing up with splits
function! DeleteBuffer()
    if &buftype ==# 'terminal'
        bd!
    else
        bd
    endif
endfunction

nnoremap <leader>q :call DeleteBuffer()<cr>
vnoremap <leader>q <esc>:call DeleteBuffer()<cr>
inoremap <leader>q <esc>:call DeleteBuffer()<cr>

" force close current buffer without saving and without messing up with splits
nnoremap <leader>z :bd!<cr>
vnoremap <leader>z <esc>:bd!<cr>
inoremap <leader>z <esc>:bd!<cr>

" quit vim
nnoremap qqq <esc>:q<CR>

" force quit vim
nnoremap <leader>fq <esc>:q!<CR>

" make < > keep selection after indentenation
vnoremap < <gv
vnoremap > >gv

" use single key stroke to indent single lines instead of double
nnoremap > >>
nnoremap < <<

" keeps what's yanked after pasting(putting)
nnoremap <expr> p 'p`[' . strpart(getregtype(), 0, 1) . '`]y'
vnoremap <expr> p 'p`[' . strpart(getregtype(), 0, 1) . '`]y'
nnoremap <leader>m :MaximizerToggle<cr>

nnoremap <leader>t :term<cr>
tnoremap <ESC><ESC> <C-\><C-N>

nnoremap <silent> <esc><esc> :nohls<cr>

" move splits
nnoremap <silent> <leader>h <c-w>H
nnoremap <silent> <leader>u <c-w>K

" navigate splits
nnoremap <silent> <C-d> <C-W>j
nnoremap <silent> <C-u> <C-W>k
nnoremap <silent> <C-h> <C-W>h
nnoremap <silent> <C-l> <C-W>l

" Save file with sudo
command! -nargs=0 WriteWithSudo :w !sudo tee % >/dev/null
" Use :ww instead of :WriteWithSudo
cnoreabbrev ww WriteWithSudo

" Keep search pattern at the center of the screen."
" nnoremap <silent> n nzz
" nnoremap <silent> N Nzz
" nnoremap <silent> * *zz

" command mode, ctrl-a to head, ctrl-e to tail
cnoremap <C-j> <t_kd>
cnoremap <C-k> <t_ku>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>


" netrw config
nnoremap ff :Lexplore<cr>
let g:netrw_keepdir = 0
let g:netrw_winsize = 20
let g:netrw_banner = 0
let g:netrw_localcopydircmd = 'cp -r'
hi! link netrwMarkFile Search

function! NetrwMapping()
    " rename
    nmap <buffer> r R

    " create file
    nmap <buffer> a %:w<CR>:buffer #<CR>

    nmap <buffer> ? I
endfunction

augroup netrw_mapping
    autocmd!
    autocmd filetype netrw call NetrwMapping()
augroup END

" strip trailing whitespace
autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rust,twig,xml,yml,perl autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

" disable automatic comment insertion on newlines after a comment
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Highlight ES6 template strings
hi link javaScriptTemplateDelim String
hi link javaScriptTemplateVar Text
hi link javaScriptTemplateString String

augroup javascript_folding
    au!
    au FileType javascript setlocal foldmethod=syntax
    au FileType javascript.jsx setlocal foldmethod=syntax
augroup END

" map leader+space to omni completion in insert mode
inoremap <leader><space> <c-x><c-o>
inoremap <c-@> <c-x><c-o>

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

" copy to clipboard using xclip
vnoremap <leader>c :!clear && xclip -i -selection clipboard<cr>u

" update vimrc file
command! -nargs=0 UpdateVimrc :silent execute "!curl -fL https://raw.githubusercontent.com/abuelwafa/dotfiles/master/vim/.vimrc -o ~/.vimrc" | echo "Vimrc has been udpated. Restart vim to activate the new changes"
