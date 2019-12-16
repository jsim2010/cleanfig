" TODO: Could I implement kakuone-like behavior forcing nvim to default to
" visual mode?
" TODO: Review wellle/targets and kana/vim-textobj-user.
" TODO: Review fzf or denite.

" Ensure vim-plug is installed.
if !filereadable(expand('~/AppData/Local/nvim/autoload/plug.vim'))
  " For now, unable to echo messages or shell commands in windows (https://github.com/neovim/neovim/issues/7967). Expect to be fixed in 0.4.
  echomsg 'vim-plug is not installed; installing now...'
  silent !md \%HOMEDRIVE\%\%HOMEPATH\%\AppData\Local\nvim\autoload 2>NUL
  silent !powershell -command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim', $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('~\AppData\Local\nvim\autoload\plug.vim'))"
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Remove unnecessary banner.
let g:netrw_banner = 0

call plug#begin()

" Define syntax following base16 styling.
Plug 'chriskempson/base16-vim'

" In order for terminal colors 1-15 to make sense, some of base16's colors are
" repeated. The base16 colors that are left out are stored in terminal colors
" 16-21. This setting updates the nvim terminal colors configurations to
" account for this change.
let base16colorspace=256
set termguicolors

" Statusline
Plug 'itchyny/lightline.vim'

let g:lightline = {
      \ 'active': {
      \   'left': [
      \     ['mode', 'paste'],
      \     ['readonly', 'relativepath', 'modified']
      \     ],
      \   'right': [
      \     ['filetype'],
      \     ['language_client'],
      \     ],
      \   },
      \ 'inactive': {
      \   'left': [['relativepath']],
      \   'right': [
      \     ['lineinfo'],
      \     ],
      \   },
      \ 'tabline': {
      \   'left': [['tabs']],
      \   'right': [[]],
      \   },
      \ 'tab': {
      \   'active': ['cwd'],
      \   'inactive': ['cwd'],
      \   },
      \ 'component_function': {
      \   'language_client': 'LanguageClient#statusLine',
      \   },
      \ 'tab_component_function': {
      \   'cwd': 'getcwd',
      \   },
      \ }

" Utility plugin.
Plug 'tpope/vim-repeat'

" Handy bracket mappings.
Plug 'tpope/vim-unimpaired'

" Rework delete and change operators to write removed text to the black hole
" register by default.
Plug 'svermeulen/vim-cutlass'

" Map x as 'cut' operator, which writes removed text to the unnamed register.
nnoremap x d
xnoremap x d
nnoremap xx dd
nnoremap X D

" Provide substitution operators
Plug 'svermeulen/vim-subversive'

" Map r as 'substitute'.
nmap s <Plug>(SubversiveSubstitute)
nmap ss <Plug>(SubversiveSubstituteLine)
nmap S <Plug>(SubversiveSubstituteToEndOfLine)

" Git wrapper
Plug 'tpope/vim-fugitive'

" Add support for Language Server Protocol.
Plug 'autozimu/LanguageClient-neovim', {
      \ 'branch': 'next',
      \ 'do': 'powershell -executionpolicy bypass -File install.ps1',
      \ }

" Required for operations modifying multiple buffers like rename.
set hidden

" Ensure buffer spacing is kept constant.
set signcolumn=yes

let g:LanguageClient_serverCommands = {
      \ 'rust': ['rustup', 'run', 'stable', 'rls'],
      \ 'cpp': ['clangd'],
      \ }

let g:LanguageClient_diagnosticsDisplay = {
      \ 1: {
      \   "name": "Error",
      \   "signText": "X",
      \   "signTexthl": "Error",
      \   },
      \ 2: {
      \   "name": "Warning",
      \   "signText": "!",
      \   "signTexthl": "IncSearch",
      \   },
      \ 3: {
      \   "name": "Information",
      \   "signText": "i",
      \   "signTexthl": "Search",
      \   },
      \ 4: {
      \   "name": "Hint",
      \   "signText": "*",
      \   "signTexthl": "LightlineLeft_terminal_0_1",
      \   },
      \ }

" Always use preview window for hover output.
let g:LanguageClient_hoverPreview = "Always"
let g:LanguageClient_useVirtualText = 0

" Only apply language client mappings for supported filetypes.
function! MapLanguageClientKeys()
  if has_key(g:LanguageClient_serverCommands, &filetype)
    " Remap Lookup
    nnoremap <buffer> <silent> K :call LanguageClient#textDocument_hover()<CR>
    " Remap jump to definition.
    nnoremap <buffer> <silent> <C-]> :call LanguageClient#textDocument_definition()<CR>
    " Remap list all references.
    nnoremap <buffer> <silent> gr <Cmd>call LanguageClient#textDocument_references()<CR>
    setlocal completefunc=LanguageClient#complete
    setlocal formatexpr=LanguageClient#textDocument_rangeFormatting_sync()
    " TO BE ADDED:
    " Goto type definition?
    " Goto implementation
    " rename, additional use for automatically changing case via tpope/vim-abolish
    " List all symbols of buffer
    " Show code actions
    " Highlight references of current identifier, along with clear highlight
    " List project's symbols
  endif
endfunction

autocmd FileType * call MapLanguageClientKeys()

call plug#end()

" Colorscheme can only be set after plugins are activated.
colorscheme base16-tomorrow-night

" Function to customize base16 highlights.
function! SetBase16(group, fg, bg)
  if a:fg != ''
    execute 'let l:cterm_fg = g:base16_cterm' . a:fg
    execute 'let l:gui_fg = g:base16_gui' . a:fg

    execute 'hi ' . a:group . ' ctermfg=' . l:cterm_fg . ' guifg=#' . l:gui_fg
  endif

  if a:bg != ''
    execute 'let l:cterm_bg = g:base16_cterm' . a:bg
    execute 'let l:gui_bg = g:base16_gui' . a:bg

    execute 'hi ' . a:group . ' ctermbg=' . l:cterm_bg . ' guibg=#' . l:gui_bg
  endif
endfunction

" vimCommand matches with Keywords.
call SetBase16('vimCommand', '0E', '')
" Character matches with Constants.
call SetBase16('Character', '09', '')
" Tag matches with Support.
call SetBase16('Tag', '0C', '')
" NonText matches with status bars.
call SetBase16('NonText', '06', '01')
" DiffChange is incorrect.
call SetBase16('DiffChange', '0E', '03')

set breakindent
set diffopt+=vertical
" Widely agreed to always use spaces
set expandtab
" Set foldtext fill to be blank; this is better for identifying where the text ends.
set fillchars+=fold:\ 
" Remove line count from text shown by fold.
set foldtext=v:folddashes.getline(v:foldstart)
set shell=powershell.exe
set shellquote=
set shellpipe=\|
set shellredir=\|\ Out-File\ -Encoding\ UTF8
set shellxquote=
set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
set shiftround
set showbreak==>
" Mode is shown in statusline.
set noshowmode
" Always show tab (displays cwd)
set showtabline=2
" When window is split, move to the created window.
set splitbelow
set splitright
" Prevent commands from moving the column.
set nostartofline
" Make tilde behavior consistent.
set tildeop
set nowrapscan

noremap H 0
noremap gH g0
noremap L $
noremap gL g$
noremap J G
noremap K gg

" Go to c'h'ar and 'l'ine
noremap gh <Bar>
noremap gl gg

noremap $ g_

noremap - b
noremap = w
noremap _ B
noremap + W

" Nvim unable to recognize alacritty Shift+Tab mapping of "\x1b[Z". Thus
" PageUp keycode is used instead.
noremap <PageUp> <S-Tab>
noremap! <PageUp> <S-Tab>
tnoremap <PageUp> <S-Tab>

" Search repeat movements should always move in the same direction.
nnoremap <expr> n v:searchforward ? 'n' : 'N'
nnoremap <expr> N v:searchforward ? 'N' : 'n'
" Use q/Q to match functionality of lowercase vs uppercase for movement
nnoremap <expr> q getcharsearch().forward ? ';' : ','
nnoremap <expr> Q getcharsearch().forward ? ',' : ';'

" Show syntax at cursor.
nnoremap <C-S><C-S> <Cmd>echo string(map(synstack(line('.'), col('.')), 'synIDattr(v:val, ''name'')')) . ' -> ' . synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')<CR>

" <Esc> should always return to Normal mode.
tnoremap <Esc> <C-\><C-N>
" Provide functionality to send <Esc> to terminal.
tnoremap <Leader><Esc> <Esc>

" Do not lose selection after shift.
vnoremap < <gv
vnoremap > >gv
