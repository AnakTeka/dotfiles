" set number relativenumber

let g:ackhighlight = 1

noremap tt :tab split<CR>

noremap <Leader>a :Ack! <cword><cr>

cabbrev Ack Ack!

noremap <Leader>y "+y

if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

nnoremap <C-P> :FZF -m<CR>

" A better navigation move by virtual lines instead of physical lines.
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" Map x!! to sudo write and quit
cmap x!! w !sudo tee %<CR><CR>:q!<CR>
set foldmethod=indent

let g:neomake_open_list = 2

" Use deoplete.
" let g:deoplete#enable_at_startup = 1
" let g:deoplete#sources#jedi#debug_server = "wwawh.log"
" let g:deoplete#sources#jedi#show_docstring = 1
" " let g:deoplete#sources#jedi#enable_cache = 0
" let g:deoplete#sources#jedi#server_timeout = 60

nnoremap gV `[v`]       " highlight last inserted text
tnoremap <Esc> <C-\><C-n>

" let g:jedi#completions_enabled = 1

let g:python_host_prog = '/home/yoga/.config/nvim/plugged/python-support.nvim/autoload/nvim_py2/bin/python'
let g:python3_host_prog = '/home/yoga/.config/nvim/plugged/python-support.nvim/autoload/nvim_py3/bin/python3'

" Supertab from top
let g:SuperTabDefaultCompletionType = "<c-n>"


" Put plugins and dictionaries in this dir (also on Windows)
let vimDir = '$HOME/.vim'
let &runtimepath.=','.vimDir

" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
    let myUndoDir = expand(vimDir . '/undodir')
    " Create dirs
    call system('mkdir ' . vimDir)
    call system('mkdir ' . myUndoDir)
    let &undodir = myUndoDir
    set undofile
endif

" let g:SimpylFold_docstring_preview = 1
" let g:markdown_folding = 1
" let g:tex_fold_enabled = 1
" let g:vimsyn_folding = 'af'
" let g:xml_syntax_folding = 1
" let g:javaScript_fold = 1
" let g:sh_fold_enabled= 7
" let g:ruby_fold = 1
" let g:perl_fold = 1
" let g:perl_fold_blocks = 1
" let g:r_syntax_folding = 1
" let g:rust_fold = 1
" let g:php_folding = 1

" " python-mode
" let g:pymode = 0
" let g:pymode_python = 'python3'
" let g:pymode_virtualenv = 0
" let g:pymode_motion = 1

let g:lexima_enable_basic_rules=1

" add number on netrw buffer
let g:netrw_bufsettings = 'noma nomod nu nowrap ro nobl'

"h ttps://vi.stackexchange.com/questions/7464/autochdir-working-with-sp-but-not-e
let g:netrw_keepdir=0

" default updatetime 4000ms is not good for async update
set updatetime=100

" https://vi.stackexchange.com/a/21166
" set shm-=S
