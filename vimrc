set number

set ruler               " show the cursor position
syntax on               " syntax highlighting
set hlsearch            " highlight the last searched term
set showmatch           " show matching brackets
 

set expandtab
set shiftwidth=2
set tabstop=2

set wrap
set linebreak
set autoindent
"set smartindent
set breakindent
set showbreak=└───

colorscheme ir_black

" Remapping keys
noremap j gj
noremap gj j
noremap k gk
noremap gk k
noremap 0 g0
noremap g0 0
noremap $ g$
noremap g$ $
noremap ^ g^
noremap g^ ^
noremap <Up> g<Up>
noremap g<Up> <Up>
noremap <Down> g<Down>
noremap g<Down> <Down>
inoremap <Up> <C-O>g<Up>
inoremap <Down> <C-O>g<Down>
map <C-s> :w<CR>
imap <C-s> <C-O>:w<CR>
map <C-\> <C-s>\ll
imap <C-\> <C-s><C-O>\ll

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" disable error bells
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

" Reload .vimrc
noremap ",v :sp ~/.vimrc<CR>
noremap <silent> ",V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR> 
noremap ",l :sp ~/.vim/ftplugin/tex/texrc<CR>
noremap <silent> ",L :source ~/.vim/ftplugin/tex/texrc<CR>:filetype detect<CR>:exe ":echo 'texrc reloaded'"<CR> 

" Word wrap with diff
"au VimEnter * if &diff | execute 'windo set wrap' | endif
autocmd FilterWritePre * if &diff | setlocal wrap< | endif

"" Latex-Suite configuration
" REQUIRED. This makes vim invoke Latex-Suite when you open a tex file.
filetype plugin on

" IMPORTANT: win32 users will need to have 'shellslash' set so that latex
" can be called correctly.
set shellslash

" IMPORTANT: grep will sometimes skip displaying the file name if you
" search in a singe file. This will confuse Latex-Suite. Set your grep
" program to always generate a file-name.
set grepprg=grep\ -nH\ $*

" OPTIONAL: This enables automatic indentation as you type.
filetype indent on

" OPTIONAL: Starting with Vim 7, the filetype of empty .tex files defaults to
" 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
" The following changes the default filetype back to 'tex':
let g:tex_flavor='latex'

" TIP: if you write your \label's as \label{fig:something}, then if you
" type in \ref{fig: and press <C-n> you will automatically cycle through
" all the figure labels. Very useful!
autocmd BufEnter,BufRead,BufNewFile *.tex set iskeyword+=:

" Turn off conversion of plaintext into mathematical symbol
let g:tex_conceal = ""
autocmd BufEnter,BufRead,BufNewFile *.tex set conceallevel=0

"Prevent Vim from going to latex compilation error automatically
" let g:Tex_GotoError=0

"Remove certain indentkeys
"autocmd FileType tex set indentkeys-=}
"autocmd FileType tex set indentkeys-=.
"autocmd FileType tex set indentkeys-=)
"autocmd FileType tex set indentkeys-=]

"netrw settings
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 20
"augroup ProjectDrawer
"  autocmd!
"  autocmd VimEnter * :Vexplore
"augroup END
"hide list
let ghregex='\(^\|\s\s\)\zs\.\S\+'
let g:netrw_list_hide=ghregex

"indentLine settings
let g:indentLine_char = '│'
" Vim
let g:indentLine_color_term = 234

" GVim
let g:indentLine_color_gui = '#1C1C1C'

" Python: remove colon as keyword
autocmd BufEnter,BufRead,BufNewFile *.py set iskeyword-=:
