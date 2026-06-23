set nocompatible
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set cursorline
set lazyredraw
set ttyfast
set showmatch
let mapleader=","
set noshowmode

" ── vim-plug ──────────────────────────────────────────────────────────────────
call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'joshdick/onedark.vim'
Plug 'ayu-theme/ayu-vim'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
Plug 'sjl/gundo.vim'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'mattn/emmet-vim'
call plug#end()

" ── Theme ─────────────────────────────────────────────────────────────────────
set background=dark
set t_Co=256

if (has("termguicolors"))
    set termguicolors
endif

colorscheme ayu
let ayucolor="mirage"

" ── Lightline ─────────────────────────────────────────────────────────────────
let g:lightline = {
    \ 'colorscheme': 'simpleblack',
    \ 'separator': { 'left': "", 'right': "" },
    \ 'subseparator': { 'left': "", 'right': "" },
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
    \ },
    \ 'component': {
    \   'readonly': '%{&filetype=="help"?"":&readonly?"":""}',
    \   'modified': '%{&filetype=="help"?"":&modified?"":&modifiable?"":"-"}',
    \   'gitbranch': '%{LightlineFugitive()}'
    \ },
    \ 'component_visible_condition': {
    \   'readonly': '(&filetype!="help"&& &readonly)',
    \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
    \   'gitbranch': 'LightlineFugitive() != ""'
    \ },
    \ }

function! LightlineFugitive()
  if (exists('*FugitiveHead'))
    let branch = FugitiveHead()
    return branch !=# '' ? ' '.branch : ''
  else
    return ''
  endif
endfunction

" ── Keymaps ───────────────────────────────────────────────────────────────────
nnoremap <leader><space> :nohlsearch<CR>
nnoremap j gj
nnoremap k gk
inoremap jk <esc>
nnoremap <leader>u :GundoToggle<CR>
map <C-o> :NERDTreeToggle<CR>
map ; :Files<CR>

" ── Plugin config ─────────────────────────────────────────────────────────────
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
let g:user_emmet_leader_key=','
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall
