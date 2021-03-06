" Modeline and Notes {
" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:
"
"                    __ _ _____              _
"         ___ _ __  / _/ |___ /      __   __(_)_ __ ___
"        / __| '_ \| |_| | |_ \ _____\ \ / /| | '_ ` _ \
"        \__ \ |_) |  _| |___) |_____|\ V / | | | | | | |
"        |___/ .__/|_| |_|____/        \_/  |_|_| |_| |_|
"            |_|
"
"   This is the personal .vimrc file of Steve Francia.
"   While much of it is beneficial for general use, I would
"   recommend picking out the parts you want and understand.
"
"   You can find me at http://vimde.com
"
"   Copyright 2014 Steve Francia
"
"   Licensed under the Apache License, Version 2.0 (the "License");
"   you may not use this file except in compliance with the License.
"   You may obtain a copy of the License at
"
"       http://www.apache.org/licenses/LICENSE-2.0
"
"   Unless required by applicable law or agreed to in writing, software
"   distributed under the License is distributed on an "AS IS" BASIS,
"   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
"   See the License for the specific language governing permissions and
"   limitations under the License.
" }

" Environment {

    " Identify platform {
        silent function! OSX()
            return has('macunix')
        endfunction
        silent function! LINUX()
            return has('unix') && !has('macunix') && !has('win32unix')
        endfunction
        silent function! WINDOWS()
            return  (has('win32') || has('win64'))
        endfunction
    " }

    " Basics {
        set nocompatible        " Must be first line
        if !WINDOWS()
            set shell=/bin/sh
        endif
    " }

    " Windows Compatible {
        " On Windows, also use '.vim' instead of 'vimfiles'; this makes synchronization
        " across (heterogeneous) systems easier.
        if WINDOWS()
          set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
        endif
    " }

    " Arrow Key Fix {
        " https://github.com/vimde/vimde-vim/issues/780
        if &term[:4] == "xterm" || &term[:5] == 'screen' || &term[:3] == 'rxvt'
            inoremap <silent> <C-[>OC <RIGHT>
        endif
    " }

" }

" Use before config if available {
    if filereadable(expand("~/.vimrc.before"))
        source ~/.vimrc.before
    endif
" }

" Use bundles config {
    if filereadable(expand("~/.vimrc.bundles"))
        source ~/.vimrc.bundles
    endif
" }

" General {

    set background=dark         " Assume a dark background

    " Allow to trigger background
    function! ToggleBG()
        let s:tbg = &background
        " Inversion
        if s:tbg == "dark"
            set background=light
        else
            set background=dark
        endif
    endfunction
    noremap <leader>bg :call ToggleBG()<CR>

    " if !has('gui')
        "set term=$TERM          " Make arrow and other keys work
    " endif
    filetype plugin indent on   " Automatically detect file types.
    syntax on                   " Syntax highlighting
    set mouse=a                 " Automatically enable mouse usage
    set mouse=n                 " no mouse when editing
    set mousehide               " Hide the mouse cursor while typing
    scriptencoding utf-8
    set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1

    if has('clipboard')
        if has('unnamedplus')  " When possible use + register for copy-paste
            set clipboard=unnamed,unnamedplus
        else         " On mac and Windows, use * register for copy-paste
            set clipboard=unnamed
        endif
    endif

    " WSL yank support
    let s:clip = '/mnt/c/Windows/System32/clip.exe'  " change this path according to your mount point
    if executable(s:clip)
        augroup WSLYank
            autocmd!
            autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
        augroup END
    endif

    " Most prefer to automatically switch to the current file directory when
    " a new buffer is opened; to prevent this behavior, add the following to
    " your .vimrc.before.local file:
    "   let g:vimde_no_autochdir = 1
    if !exists('g:vimde_no_autochdir')
        autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif
        " Always switch to the current file directory
    endif

    "set autowrite                       " Automatically write a file when leaving a modified buffer
    set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
    set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
    set virtualedit=onemore             " Allow for cursor beyond last character
    set history=1000                    " Store a ton of history (default is 20)
    set spell                           " Spell checking on
    set hidden                          " Allow buffer switching without saving
    set iskeyword-=.                    " '.' is an end of word designator
    set iskeyword-=#                    " '#' is an end of word designator
    set iskeyword-=-                    " '-' is an end of word designator

    " Spelling errors are higlighted using SpellBad highlighting group
    " set spell checking highlight styles after alternating color scheme or
    " background
    hi clear SpellBad
    hi SpellBad cterm=underline

    "disable autoread/auto reloading but enable auto check
    set noautoread
    " Check for file modifications automatically
    " (current buffer only).
    augroup autoCheckTime
        au!
        au CursorHold,FocusGained,BufEnter * checktime
    augroup end

    " Use :NoAutoChecktime to disable it (uses b:autochecktime)
    fun! AutoCheckTime()
      " only check timestamp for normal files
      if &buftype != '' | return | endif
      if ! exists('b:autochecktime') || b:autochecktime
        checktime %
        let b:autochecktime = 1
      endif
    endfun

    command! NoAutoChecktime let b:autochecktime=0

    " Instead of reverting the cursor to the last position in the buffer, we
    " set it to the first line when editing a git commit message
    au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

    " http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
    " Restore cursor to file position in previous editing session
    " To disable this, add the following to your .vimrc.before.local file:
    "   let g:vimde_no_restore_cursor = 1
    if !exists('g:vimde_no_restore_cursor')
        function! ResCur()
            if line("'\"") <= line("$")
                silent! normal! g`"
                return 1
            endif
        endfunction

        augroup resCur
            autocmd!
            autocmd BufWinEnter * call ResCur()
        augroup END
    endif

    " Setting up the directories {
        set backup                  " Backups are nice ...
        if has('persistent_undo')
            set undofile                " So is persistent undo ...
            set undolevels=1000         " Maximum number of changes that can be undone
            set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
        endif

        " To disable views add the following to your .vimrc.before.local file:
        "   let g:vimde_no_views = 1
        if !exists('g:vimde_no_views')
            " Add exclusions to mkview and loadview
            " eg: *.*, svn-commit.tmp
            let g:skipview_files = [
                \ '\[example pattern\]'
                \ ]
        endif
    " }

    "NeoVim handles ESC keys as alt+key, set this to solve the problem
    if has('nvim')
      set ttimeoutlen=0
      set ttimeout
    endif

" }

" Vim UI {

    "Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
    "If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
    "(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
    if (empty($TMUX) || 1)
      if (has("nvim"))
        "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
        "set t_8f=[38;2;%lu;%lu;%lum  " Needed in tmux
        "set t_8b=[48;2;%lu;%lu;%lum  " Ditto
        let $NVIM_TUI_ENABLE_TRUE_COLOR   = 1
      endif
    endif
    "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
    "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
    " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
    set t_8f=[38;2;%lu;%lu;%lum  " Needed in tmux
    set t_8b=[48;2;%lu;%lu;%lum  " Ditto
    if (has("termguicolors"))
        set termguicolors
    endif


    if (has("nvim"))
        "let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1
    endif
    " To enable mode shapes, "Cursor" highlight, and blinking:
    set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
                \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
                \,sm:block-blinkwait175-blinkoff150-blinkon175

    " highlight cursor
    "highlight Cursor         ctermfg=8 ctermbg=14 guifg=#002b36 guibg=#93a1a1
    "highlight Cursor         ctermfg=8 ctermbg=14 guifg=#002b36 guibg=#303030

    set cursorline                  " Highlight current line
    set cursorcolumn                " Highlight current column

    if !exists('g:override_vimde_bundles') && filereadable(expand("~/.vim/bundle/vim-colors-solarized/colors/solarized.vim"))
        if has('gui_running')
            set background=light
        else
            set background=dark
        endif
        let g:solarized_termcolors=256
        let g:solarized_termtrans=1
        let g:solarized_contrast="normal"
        let g:solarized_visibility="normal"
        "color solarized             " Load a colorscheme
    endif

    " OmniComplete menu highlighting{
        " highlight pop up menu
        hi Pmenu  guifg=#000000 guibg=#F8F8F8 ctermfg=black ctermbg=Lightgray
        hi PmenuSel cterm=bold ctermfg=239 ctermbg=1 gui=bold guifg=#504945 guibg=#83a598
        hi PmenuSbar  guifg=#8A95A7 guibg=#F8F8F8 gui=NONE ctermfg=darkcyan ctermbg=lightgray cterm=NONE
        hi PmenuThumb  guifg=#F8F8F8 guibg=#8A95A7 gui=NONE ctermfg=lightgray ctermbg=darkcyan cterm=NONE

        " maybe this setting is better
        hi Pmenu  guifg=#000000 guibg=#F8F8F8 ctermfg=cyan ctermbg=8
        hi PmenuSel cterm=bold ctermfg=239 ctermbg=green gui=bold guifg=#504945 guibg=#83a598
    "}

    " NeoSolarized {
        if filereadable(expand("~/.vim/bundle/NeoSolarized/colors/NeoSolarized.vim"))
            " default value is "normal", Setting this option to "high" or "low" does use the
            " same Solarized palette but simply shifts some values up or down in order to
            " expand or compress the tonal range displayed.
            let g:neosolarized_contrast = "high"

            " Special characters such as trailing whitespace, tabs, newlines, when displayed
            " using ":set list" can be set to one of three levels depending on your needs.
            " Default value is "normal". Provide "high" and "low" options.
            let g:neosolarized_visibility = "normal"

            " If you wish to enable/disable NeoSolarized from displaying bold, underlined or italicized
            " typefaces, simply assign 1 or 0 to the appropriate variable.
            let g:neosolarized_bold      = 1
            let g:neosolarized_underline = 1
            let g:neosolarized_italic    = 0
            colorscheme NeoSolarized    " Load a colorcheme
        endif
    " }


    set tabpagemax=15               " Only show 15 tabs
    set showmode                    " Display the current mode

    highlight clear SignColumn      " SignColumn should match background
    highlight clear LineNr          " Current line number row will have same background color in relative mode
    "highlight clear CursorLineNr    " Remove highlight color from current line number
    highlight clear SignColumn      " SignColumn should match background
    highlight clear VertSplit      " SignColumn should match background


    if has('cmdline_info')
        set ruler                   " Show the ruler
        set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
        set showcmd                 " Show partial commands in status line and
                                    " Selected characters/lines in visual mode
    endif

    if has('statusline')
        set laststatus=2

        " Broken down into easily includeable segments
        set statusline=%<%f\                     " Filename
        set statusline+=%w%h%m%r                 " Options
        if !exists('g:override_vimde_bundles')
            set statusline+=%{fugitive#statusline()} " Git Hotness
        endif
        set statusline+=\ [%{&ff}/%Y]            " Filetype
        set statusline+=\ [%{getcwd()}]          " Current dir
        set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info

        " count of search occurrences
        " FIXME: visual % will not work
        function! SearchCount()
            let keyString=@/
            let pos=getpos('.')
            try
                " validate input
                if keyString =~ '^$' " empty string
                    return '0' . '/' . '0'
                endif

                if keyString =~ '^\\$'
                    return '0/0'
                endif

                let nth="0 matches on 0 lines"
                let cnt="0 matches on 0 lines"
                redir => nth
                    silent exe '0,.s/' . keyString . '//gne'
                redir => cnt
                    silent exe '%s/' . keyString . '//ne'
                redir END

                " post check
                if !exists('nth') " undefined, empty string from stdout
                    echo "nth doesn't exist yet!"
                    return '0' . '/' . '0'
                endif
                if !exists('cnt') " empty string
                    return '0' . '/' . '0'
                endif

                " regular expression matching, \v for magic(extended regex)
                return matchstr(nth, '\v\d+') . '/' . matchstr(cnt, '\v\d+')
            finally
                call setpos('.', pos)
            endtry
        endfunction
        set statusline+=[%{SearchCount()}] " Nth of N when searching

    endif

    set backspace=indent,eol,start  " Backspace for dummies
    set linespace=0                 " No extra spaces between rows
    set number                      " Line numbers on
    set showmatch                   " Show matching brackets/parenthesis
    set incsearch                   " Find as you type search
    set hlsearch                    " Highlight search terms
    set winminheight=0              " Windows can be 0 line high
    set ignorecase                  " Case insensitive search
    set smartcase                   " Case sensitive when uc present
    set wildmenu                    " Show list instead of just completing
    set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
    set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
    set scrolljump=5                " Lines to scroll when cursor leaves screen
    set scrolloff=3                 " Minimum lines to keep above and below cursor
    set foldenable                  " Auto fold code
    set foldmethod=indent
    set foldlevel=9
    "list feature can be used to reveal hidden characters
    set list
    "type unicode characters: press <ctrl-v>u, followed by its unicode number
    "set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
    set listchars=tab:¦\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
    "set listchars=tab:▸\ ,trail:•,eol:¬,extends:#,nbsp:.  " Highlight problematic whitespace
    "Invisible character colors, but it's overriden by colorscheme plugins
    highlight NonText guifg=#4a4a59
    highlight SpecialKey guifg=#4a4a59

    set concealcursor=n

" }

" Formatting {

    set nowrap                      " Do not wrap long lines
    set wrap                        " wrap long lines
    set autoindent                  " Indent at the same level of the previous line
    set shiftwidth=4                " Use indents of 4 spaces
    " set noexpandtab                   " Tabs are spaces, not tabs
    set tabstop=4                   " An indentation every four columns
    set softtabstop=4               " Let backspace delete indent
    set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
    set splitright                  " Puts new vsplit windows to the right of the current
    set splitbelow                  " Puts new split windows to the bottom of the current
    "set matchpairs+=<:>             " Match, to be used with %
    set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
    "set comments=sl:/*,mb:*,elx:*/  " auto format comment blocks
    " Remove trailing whitespaces and ^M chars
    " To disable the stripping of whitespace, add the following to your
    " .vimrc.before.local file:
    "   let g:vimde_keep_trailing_whitespace = 1
    autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rust,twig,xml,yml,perl,sql autocmd BufWritePre <buffer> if !exists('g:vimde_keep_trailing_whitespace') | call StripTrailingWhitespace() | endif
    autocmd FileType c,cpp,objc,objcpp setlocal noexpandtab shiftwidth=4 tabstop=4 softtabstop=4
    "autocmd FileType go autocmd BufWritePre <buffer> Fmt
    autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
    autocmd FileType haskell,puppet,ruby,yml,javascript,jsx,javascript.jsx,html,xhtml,xml,css,json setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
    " preceding line best in a plugin but here for now.

    autocmd BufNewFile,BufRead *.coffee set filetype=coffee

    " Workaround vim-commentary for Haskell
    autocmd FileType haskell setlocal commentstring=--\ %s
    " Workaround broken colour highlighting in Haskell
    autocmd FileType haskell,rust setlocal nospell
    " Note: this could be override by vim-autoformat plugin
    "au FileType python setlocal formatprg=autopep8\ -\ --aggressive\ --aggressive\ --ignore\ E302
    au FileType javascript setlocal formatprg=esformatter

" }

" Key (re)Mappings {

    " http://vim.wikia.com/wiki/Replace_a_builtin_command_using_cabbrev{
    " map :e to :E, :cabbrev e <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'E' : 'e')<CR>
        function! CommandCabbr(abbreviation, expansion)
          execute 'cabbrev ' . a:abbreviation . ' <c-r>=getcmdpos() == 1 && getcmdtype() == ":" ? "' . a:expansion . '" : "' . a:abbreviation . '"<CR>'
        endfunction
        command! -nargs=+ CommandCabbr call CommandCabbr(<f-args>)
        " Use it on itself to define a simpler abbreviation for itself.
        CommandCabbr alias CommandCabbr
    " }

    " The default leader is '\', but many people prefer ',' as it's in a standard
    " location. To override this behavior and set it back to '\' (or any other
    " character) add the following to your .vimrc.before.local file:
    "   let g:vimde_leader='\'
    if !exists('g:vimde_leader')
        let mapleader = ','
    else
        let mapleader=g:vimde_leader
    endif
    if !exists('g:vimde_localleader')
        let maplocalleader = '_'
    else
        let maplocalleader=g:vimde_localleader
    endif

    " The default mappings for editing and applying the vimde configuration
    " are <leader>ev and <leader>sv respectively. Change them to your preference
    " by adding the following to your .vimrc.before.local file:
    "   let g:vimde_edit_config_mapping='<leader>ec'
    "   let g:vimde_apply_config_mapping='<leader>sc'
    if !exists('g:vimde_edit_config_mapping')
        let s:vimde_edit_config_mapping = '<leader>ev'
    else
        let s:vimde_edit_config_mapping = g:vimde_edit_config_mapping
    endif
    if !exists('g:vimde_apply_config_mapping')
        let s:vimde_apply_config_mapping = '<leader>sv'
    else
        let s:vimde_apply_config_mapping = g:vimde_apply_config_mapping
    endif

    " Easier moving in tabs and windows
    " The lines conflict with the default digraph mapping of <C-K>
    " If you prefer that functionality, add the following to your
    " .vimrc.before.local file:
    "   let g:vimde_no_easyWindows = 1
    if !exists('g:vimde_no_easyWindows')
        "map <C-J> <C-W>j<C-W>_
        "map <C-K> <C-W>k<C-W>_
        "map <C-L> <C-W>l<C-W>_
        "map <C-H> <C-W>h<C-W>_
        map <C-J> <C-W>j
        map <C-K> <C-W>k
        map <C-L> <C-W>l
        map <C-H> <C-W>h
    endif

    " Wrapped lines goes down/up to next row, rather than next line in file.
    noremap j gj
    noremap k gk

    " selecte last changed text
    "nnoremap <expr> gp `[v`]
    nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

    " End/Start of line motion keys act relative to row/wrap width in the
    " presence of `:set wrap`, and relative to line for `:set nowrap`.
    " Default vim behaviour is to act relative to text line in both cases
    " If you prefer the default behaviour, add the following to your
    " .vimrc.before.local file:
    "   let g:vimde_no_wrapRelMotion = 1
    if !exists('g:vimde_no_wrapRelMotion')
        " Same for 0, home, end, etc
        function! WrapRelativeMotion(key, ...)
            let vis_sel=""
            if a:0
                let vis_sel="gv"
            endif
            if &wrap
                execute "normal!" vis_sel . "g" . a:key
            else
                execute "normal!" vis_sel . a:key
            endif
        endfunction

        " Map g* keys in Normal, Operator-pending, and Visual+select
        noremap $ :call WrapRelativeMotion("$")<CR>
        noremap <End> :call WrapRelativeMotion("$")<CR>
        noremap 0 :call WrapRelativeMotion("0")<CR>
        noremap <Home> :call WrapRelativeMotion("0")<CR>
        noremap ^ :call WrapRelativeMotion("^")<CR>
        " Overwrite the operator pending $/<End> mappings from above
        " to force inclusive motion with :execute normal!
        onoremap $ v:call WrapRelativeMotion("$")<CR>
        onoremap <End> v:call WrapRelativeMotion("$")<CR>
        " Overwrite the Visual+select mode mappings from above
        " to ensure the correct vis_sel flag is passed to function
        vnoremap $ :<C-U>call WrapRelativeMotion("$", 1)<CR>
        vnoremap <End> :<C-U>call WrapRelativeMotion("$", 1)<CR>
        vnoremap 0 :<C-U>call WrapRelativeMotion("0", 1)<CR>
        vnoremap <Home> :<C-U>call WrapRelativeMotion("0", 1)<CR>
        vnoremap ^ :<C-U>call WrapRelativeMotion("^", 1)<CR>
        vnoremap H <Nop>
    endif

    " The following two lines conflict with moving to top and
    " bottom of the screen
    " If you prefer that functionality, add the following to your
    " .vimrc.before.local file:
    "   let g:vimde_no_fastTabs = 1
    if !exists('g:vimde_no_fastTabs')
        nmap <M-h> gT
        nmap <M-l> gt
        nmap <M-t> :tabnew<CR>
        nmap <M-w> :tabclose<CR>
        "nmap <M-S-t> :tabnew#<CR>
        "nnoremap <S-PageUp> :tabmove -1<CR>
        "nnoremap <S-PageDown> :tabmove +1<CR>
        nnoremap <M-H> :tabmove -1<CR> " <M-H> is <M-S-H>
        nnoremap <M-L> :tabmove +1<CR>

    endif

    " fast tabs
    nnoremap <S-Tab> :tabprevious<CR>
    nnoremap <Tab> :tabnext<CR> " go to

    " Stupid shift key fixes
    if !exists('g:vimde_no_keyfixes')
        if has("user_commands")
            command! -bang -nargs=* -complete=file E e<bang> <args>
            command! -bang -nargs=* -complete=file W w<bang> <args>
            command! -bang -nargs=* -complete=file Wq wq<bang> <args>
            command! -bang -nargs=* -complete=file WQ wq<bang> <args>
            command! -bang Wa wa<bang>
            command! -bang WA wa<bang>
            command! -bang Q q<bang>
            command! -bang QA qa<bang>
            command! -bang Qa qa<bang>
        endif

        cmap Tabe tabe
    endif

    " Yank/copy and paste {
    "Paste in visual mode without copying
        "xnoremap p pgvy
        " use '"_', the blackhole register, see ':help "_'
        " delete without yanking
        "vnoremap <leader>d "_d
        "nnoremap <leader>d "_d
        " replace visually selected text without copying it: delete into black hole register, then paste
        vnoremap p "_dP
    " }

    " Yank from the cursor to the end of the line, to be consistent with C and D.
    nnoremap Y y$

    " Code folding options
    nmap <leader>f0 :set foldlevel=0<CR>
    nmap <leader>f1 :set foldlevel=1<CR>
    nmap <leader>f2 :set foldlevel=2<CR>
    nmap <leader>f3 :set foldlevel=3<CR>
    nmap <leader>f4 :set foldlevel=4<CR>
    nmap <leader>f5 :set foldlevel=5<CR>
    nmap <leader>f6 :set foldlevel=6<CR>
    nmap <leader>f7 :set foldlevel=7<CR>
    nmap <leader>f8 :set foldlevel=8<CR>
    nmap <leader>f9 :set foldlevel=9<CR>

    " easier search {
        " search for visually selected text, http://vim.wikia.com/wiki/Search_for_visually_selected_text
        vnoremap // y/\V<C-r>=escape(@",'/\')<CR><CR>

        " search within range, http://vim.wikia.com/wiki/Search_only_over_a_visual_range
        vnoremap / <Esc>/\%><C-R>=line("'<")-1<CR>l\%<<C-R>=line("'>")+1<CR>l
        vnoremap ? <Esc>?\%><C-R>=line("'<")-1<CR>l\%<<C-R>=line("'>")+1<CR>l

        " Permanent very magic mode, like POSIX regular expression, see :help magic
        " http://vim.wikia.com/wiki/Simplifying_regular_expressions_using_magic_and_no-magic
        " Refer to https://github.com/vim-scripts/Enchanted-Vim
        nnoremap / /\v
        nnoremap ? ?\v
        "vnoremap / y/\v<C-R>"<CR>
        "vnoremap ? y?\v<C-R>"<CR>
        "cnoremap %s/ %smagic/
        cnoremap %s/ %s/\v
        "cnoremap '<,'>s/ '<,'>s/\v " doesn't work
        cnoremap \>s/ \>smagic/
        nnoremap :g/ :g/\v
        nnoremap :g// :g//
    " }

    " record: to apply the recorded macro over visually selected lines,
    " map visual at {
        vnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

        function! ExecuteMacroOverVisualRange()
            echo "@".getcmdline()
            execute ":'<,'>normal @".nr2char(getchar())
        endfunction

    " }

    " Most prefer to toggle search highlighting rather than clear the current
    " search results. To clear search highlighting rather than toggle it on
    " and off, add the following to your .vimrc.before.local file:
    "   let g:vimde_clear_search_highlight = 1
    if exists('g:vimde_clear_search_highlight')
        nmap <silent> <leader>/ :nohlsearch<CR>
    else
        nmap <silent> <leader>/ :set invhlsearch<CR>
    endif


    " Find merge conflict markers
    map <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>

    " Shortcuts
    " Change Working Directory to that of the current file
    "cmap cwd lcd %:p:h
    command Cwd lcd %:p:h "
    "cmap cd. lcd %:p:h
    "cmap ccp let @+ = expand("%:p") " Copy current File full Path into unnamedplus register
    command Ccp  let @+ = expand("%:p") "  Copy current File full Path into unnamedplus register
    " WSL(Windows subsystem for Linux) support
    if system('uname -r') =~ "Microsoft"
        command! Ccp call system(s:clip, expand("%:p")) " command! to override previously defined commands
    endif

    " Visual shifting (does not exit Visual mode)
    vnoremap < <gv
    vnoremap > >gv

    " Allow using the repeat operator with a visual selection (!)
    " http://stackoverflow.com/a/8064607/127816
    vnoremap . :normal .<CR>

    " For when you forget to sudo.. Really Write the file.
    cmap w!! w !sudo tee % >/dev/null
    cmap w\ w " ignore accidentally pressing \ when hitting <Enter>

    " Some helpers to edit mode
    " http://vimcasts.org/e/14
    cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
    map <leader>ew :e %%
    map <leader>es :sp %%
    map <leader>ev :vsp %%
    map <leader>et :tabe %%

    " Adjust viewports to the same size
    map <Leader>= <C-w>=

    " Map <Leader>ff to display all lines with keyword under cursor
    " and ask which one to jump to
    "nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

    " Easier horizontal scrolling
    map zl zL
    map zh zH

    " Easier formatting
    nnoremap <silent> <leader>q gwip
    nnoremap <silent> <leader>m :%s/\r//g<CR>

    " FIXME: Revert this f70be548
    " fullscreen mode for GVIM and Terminal, need 'wmctrl' in you PATH
    map <silent> <F11> :call system("wmctrl -ir " . v:windowid . " -b toggle,fullscreen")<CR>
    "autocmd FileType text,help,vim nnoremap <C-]> :tjump<CR>

    " universal INSERT MODE editting key mappings to be compatible with editors
    " Ctrl-S to save in insert mode
    imap <c-s> <Esc>:w<CR>a
    " Map Ctrl-A -> Start of line, Ctrl-E -> End of line
    imap <C-a> <Home>
    "inoremap <C-a> <C-U>call WrapRelativeMotion("^", 1)<CR>
    imap <C-e> <End>

    " redo, undo in insert mode
    inoremap <C-Z> <Esc>ua
    "inoremap <C-Z> <Esc>:undo<CR>a
    inoremap <C-R> <Esc>:redo<CR>a

    "digraphs alphsubs ---------------------- {
            execute "digraphs as " . 0x2090
            execute "digraphs es " . 0x2091
            execute "digraphs hs " . 0x2095
            execute "digraphs is " . 0x1D62
            execute "digraphs js " . 0x2C7C
            execute "digraphs ks " . 0x2096
            execute "digraphs ls " . 0x2097
            execute "digraphs ms " . 0x2098
            execute "digraphs ns " . 0x2099
            execute "digraphs os " . 0x2092
            execute "digraphs ps " . 0x209A
            execute "digraphs rs " . 0x1D63
            execute "digraphs ss " . 0x209B
            execute "digraphs ts " . 0x209C
            execute "digraphs us " . 0x1D64
            execute "digraphs vs " . 0x1D65
            execute "digraphs xs " . 0x2093
    "}

    " base64.
    " https://stackoverflow.com/questions/7845671/how-to-execute-base64-decode-on-selected-text-in-vim
    " {
    " :'<,'>!base64 -d -
    " :'<,'>!python -m base64 -d
        nnoremap <leader>bd :%!base64 -d -<CR>
        nnoremap <leader>be :%!base64 -<CR>
        " vnoremap <leader>64 y:echo system('base64 --decode', @")<cr>")
    " }

    " JSON {
        " format with Linux jq::%!jq --tab -S . %
        " Or, format with python -m json.tool
        nmap <leader>jf <Esc>:%!python -m json.tool<CR><Esc>:set filetype=json<CR>
        let g:vim_json_syntax_conceal = 0
    " }



" }

" Plugins {

    "General Programming  {
         if count(g:vimde_bundle_groups, 'programming')
            "rainbow_parentheses.vim
            au VimEnter * RainbowParenthesesToggle
            au Syntax * RainbowParenthesesLoadRound
            au Syntax * RainbowParenthesesLoadSquare
            au Syntax * RainbowParenthesesLoadBraces

            " sideways.vim
            nnoremap <, :SidewaysLeft<cr>
            nnoremap >. :SidewaysRight<cr>
        endif
    "}

    " TextObj Sentence {
        if count(g:vimde_bundle_groups, 'writing')
            augroup textobj_sentence
              autocmd!
              autocmd FileType markdown call textobj#sentence#init()
              autocmd FileType textile call textobj#sentence#init()
              autocmd FileType text call textobj#sentence#init()
            augroup END
        endif
    " }

    " TextObj Quote {
        if count(g:vimde_bundle_groups, 'writing')
            augroup textobj_quote
                autocmd!
                autocmd FileType markdown call textobj#quote#init()
                autocmd FileType textile call textobj#quote#init()
                autocmd FileType text call textobj#quote#init({'educate': 0})
            augroup END
        endif
    " }

    " nerdcommenter {
        let NERDSpaceDelims=1
        let g:NERDCustomDelimiters = {
            \ 'javascript': { 'left': '// ', 'leftAlt': '/* ', 'rightAlt': '*/' },
            \ 'javascript.jsx': { 'left': '// ', 'leftAlt': '/* ', 'rightAlt': '*/' },
            \ 'jsx': { 'left': '// ', 'leftAlt': '/* ', 'rightAlt': '*/' },
        \ }
        "map <C-/> <Esc><plug>NERDCommenterToggle<CR>i
        if OSX()
            " Do Mac stuff here
            "map <D-/> <Esc><plug>NERDCommenterToggle<CR>i
            "imap <D-/> <Esc><plug>NERDCommenterToggle<CR>i
            "imap <C-/> <Esc><plug>NERDCommenterToggle<CR>i
        endif
    " }

    " vim-autoformat {
        "vim-autoformat
        "noremap <F3> :Autoformat<CR>
        noremap <F7> :Autoformat<CR>
        "au BufWrite * :Autoformat
        let g:formatter_yapf_style = 'pep8'

    " }

    " PIV {
        if isdirectory(expand("~/.vim/bundle/PIV"))
            let g:DisableAutoPHPFolding = 0
            let g:PIVAutoClose = 0
        endif
    " }

    " Misc {
        if isdirectory(expand("~/.vim/bundle/nerdtree"))
            let g:NERDShutUp=1
        endif
        if isdirectory(expand("~/.vim/bundle/matchit.zip"))
            let b:match_ignorecase = 1
        endif
    " }

    " OmniComplete {
        " To disable omni complete, add the following to your .vimrc.before.local file:
        "   let g:vimde_no_omni_complete = 1
        if !exists('g:vimde_no_omni_complete')
            if has("autocmd") && exists("+omnifunc")
                autocmd Filetype *
                    \if &omnifunc == "" |
                    \setlocal omnifunc=syntaxcomplete#Complete |
                    \endif
            endif

            " Some convenient mappings
            "inoremap <expr> <Esc>      pumvisible() ? "\<C-e>" : "\<Esc>"
            if exists('g:vimde_map_cr_omni_complete')
                inoremap <expr> <CR>     pumvisible() ? "\<C-y>" : "\<CR>"
            endif
            inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
            inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
            inoremap <expr> <C-d>      pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
            inoremap <expr> <C-u>      pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"

            " Automatically open and close the popup menu / preview window
            au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
            set completeopt=menu,preview,longest
        endif
    " }

    " Ctags {
        set tags=./tags;/,~/.vimtags

        " Make tags placed in .git/tags file available in all levels of a repository
        let gitroot = substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
        if gitroot != ''
            let &tags = &tags . ',' . gitroot . '/.git/tags'
        endif
    " }

    " AutoCloseTag {
        " Make it so AutoCloseTag works for xml and xhtml files as well
        au FileType xhtml,xml ru ftplugin/html/autoclosetag.vim
        nmap <Leader>ac <Plug>ToggleAutoCloseMappings
    " }

    " SnipMate {
        " Setting the author var
        " If forking, please overwrite in your .vimrc.local file
        let g:snips_author = 'Alex Hacker <alex.h.hacker@gmail.com>'
    " }

    " NerdTree {
        if isdirectory(expand("~/.vim/bundle/nerdtree"))
            "map <C-e> <plug>NERDTreeTabsToggle<CR>
            map <leader>e :NERDTreeFind<CR>
            nmap <leader>nt :NERDTreeFind<CR>

            let NERDTreeWinSize          = 60
            let NERDTreeShowBookmarks    = 1
            let NERDTreeIgnore           = ['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$', '.DS_Store', '\.out']
            let NERDTreeChDirMode        = 2
            let NERDTreeQuitOnOpen       = 0
            let NERDTreeMouseMode        = 2
            let NERDTreeShowHidden       = 1
            let NERDTreeKeepTreeInNewTab = 1

            let g:nerdtree_tabs_open_on_gui_startup = 0
            let g:nerdtree_tabs_autofind            = 0
            let g:nerdtree_tabs_focus_on_files      = 1
        endif
    " }

    " auto-pairs {
        let g:AutoPairsFlyMode            = 0
        let g:AutoPairsShortcutBackInsert = '<M-b>'
        let g:AutoPairsMapCR              = 0       " <Enter> is mapped to select completion result in insert mode
        " XXX: avoid conflict with completeParameter. A better way?
        "let g:AutoPairs = {'[':']', '{':'}',"'":"'",'"':'"', '`':'`'}
        "inoremap <buffer><silent> ) <C-R>=AutoPairsInsert(')')<CR>
    " }

    " Tabularize {
    " DEPRECATED, favoring vim-easy-align
        if isdirectory(expand("~/.vim/bundle/tabular"))
            nmap <Leader>a& :Tabularize /&<CR>
            vmap <Leader>a& :Tabularize /&<CR>
            nmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
            vmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
            nmap <Leader>a=> :Tabularize /=><CR>
            vmap <Leader>a=> :Tabularize /=><CR>
            nmap <Leader>a: :Tabularize /:<CR>
            vmap <Leader>a: :Tabularize /:<CR>
            nmap <Leader>a:: :Tabularize /:\zs<CR>
            vmap <Leader>a:: :Tabularize /:\zs<CR>
            nmap <Leader>a, :Tabularize /,<CR>
            vmap <Leader>a, :Tabularize /,<CR>
            nmap <Leader>a,, :Tabularize /,\zs<CR>
            vmap <Leader>a,, :Tabularize /,\zs<CR>
            nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
            vmap <Leader>a<Bar> :Tabularize /<Bar><CR>
        endif
    " }

    " vim-easy-align {
        if isdirectory(expand('~/.vim/bundle/vim-easy-align'))
            " Start interactive EasyAlign in visual mode (e.g. vipga), default
            " ga
            xmap <leader>a <Plug>(EasyAlign)
            vmap <leader>a <Plug>(EasyAlign)

            " Start interactive EasyAlign for a motion/text object (e.g. gaip), default ga
            nmap <leader>a <Plug>(EasyAlign)
        endif
    " }

    " Session List {
        set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
        "if isdirectory(expand("~/.vim/bundle/sessionman.vim/"))
            "nmap <leader>sl :SessionList<CR>
            "nmap <leader>ss :SessionSave<CR>
            "nmap <leader>sc :SessionClose<CR>
        "endif
    " }

    " ctrlp {
        if isdirectory(expand("~/.vim/bundle/ctrlp.vim/"))
            let g:ctrlp_working_path_mode = 'ra'
            nnoremap <silent> <D-t> :CtrlP<CR>
            nnoremap <silent> <D-r> :CtrlPMRU<CR>
            let g:ctrlp_custom_ignore = {
                \ 'dir':  '\.git$\|\.hg$\|\.svn$|node_modules$',
                \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$' }

            if executable('ag')
                let s:ctrlp_fallback = 'ag %s --nocolor -l -g ""'
            elseif executable('ack-grep')
                let s:ctrlp_fallback = 'ack-grep %s --nocolor -f'
            elseif executable('ack')
                let s:ctrlp_fallback = 'ack %s --nocolor -f'
            " On Windows use "dir" as fallback command.
            elseif WINDOWS()
                let s:ctrlp_fallback = 'dir %s /-n /b /s /a-d'
            else
                let s:ctrlp_fallback = 'find %s -type f'
            endif
            if exists("g:ctrlp_user_command")
                unlet g:ctrlp_user_command
            endif
            let g:ctrlp_user_command = {
                \ 'types': {
                    \ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others'],
                    \ 2: ['.hg', 'hg --cwd %s locate -I .'],
                \ },
                \ 'fallback': s:ctrlp_fallback
            \ }

            if isdirectory(expand("~/.vim/bundle/ctrlp-funky/"))
                " CtrlP extensions
                let g:ctrlp_extensions = ['funky']

                "funky
                nnoremap <Leader>fu :CtrlPFunky<Cr>
            endif
        endif
    "}

    " fzf.vim: fuzzy finder {
        if isdirectory(expand("~/.vim/bundle/fzf.vim"))
            nnoremap <c-M-p> :Files<cr>
            nmap <leader>lf :Files<CR>
            " list files
            nnoremap <c-p> :GFiles<cr>
            nmap <leader>lg :GFiles<CR>
            " list buffers
            nnoremap <C-M-b> :Buffers<cr>
            CommandCabbr buffers Buffers
            nmap <leader>lb :Buffers<CR>
            nmap <leader>ls :Buffers<CR>
            "CommandCabbr ls Buffers
            " list windows
            nmap <leader>lw :Windows<CR>
            CommandCabbr history History
        endif
    " }

    " TagBar {
        if isdirectory(expand("~/.vim/bundle/tagbar/"))
            let updatetime=600
            let g:tagbar_sort = 0
            nnoremap <silent> <leader>tt :TagbarToggle<CR>
        endif
    "}

    " Rainbow {
        if isdirectory(expand("~/.vim/bundle/rainbow/"))
            let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
        endif
    "}

    " Fugitive {
        if isdirectory(expand("~/.vim/bundle/vim-fugitive/"))
            nnoremap <silent> <leader>ga :Git add %<CR>
            nnoremap <silent> <leader>gs :Gstatus<CR>
            nnoremap <silent> <leader>gd :Gdiff<CR>
            nnoremap <silent> <leader>gc :Gcommit<CR>
            nnoremap <silent> <leader>gb :Gblame<CR>
            nnoremap <silent> <leader>gl :Glog<CR>
            nnoremap <silent> <leader>gp :Git push<CR>
            nnoremap <silent> <leader>gr :Gread<CR>
            nnoremap <silent> <leader>gw :Gwrite<CR>
            nnoremap <silent> <leader>ge :Gedit<CR>
            " Mnemonic _i_nteractive
            nnoremap <silent> <leader>gi :Git add -p %<CR>
            nnoremap <silent> <leader>gg :SignifyToggle<CR>
        endif
    "}

    " Neomake {
        if isdirectory(expand("~/.vim/bundle/neomake"))
            "augroup lint
                "autocmd! FileType python,javascript
                            "\ autocmd! BufWritePost,BufWinEnter * Neomake
                " Details about autocmd see :help autocmd
                "autocmd! InsertLeave,BufWrite,BufWinEnter * Neomake
                "autocmd! BufWritePost,BufWinEnter * Neomake
                "autocmd! CursorHold,CursorHoldI * Neomake
            "augroup END
            let g:neomake_python_flake82_maker = {
                \ 'exe': 'python2',
                \ 'args': [ '-m' , 'flake8'],
                \ 'errorformat':
                    \ '%E%f:%l: could not compile,%-Z%p^,' .
                    \ '%A%f:%l:%c: %t%n %m,' .
                    \ '%A%f:%l: %t%n %m,' .
                    \ '%-G%.%#'
                \ }
            let g:neomake_python_flake83_maker = {
                \ 'exe': 'python3',
                \ 'args': ['-m', 'flake8'],
                \ 'errorformat':
                    \ '%E%f:%l: could not compile,%-Z%p^,' .
                    \ '%A%f:%l:%c: %t%n %m,' .
                    \ '%A%f:%l: %t%n %m,' .
                    \ '%-G%.%#'
                \ }
            let g:neomake_python_pylint2_maker = {
                \ 'exe': 'PYTHONPATH=$PYTHONPATH:`pwd` python2',
                \ 'args': [
                    \ '-m', 'pylint', '--rcfile=~/.pylintrc',
                    \ '-f', 'text',
                    \ '--msg-template="{path}:{line}:{column}:{C}: [{symbol}] {msg}"',
                    \ '-r', 'n'
                \ ],
                \ 'errorformat':
                    \ '%A%f:%l:%c:%t: %m,' .
                    \ '%A%f:%l: %m,' .
                    \ '%A%f:(%l): %m,' .
                    \ '%-Z%p^%.%#,' .
                    \ '%-G%.%#',
                \ }
            let g:neomake_python_pylint3_maker = {
                \ 'exe': 'python3',
                \ 'args': [
                    \ '-m', 'pylint', '--rcfile=~/.pylintrc',
                    \ '-f', 'text',
                    \ '--msg-template="{path}:{line}:{column}:{C}: [{symbol}] {msg}"',
                    \ '-r', 'n'
                \ ],
                \ 'errorformat':
                    \ '%A%f:%l:%c:%t: %m,' .
                    \ '%A%f:%l: %m,' .
                    \ '%A%f:(%l): %m,' .
                    \ '%-Z%p^%.%#,' .
                    \ '%-G%.%#',
                \ }
            let g:neomake_python_python2_maker = {
                \ 'args': [ '-c',
                    \ "from __future__ import print_function\n" .
                    \ "from sys import argv, exit\n" .
                    \ "if len(argv) != 2:\n" .
                    \ "    exit(1)\n" .
                    \ "try:\n" .
                    \ "    compile(open(argv[1]).read(), argv[1], 'exec', 0, 1)\n" .
                    \ "except SyntaxError as err:\n" .
                    \ "    print('%s:%s:%s: %s' % (err.filename, err.lineno, err.offset, err.msg))"
                \ ],
                \ 'errorformat': '%E%f:%l:%c: %m',
                \ }
            let g:neomake_python_python3_maker = {
                \ 'args': [ '-c',
                    \ "from __future__ import print_function\n" .
                    \ "from sys import argv, exit\n" .
                    \ "if len(argv) != 2:\n" .
                    \ "    exit(1)\n" .
                    \ "try:\n" .
                    \ "    compile(open(argv[1]).read(), argv[1], 'exec', 0, 1)\n" .
                    \ "except SyntaxError as err:\n" .
                    \ "    print('%s:%s:%s: %s' % (err.filename, err.lineno, err.offset, err.msg))"
                \ ],
                \ 'errorformat': '%E%f:%l:%c: %m',
                \ }
            "let g:neomake_javascript_eslint_maker = {
                "\ 'pipe': 1,
                "\ 'args': ['-f', 'compact', '--stdin', '--stdin-filename'],
                "\ 'errorformat': '%E%f: line %l\, col %c\, Error - %m,' .
                "\ '%W%f: line %l\, col %c\, Warning - %m'
                "\ }
            "let g:neomake_jsx_eslint_maker = {
                "\ 'pipe': 1,
                "\ 'args': ['-f', 'compact', '--stdin', '--stdin-filename'],
                "\ 'errorformat': '%E%f: line %l\, col %c\, Error - %m,' .
                "\ '%W%f: line %l\, col %c\, Warning - %m'
                "\ }

            "let g:neomake_javascript_enabled_makers = ['eslint']
            "let g:neomake_python_enabled_makers     = ['python', 'pylint', 'flake8']
            let g:neomake_python_enabled_makers      = ['pylint']
            let g:neomake_cpp_enable_markers         = ['clang']
            let g:neomake_cpp_clang_args             = ["-std=c++14", "-Wextra", "-Wall", "-g"]
            "let g:neomake_objc_enabled_makers       = ['clang']
            let g:neomake_serialize                  = 1
            let g:neomake_serialize_abort_on_error   = 1
            let g:neomake_logfile                   = '/tmp/neomake.error.log'
            let g:neomake_airline                    = 1
            let g:neomake_open_list                  = 0
            let g:neomake_verbose                    = 1
            let g:neomake_error_sign                 = {
                \ 'text': '✗',
                \ 'texthl': 'Error',
                \ }

        endif
    " }

    " Syntastic {
        if isdirectory(expand("~/.vim/bundle/syntastic/"))
            let g:syntastic_mode_map = {
                \ 'mode': 'passive',
                   \ 'passive_filetypes':
                   \ [
                       \ 'go',
                       \ 'python',
                       \ 'c',
                       \ 'cpp',
                       \ 'javascript',
                       \ 'jsx',
                       \ 'javascript.jsx',
                       \ 'markdown',
                       \ 'sh'
                   \ ]
               \ }
            set statusline+=%#warningmsg#
            "set statusline+=%{SyntasticStatuslineFlag()}
            set statusline+=%*

            let g:syntastic_always_populate_loc_list = 1
            let g:syntastic_auto_loc_list            = 1
            let g:syntastic_check_on_open            = 0
            let g:syntastic_check_on_wq              = 0
            let g:syntastic_aggregate_errors         = 0
            let g:syntastic_error_symbol             = '✗'
            let g:syntastic_warning_symbol           = '⚠'
            let g:syntastic_enable_ballons           = has('ballon_eval')
            let g:syntastic_javascript_checkers      = ['eslint']
            "let g:syntastic_javascript_checkers     = ['jsxhint']
            "let g:syntastic_javascript_jsxhint_exec = 'jsx-jsxhint-wrapper'
            let g:syntastic_json_checkers            = ['jsonlint', 'jsonval']
            " flake8 combines pep8 and pyflakes
            "let g:syntastic_python_checkers        = ['python2', 'pylint', 'flake8']
            let g:syntastic_python_checkers         = ['python2', 'pylint']
            let g:syntastic_ruby_checkers           = ['rubocop','mri']
            let g:syntastic_perl_checkers           = ['perl','perlcritic','podchecker']
            let g:syntastic_cpp_checkers            = ['gcc','cppcheck','cpplint','ycm','clang_tidy','clang_check']
            let g:syntastic_c_checkers              = ['gcc','make','cppcheck','clang_tidy','clang_check']
            let g:syntastic_haml_checkers           = ['haml_lint', 'haml']
            let g:syntastic_html_checkers           = ['jshint']
            let g:syntastic_yaml_checkers           = ['jsyaml']
            let g:syntastic_sh_checkers             = ['sh','shellcheck','checkbashisms']
            let g:syntastic_vim_checkers            = ['vimlint']
            let g:syntastic_enable_perl_checker     = 1
            let g:syntastic_c_clang_tidy_sort       = 1
            let g:syntastic_c_clang_check_sort      = 1
            let g:syntastic_c_remove_include_errors = 1
            let g:syntastic_quiet_messages          = { "level": "[]", "file": ['*_LOCAL_*', '*_BASE_*', '*_REMOTE_*']  }
            let g:syntastic_stl_format              = '[%E{E: %fe #%e}%B{, }%W{W: %fw #%w}]'
            let g:syntastic_java_javac_options      = "-g:none -source 8 -Xmaxerrs 5 -Xmaswarns 5"
        endif

    " }


    " A code-completion engine for Vim
    " Use Ctrl+Space to trigger the completion suggestions anywhere, even without a string prefix.
    " YouCompleteMe {
        if count(g:vimde_bundle_groups, 'youcompleteme')

            let g:ycm_auto_trigger                                       = 1
            " enable completion from tags
            let g:ycm_collect_identifiers_from_tags_files                = 1
            let g:ycm_global_ycm_extra_conf                              = $HOME."/.vim/bundle/YouCompleteMe/third_party/ycmd/.ycm_extra_conf.py"
            let g:ycm_global_ycm_extra_conf                              = $HOME."/.ycm_extra_conf.py"
            let g:ycm_confirm_extra_conf                                 = 0
            let g:ycm_collect_identifiers_from_tags_files                = 1 " Let YCM read tags from Ctags file
            let g:ycm_use_ultisnips_completer                            = 1 " Default 1, just ensure
            let g:ycm_seed_identifiers_with_syntax                       = 1 " Completion for programming language's keyword
            let g:ycm_complete_in_comments                               = 1 " Completion in comments
            let g:ycm_complete_in_strings                                = 1 " Completion in string
            let g:ycm_goto_buffer_command                                = 'new-or-existing-tab' "where GoTo* commands result should be opened.
            let g:ycm_key_list_select_completion                         = ['<TAB>', '<Down>']
            let g:ycm_key_list_previous_completion                       = ['<S-TAB>', '<Up>']
            let g:ycm_key_list_stop_completion                           = ['<C-Y>', '<CR>']
            let g:ycm_show_diagnostics_ui                                = 1 " YCM's diagnostic, supporting custome configs
            "let g:ycm_error_symbol                                       = 'E'
            let g:ycm_error_symbol                                       = '✗'
            let g:ycm_error_symbol                                       = '⚠'
            let g:ycm_enable_diagnostic_signs                            = 1
            let g:ycm_server_keep_logfiles                               = 1
            let g:ycm_server_use_vim_stdout                              = 0
            " python option
            "let g:ycm_path_to_python_interpreter                         = "python3"
            "let g:ycm_python_binary_path                                 = "python"
            " rust option
            let g:ycm_rust_src_path                                      = $RUST_SRC_PATH.'/'

            nnoremap <leader>gd :YcmCompleter GoToDefinitionElseDeclaration<CR>
            "inoremap <silent><expr><CR> pumvisible() ? "\<C-y>" : "\<CR>"
            "autocmd FileType c,cpp,python,javascript,go,rust,objc,objcpp,cs,typescript let g:ycm_auto_trigger = 1
            autocmd FileType c,cpp,python,javascript,go,rust,objc,objcpp,cs,typescript nnoremap <C-]> :YcmCompleter GoTo<CR>
            autocmd FileType c,cpp,python,javascript,go,rust,objc,objcpp,cs,typescript nnoremap <S-K> :YcmCompleter GetDoc<CR>

            autocmd Filetype c,cpp ALEDisable
            "cmap ycmfixit YcmCompleter FixIt
            CommandCabbr fixit YcmCompleter\ FixIt

            " Haskell post write lint and check with ghcmod
            " $ `cabal install ghcmod` if missing and ensure
            " ~/.cabal/bin is in your $PATH.
            if !executable("ghcmod")
                autocmd BufWritePost *.hs GhcModCheckAndLintAsync
            endif

            " For snippet_complete marker.
            if !exists("g:vimde_no_conceal")
                if has('conceal')
                    set conceallevel=2 concealcursor=n " conceal only in normal mode
                endif
            endif

            " Disable the preview  window
            " When enabled, there can be too much visual noise especially when splits are used.
            set completeopt-=preview
            "let g:ycm_add_preview_to_completeopt = 1
        endif
    " }

    " coc.nvim {
        " Conquer of Completion, language server leveraging VSCode plugins
        if count(g:vimde_bundle_groups, 'coc.nvim')

            " Set internal encoding of vim, not needed on neovim, since coc.nvim using some
            " unicode characters in the file autoload/float.vim
            set encoding=utf-8

            " TextEdit might fail if hidden is not set.
            set hidden

            " Some servers have issues with backup files, see #649.
            set nobackup
            set nowritebackup

            " Give more space for displaying messages.
            set cmdheight=2

            " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
            " delays and poor user experience.
            set updatetime=300

            " Don't pass messages to |ins-completion-menu|.
            set shortmess+=c

            " Always show the signcolumn, otherwise it would shift the text each time
            " diagnostics appear/become resolved.
            if has("nvim-0.5.0") || has("patch-8.1.1564")
              " Recently vim can merge signcolumn and number column into one
              set signcolumn=number
            else
              set signcolumn=yes
            endif

            " Use tab for trigger completion with characters ahead and navigate.
            " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
            " other plugin before putting this into your config.
            inoremap <silent><expr> <TAB>
                  \ pumvisible() ? "\<C-n>" :
                  \ <SID>check_back_space() ? "\<TAB>" :
                  \ coc#refresh()
            inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

            function! s:check_back_space() abort
              let col = col('.') - 1
              return !col || getline('.')[col - 1]  =~# '\s'
            endfunction

            " Use <c-space> to trigger completion.
            if has('nvim')
              inoremap <silent><expr> <c-space> coc#refresh()
            else
              inoremap <silent><expr> <c-@> coc#refresh()
            endif

            " Make <CR> auto-select the first completion item and notify coc.nvim to
            " format on enter, <cr> could be remapped by other vim plugin
            inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                                          \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

            " Use `[g` and `]g` to navigate diagnostics
            " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
            nmap <silent> [g <Plug>(coc-diagnostic-prev)
            nmap <silent> ]g <Plug>(coc-diagnostic-next)

            " GoTo code navigation.
            nmap <silent> gd <Plug>(coc-definition)
            nmap <silent> gy <Plug>(coc-type-definition)
            nmap <silent> gi <Plug>(coc-implementation)
            nmap <silent> gr <Plug>(coc-references)

            " Use K to show documentation in preview window.
            nnoremap <silent> K :call <SID>show_documentation()<CR>

            function! s:show_documentation()
              if (index(['vim','help'], &filetype) >= 0)
                execute 'h '.expand('<cword>')
              elseif (coc#rpc#ready())
                call CocActionAsync('doHover')
              else
                execute '!' . &keywordprg . " " . expand('<cword>')
              endif
            endfunction

            " Highlight the symbol and its references when holding the cursor.
            autocmd CursorHold * silent call CocActionAsync('highlight')

            " Symbol renaming.
            nmap <leader>rn <Plug>(coc-rename)

            " Formatting selected code.
            xmap <leader>f  <Plug>(coc-format-selected)
            nmap <leader>f  <Plug>(coc-format-selected)

            augroup mygroup
              autocmd!
              " Setup formatexpr specified filetype(s).
              autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
              " Update signature help on jump placeholder.
              autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
            augroup end

            " Applying codeAction to the selected region.
            " Example: `<leader>aap` for current paragraph
            xmap <leader>a  <Plug>(coc-codeaction-selected)
            nmap <leader>a  <Plug>(coc-codeaction-selected)

            " Remap keys for applying codeAction to the current buffer.
            nmap <leader>ac  <Plug>(coc-codeaction)
            " Apply AutoFix to problem on the current line.
            nmap <leader>qf  <Plug>(coc-fix-current)

            " Map function and class text objects
            " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
            xmap if <Plug>(coc-funcobj-i)
            omap if <Plug>(coc-funcobj-i)
            xmap af <Plug>(coc-funcobj-a)
            omap af <Plug>(coc-funcobj-a)
            xmap ic <Plug>(coc-classobj-i)
            omap ic <Plug>(coc-classobj-i)
            xmap ac <Plug>(coc-classobj-a)
            omap ac <Plug>(coc-classobj-a)

            " Remap <C-f> and <C-b> for scroll float windows/popups.
            if has('nvim-0.4.0') || has('patch-8.2.0750')
              nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
              nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
              inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
              inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
              vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
              vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
            endif

            " Use CTRL-S for selections ranges.
            " Requires 'textDocument/selectionRange' support of language server.
            nmap <silent> <C-s> <Plug>(coc-range-select)
            xmap <silent> <C-s> <Plug>(coc-range-select)

            " Add `:Format` command to format current buffer.
            command! -nargs=0 Format :call CocAction('format')

            " Add `:Fold` command to fold current buffer.
            command! -nargs=? Fold :call     CocAction('fold', <f-args>)

            " Add `:OR` command for organize imports of the current buffer.
            command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

            " Add (Neo)Vim's native statusline support.
            " NOTE: Please see `:h coc-status` for integrations with external plugins that
            " provide custom statusline: lightline.vim, vim-airline.
            set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

            " Mappings for CoCList
            " Show all diagnostics.
            nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
            " Manage extensions.
            nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
            " Show commands.
            nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
            " Find symbol of current document.
            nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
            " Search workspace symbols.
            nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
            " Do default action for next item.
            nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
            " Do default action for previous item.
            nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
            " Resume latest coc list.
            nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
        endif
    " }
    " deoplete {
        if count(g:vimde_bundle_groups, 'deoplete')
            " Use deoplete.
            let g:deoplete#enable_at_startup = 1
            " Use smartcase.
            let g:deoplete#enable_smart_case = 1

            set completeopt-=preview
            autocmd FileType javascript set completeopt+=preview
            set completeopt+=menuone

            inoremap <silent><expr> <Tab>
                    \ pumvisible() ? "\<C-n>" :
                    \ deoplete#mappings#manual_complete()
            " use tab to forward cycle
            inoremap <silent><expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
            " use tab to backward cycle
            inoremap <silent><expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
            " Enable omni completion.
            " <C-h>, <BS>: close popup and delete backword char.
            inoremap <expr><C-h> deoplete#mappings#smart_close_popup()."\<C-h>"
            " disable this key mapping because it causes basic vim backspace
            " key functions with error if deoplete not enabled
            inoremap <expr><BS>  deoplete#mappings#smart_close_popup()."\<C-h>"

            " <CR>: close popup and save indent or newline.
            inoremap <silent><expr><CR> pumvisible() ? deoplete#mappings#close_popup() : "\<CR>"
            inoremap <silent><expr><C-e> pumvisible() ? deoplete#undo_completion() : "<End>"
             "inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
            " function! s:my_cr_function()
                " return deoplete#mappings#close_popup() . "\<CR>"
            " endfunction

            " actually, we don't need these settings anymore, omnifunc are
            " managed by deoplete sources automatically
            if !exists('g:deoplete#omni#input_patterns')
                let g:deoplete#omni#input_patterns = {}
            endif
            if !exists('g:deoplete#omni#functions')
                let g:deoplete#omni#functions = {}
            endif
        endif
    " }

    " echodoc {
        "set cmdheight=2
        "let g:echodoc_enable_at_startup = 1
    " }

    " neocomplete {
        if count(g:vimde_bundle_groups, 'neocomplete')
            let g:acp_enableAtStartup = 0
            let g:neocomplete#enable_at_startup = 1
            let g:neocomplete#enable_smart_case = 1
            let g:neocomplete#enable_auto_delimiter = 1
            let g:neocomplete#max_list = 15
            let g:neocomplete#force_overwrite_completefunc = 1


            " Define dictionary.
            let g:neocomplete#sources#dictionary#dictionaries = {
                        \ 'default' : '',
                        \ 'vimshell' : $HOME.'/.vimshell_hist',
                        \ 'scheme' : $HOME.'/.gosh_completions'
                        \ }

            " Define keyword.
            if !exists('g:neocomplete#keyword_patterns')
                let g:neocomplete#keyword_patterns = {}
            endif
            let g:neocomplete#keyword_patterns['default'] = '\h\w*'

            " Plugin key-mappings {
                " These two lines conflict with the default digraph mapping of <C-K>
                if !exists('g:vimde_no_neosnippet_expand')
                    imap <C-k> <Plug>(neosnippet_expand_or_jump)
                    smap <C-k> <Plug>(neosnippet_expand_or_jump)
                endif
                if exists('g:vimde_noninvasive_completion')
                    inoremap <CR> <CR>
                    " <ESC> takes you out of insert mode
                    inoremap <expr> <Esc>   pumvisible() ? "\<C-y>\<Esc>" : "\<Esc>"
                    " <CR> accepts first, then sends the <CR>
                    inoremap <expr> <CR>    pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
                    " <Down> and <Up> cycle like <Tab> and <S-Tab>
                    inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
                    inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
                    " Jump up and down the list
                    inoremap <expr> <C-d>   pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
                    inoremap <expr> <C-u>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"
                else
                    " <C-k> Complete Snippet
                    " <C-k> Jump to next snippet point
                    imap <silent><expr><C-k> neosnippet#expandable() ?
                                \ "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ?
                                \ "\<C-e>" : "\<Plug>(neosnippet_expand_or_jump)")
                    smap <TAB> <Right><Plug>(neosnippet_jump_or_expand)

                    inoremap <expr><C-g> neocomplete#undo_completion()
                    inoremap <expr><C-l> neocomplete#complete_common_string()
                    "inoremap <expr><CR> neocomplete#complete_common_string()

                    " <CR>: close popup
                    " <s-CR>: close popup and save indent.
                    inoremap <expr><s-CR> pumvisible() ? neocomplete#smart_close_popup()."\<CR>" : "\<CR>"

                    function! CleverCr()
                        if pumvisible()
                            if neosnippet#expandable()
                                let exp = "\<Plug>(neosnippet_expand)"
                                return exp . neocomplete#smart_close_popup()
                            else
                                return neocomplete#smart_close_popup()
                            endif
                        else
                            return "\<CR>"
                        endif
                    endfunction

                    " <CR> close popup and save indent or expand snippet
                    imap <expr> <CR> CleverCr()
                    " <C-h>, <BS>: close popup and delete backword char.
                    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
                    inoremap <expr><C-y> neocomplete#smart_close_popup()
                endif
                " <TAB>: completion.
                inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
                inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

                " Courtesy of Matteo Cavalleri

                function! CleverTab()
                    if pumvisible()
                        return "\<C-n>"
                    endif
                    let substr = strpart(getline('.'), 0, col('.') - 1)
                    let substr = matchstr(substr, '[^ \t]*$')
                    if strlen(substr) == 0
                        " nothing to match on empty string
                        return "\<Tab>"
                    else
                        " existing text matching
                        if neosnippet#expandable_or_jumpable()
                            return "\<Plug>(neosnippet_expand_or_jump)"
                        else
                            return neocomplete#start_manual_complete()
                        endif
                    endif
                endfunction

                imap <expr> <Tab> CleverTab()
            " }

            " Enable heavy omni completion.
            if !exists('g:neocomplete#sources#omni#input_patterns')
                let g:neocomplete#sources#omni#input_patterns = {}
            endif
            let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
            let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
            let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
            let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
            let g:neocomplete#sources#omni#input_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
    " }
    " neocomplcache {
        elseif count(g:vimde_bundle_groups, 'neocomplcache')
            let g:acp_enableAtStartup = 0
            let g:neocomplcache_enable_at_startup = 1
            let g:neocomplcache_enable_camel_case_completion = 1
            let g:neocomplcache_enable_smart_case = 1
            let g:neocomplcache_enable_underbar_completion = 1
            let g:neocomplcache_enable_auto_delimiter = 1
            let g:neocomplcache_max_list = 15
            let g:neocomplcache_force_overwrite_completefunc = 1

            " Define dictionary.
            let g:neocomplcache_dictionary_filetype_lists = {
                        \ 'default' : '',
                        \ 'vimshell' : $HOME.'/.vimshell_hist',
                        \ 'scheme' : $HOME.'/.gosh_completions'
                        \ }

            " Define keyword.
            if !exists('g:neocomplcache_keyword_patterns')
                let g:neocomplcache_keyword_patterns = {}
            endif
            let g:neocomplcache_keyword_patterns._ = '\h\w*'

            " Plugin key-mappings {
                " These two lines conflict with the default digraph mapping of <C-K>
                imap <C-k> <Plug>(neosnippet_expand_or_jump)
                smap <C-k> <Plug>(neosnippet_expand_or_jump)
                if exists('g:vimde_noninvasive_completion')
                    inoremap <CR> <CR>
                    " <ESC> takes you out of insert mode
                    inoremap <expr> <Esc>   pumvisible() ? "\<C-y>\<Esc>" : "\<Esc>"
                    " <CR> accepts first, then sends the <CR>
                    inoremap <expr> <CR>    pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
                    " <Down> and <Up> cycle like <Tab> and <S-Tab>
                    inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
                    inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
                    " Jump up and down the list
                    inoremap <expr> <C-d>   pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
                    inoremap <expr> <C-u>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"
                else
                    imap <silent><expr><C-k> neosnippet#expandable() ?
                                \ "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ?
                                \ "\<C-e>" : "\<Plug>(neosnippet_expand_or_jump)")
                    smap <TAB> <Right><Plug>(neosnippet_jump_or_expand)

                    inoremap <expr><C-g> neocomplcache#undo_completion()
                    inoremap <expr><C-l> neocomplcache#complete_common_string()
                    "inoremap <expr><CR> neocomplcache#complete_common_string()

                    function! CleverCr()
                        if pumvisible()
                            if neosnippet#expandable()
                                let exp = "\<Plug>(neosnippet_expand)"
                                return exp . neocomplcache#close_popup()
                            else
                                return neocomplcache#close_popup()
                            endif
                        else
                            return "\<CR>"
                        endif
                    endfunction

                    " <CR> close popup and save indent or expand snippet
                    imap <expr> <CR> CleverCr()

                    " <CR>: close popup
                    " <s-CR>: close popup and save indent.
                    inoremap <expr><s-CR> pumvisible() ? neocomplcache#close_popup()."\<CR>" : "\<CR>"
                    "inoremap <expr><CR> pumvisible() ? neocomplcache#close_popup() : "\<CR>"

                    " <C-h>, <BS>: close popup and delete backword char.
                    inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
                    inoremap <expr><C-y> neocomplcache#close_popup()
                endif
                " <TAB>: completion.
                inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
                inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"
            " }

            " Enable omni completion.
            autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
            autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
            autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
            autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
            autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
            autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
            autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

            " Enable heavy omni completion.
            if !exists('g:neocomplcache_omni_patterns')
                let g:neocomplcache_omni_patterns = {}
            endif
            let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
            let g:neocomplcache_omni_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
            let g:neocomplcache_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
            let g:neocomplcache_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
            let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
            let g:neocomplcache_omni_patterns.go = '\h\w*\.\?'
    " }
    " Normal Vim omni-completion {
    " To disable omni complete, add the following to your .vimrc.before.local file:
    "   let g:vimde_no_omni_complete = 1
        elseif !exists('g:vimde_no_omni_complete')
            " Enable omni-completion.
            autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
            autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
            autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
            autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
            autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
            autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
            autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

        endif
    " }

    " Snippets {
        if count(g:vimde_bundle_groups, 'neocomplcache') ||
                    \ count(g:vimde_bundle_groups, 'neocomplete')

            " Use honza's snippets.
            let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

            " Enable neosnippet snipmate compatibility mode
            let g:neosnippet#enable_snipmate_compatibility = 1

            " For snippet_complete marker.
            if !exists("g:vimde_no_conceal")
                if has('conceal')
                    set conceallevel=2 concealcursor=n " conceal only in normal mode
                endif
            endif

            " Enable neosnippets when using go
            let g:go_snippet_engine = "neosnippet"

            " Disable the neosnippet preview candidate window
            " When enabled, there can be too much visual noise
            " especially when splits are used.
            set completeopt-=preview
        endif

        " remap Ultisnips for compatibility for omnicomplete
        let g:UltiSnipsExpandTrigger       = '<C-j>'
        let g:UltiSnipsJumpForwardTrigger  = '<C-j>'
        let g:UltiSnipsJumpBackwardTrigger = '<C-k>'
        autocmd FileType js UltiSnipsAddFiletypes javascript-es6

        " CompleteParameter.vim {
            "inoremap <silent><expr> ( complete_parameter#pre_complete("()")
            "inoremap <silent><expr><c-j> complete_parameter#pre_complete("()") " doesn't work...
            inoremap <silent><expr><m-j> complete_parameter#pre_complete("()")
            smap <c-j> <Plug>(complete_parameter#goto_next_parameter)
            imap <c-j> <Plug>(complete_parameter#goto_next_parameter)
            smap <c-k> <Plug>(complete_parameter#goto_previous_parameter)
            imap <c-k> <Plug>(complete_parameter#goto_previous_parameter)
        " }

    " }

    " FIXME: Isn't this for Syntastic to handle?
    " Haskell post write lint and check with ghcmod
    " $ `cabal install ghcmod` if missing and ensure
    " ~/.cabal/bin is in your $PATH.
    if !executable("ghcmod")
        autocmd BufWritePost *.hs GhcModCheckAndLintAsync
    endif

    " UndoTree {
        if isdirectory(expand("~/.vim/bundle/undotree/"))
            nnoremap <Leader>u :UndotreeToggle<CR>
            " If undotree is opened, it is likely one wants to interact with it.
            let g:undotree_SetFocusWhenToggle=1
        endif
    " }

    " indent_guides {
        if isdirectory(expand("~/.vim/bundle/vim-indent-guides/"))
            let g:indent_guides_start_level = 2
            let g:indent_guides_guide_size = 1
            let g:indent_guides_enable_on_vim_startup = 1
            hi IndentGuidesOdd  ctermbg=white
        endif
    " }

    " vim-airline {
        " Set configuration options for the statusline plugin vim-airline.
        " Use the powerline theme and optionally enable powerline symbols.
        " To use the symbols , , , , , , and .in the statusline
        " segments add the following to your .vimrc.before.local file:
        "   let g:airline_powerline_fonts=1
        " If the previous symbols do not render for you then install a
        " powerline enabled font.

        " See `:echo g:airline_theme_map` for some more choices
        " Default in terminal vim is 'dark'
        if isdirectory(expand("~/.vim/bundle/vim-airline-themes/"))
            if !exists('g:airline_theme')
                let g:airline_theme = 'solarized'
            endif
            let g:airline#extensions#tabline#enabled         = 1
            let g:airline#extensions#virtualenv#enabled      = 1
            let g:airline#extensions#wordcount#enabled       = 1
            let g:airline#extensions#tabline#buffer_idx_mode = 1
            let g:airline#extensions#syntastic#enabled       = 0
            let g:airline#extensions#neomake#enabled         = 0
            let g:airline#extensions#ycm#enabled             = 1
            let g:airline#extensions#ale#enabled             = 1
            let g:airline#extensions#branch#enabled          = 0
            " show number of search occurrences
            let g:airline_section_error                      = ''
            let g:airline_section_warning                    = ''
            let g:airline_section_z                          = '[%{SearchCount()}]%3p%% %#__accent_bold#%{g:airline_symbols.linenr}%4l%#__restore__#%#__accent_bold#/%L%{g:airline_symbols.maxlinenr}%#__restore__# :%3v'
            if !exists('g:airline_powerline_fonts')
                " Use the default set of separators with a few customizations
                let g:airline_left_sep  = '›'  " Slightly fancier than '>'
                let g:airline_right_sep = '‹' " Slightly fancier than '<'
            endif
        endif
    " }

    " lightline.vim {
        if isdirectory(expand("~/.vim/bundle/vim-airline-themes/"))
            " status line
            let g:lightline = {
                  \ 'colorscheme': 'solarized',
                  \ }
        endif
    " }

    " Python {
        " Disable if python support not present
        if !has('python') && !has('python3')
            let g:pymode = 0
        endif
        autocmd FileType python setlocal makeprg=python

        " highlight
        let python_highlight_all = 1

        if isdirectory(expand("~/.vim/bundle/jedi-vim")) && !count(g:vimde_bundle_groups, 'youcompleteme')
            " using deoplete-vim source for completion, not jedi-vim's omnifunc
            " but using jedi's key mapping
             autocmd FileType python setlocal omnifunc=jedi#completions

            " use make to run the current file
            " disable completion to avoid conflicts with completion engine
            " plugins like YCM and deoplete
            let g:jedi#completions_enabled      = 0
            let g:jedi#auto_vim_configuration   = 0
            let g:jedi#smart_auto_mappings      = 0
            " let g:jedi#show_call_signatures     = 0
            let g:jedi#show_call_signatures     = "1"
            let g:jedi#popup_on_dot             = 0
            let g:jedi#use_tabs_not_buffers     = 1
            "let g:jedi#goto_command             = "<leader>d"
            let g:jedi#goto_command             = "<C-]>"
            let g:jedi#goto_assignments_command = "gd"
            let g:jedi#goto_definitions_command = ""
            let g:jedi#documentation_command    = "K"
            let g:jedi#usages_command           = "<leader>n"
            let g:jedi#completions_command      = "<C-Space>"
            "let g:jedi#rename_command           = "<leader>r"
        endif

        if isdirectory(expand("~/.vim/bundle/python-mode")) && !count(g:vimde_bundle_groups, 'youcompleteme')
            "python-mode
            let g:pymode            = 1
            let g:pymode_python     = 'python3'
            let g:pymode_virtualenv = 1
            "let g:pymode_indent    = []
            let g:pymode_doc        = 0
            " Override view python doc key shortcut to Ctrl-Shift-d
            let g:pymode_doc_bind         = "<C-S-d>"
            let g:pymode_trim_whitespaces = 0
            let g:pymode_options          = 0
            let g:pymode_run              = 1
            "let g:pymode_run_bind         = '<leader>r'
            let g:pymode_breakpoint_cmd   = ''
            let g:pymode_lint_on_fly      = 1
            "if using neomake, then disable pymode lint
            "let g:pymode_lint_checkers = ['pylint', 'pyflakes', 'pep8', 'mccabe']
            "let g:pymode_lint_checkers = ['pylama', 'pylint']
            let g:pymode_lint_checkers = []
            let g:pymode_lint_ignore = ""

            let g:pymode_rope = 1
            " disable completion to avoid conflicts with YCM
            let g:pymode_rope_completion             = 0
            " Override go-to.definition key shortcut to Ctrl-]
            let g:pymode_rope_goto_definition_bind   = "<C-]>"
            let g:pymode_rope_goto_definition_cmd    = 'tabnew'
            let g:pymode_rope_autoimport             = 1
            let g:pymode_rope_autoimport_modules     = ['os', 'shutil', 'datetime']
            let g:pymode_rope_organize_imports_bind  = '<C-c>ro'
            let g:pymode_rope_autoimport_bind        = '<C-c>ra'
            let g:pymode_rope_module_to_package_bind = '<C-c>r1p'
            let g:pymode_rope_extract_method_bind    = '<C-c>rm'
            let g:pymode_rope_extract_variable_bind  = '<C-c>rl'
            let g:pymode_rope_rename_bind            = '<C-c>rr'
        endif
    " }

    " javascript {
        if count(g:vimde_bundle_groups, 'javascript')
            if isdirectory(expand("~/.vim/bundle/tern_for_vim")) && !count(g:vimde_bundle_groups, 'youcompleteme')
                " User tern_for_vim for javascript completion
                "autocmd FileType javascript,jsx,javascript.jsx setlocal omnifunc=tern#Complete
                let g:tern_show_argument_hints   = 'on_hold'
                let g:tern_show_signature_in_pum = 1
                autocmd FileType javascript,jsx,javascript.jsx  nnoremap <C-]> :TernDef<CR>
                autocmd FileType javascript,jsx,javascript.jsx  nnoremap <S-K> :TernDoc<CR>
            endif
            "vim-jsx
            let g:jsx_ext_required    = 0 " Allow JSX in normal JS files
            "let g:jsx_pragma_required = 1

            let g:tern_show_signature_in_pum = '0'  " This do disable full signature type on autocomplete

            "Add extra filetypes
            let g:tern#filetypes = [
                            \ 'javascript',
                            \ 'jsx',
                            \ 'javascript.jsx',
                            \ 'vue',
                            \ ]
        endif
    " }

    " rust {

        " rust.vim
         let g:rustfmt_autosave = 1

        " deoplete-rust
        "let g:deoplete#sources#rust#racer_binary     = "$(which racer)"
        let g:deoplete#sources#rust#racer_binary     = $HOME.'/.cargo/bin/racer'
        "let g:deoplete#sources#rust#rust_source_path = $RUST_SRC_PATH.'/'
    " }

    " C, CPP {
        " STL header file type detection
        "au BufRead * if search('\M-*- C++ -*-', 'nw') | setlocal ft=cpp | endif
        au BufRead * if search('\M-*- C++ -*-', 'n', '1') | setlocal ft=cpp | endif " only search first line
        " clang_complete
        let g:clang_use_library                        = 1
        let g:clang_library_path                       = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib"
        let g:clang_complete_auto                      = 0
        let g:clang_complete_optional_args_in_snippets = 1
        let g:clang_snippets                           = 1
        let g:clang_snippets_engine                    = "ultisnips"
        let g:clang_user_options                       = '-std=c++11 -stdlib=libc++'

        " vim-inccomplete, not needed anymore
        " let g:inccomplete_showdirs             = 1
        " let g:deoplete#omni#input_patterns.cpp = ['[^. *\t]\.\w*', '[^. *\t]\::\w*', '[^. *\t]\->\w*', '[<"].*/']
        " Add the last one, otherwise `<../` and `"../` won't trigger omnifunc

        " deoplete-clang
        let g:deoplete#sources#clang#libclang_path = "/Library/Developer/CommandLineTools/usr/lib/libclang.dylib"
        let g:deoplete#sources#clang#clang_header  = "/Library/Developer/CommandLineTools/usr/lib/clang"
        " vim-clang (not installed yet)
        let g:clang_c_options                          = '-std=gnu11'
        let g:clang_cpp_options                        = '-std=c++11 -stdlib=libc++'
    " }

    " GoLang {
        if count(g:vimde_bundle_groups, 'go')
            let g:go_highlight_functions         = 1
            let g:go_highlight_methods           = 1
            let g:go_highlight_structs           = 1
            let g:go_highlight_operators         = 1
            let g:go_highlight_build_constraints = 1
            let g:go_fmt_command                 = "goimports"
            let g:syntastic_go_checkers          = ['golint', 'govet', 'errcheck']
            let g:syntastic_mode_map             = { 'mode': 'active', 'passive_filetypes': ['go'] }
            " vim-go
            au FileType go nmap <Leader>s <Plug>(go-implements)
            au FileType go nmap <Leader>i <Plug>(go-info)
            au FileType go nmap <Leader>e <Plug>(go-rename)
            "au FileType go nmap <leader>r <Plug>(go-run)
            au FileType go nmap <leader>b <Plug>(go-build)
            au FileType go nmap <leader>t <Plug>(go-test)
            au FileType go nmap <Leader>gd <Plug>(go-doc)
            au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
            au FileType go nmap <leader>co <Plug>(go-coverage)

            " deoplete-go
            let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
            "let g:deoplete#sources#go#cgo           = 1
        endif
    " }

    " Swift {
        " landaire/deoplete-swift
        " Jump to the first placeholder by typing `<C-j>`.
        autocmd FileType swift imap <buffer> <C-j> <Plug>(deoplete_swift_jump_to_placeholder)
    " }

    " markdown {
        "plugin vim-markdown
        let g:vim_markdown_folding_disabled = 1
        let g:vim_markdown_math             = 1
        autocmd FileType markdown set conceallevel=2 concealcursor=n
        au FileType markdown au BufEnter set conceallevel=2 concealcursor=n

        " vim-livedown{
            " should markdown preview get shown automatically upon opening markdown buffer
            let g:livedown_autorun = 1

            " should the browser window pop-up upon previewing
            let g:livedown_open = 1

            " the port on which Livedown server will run
            let g:livedown_port = 1337

            " the browser to use
            "let g:livedown_browser = "safari"
        " }

        " prevent indentLine overwrite
        let g:indentLine_setConceal = 0
    " }

    " lua {
        let g:lua_check_syntax = 0
        let g:lua_complete_omni = 1
        let g:lua_complete_dynamic = 0
        let g:lua_define_completion_mappings = 0

        "let g:deoplete#omni#functions.lua = 'xolox#lua#omnifunc'
        "let g:deoplete#omni#functions.lua = 'xolox#lua#completefunc'

    " }

    " java {
        if isdirectory(expand("~/.vim/bundle/vim-javacomplete2"))
            autocmd FileType java setlocal omnifunc=javacomplete#Complete

            nmap <F4> <Plug>(JavaComplete-Imports-Add)
            imap <F4> <Plug>(JavaComplete-Imports-Add)

        endif
    " }

    " swift {
        if count(g:vimde_bundle_groups, 'deoplete')
            " Jump to the first placeholder by typing `<C-j>`.
            autocmd FileType swift imap <buffer> <C-j> <Plug>(deoplete_swift_jump_to_placeholder)
        endif
    " }

    " vim-move {
        "let g:move_map_keys = 0
        let g:move_key_modifier = 'A'
        " FIXME: map <A-key> not working for Alt modifier, directly type
        " Alt+key would do the trick
        "vmap <A-j> <Plug>MoveBlockDown
        "vmap <A-k> <Plug>MoveBlockUp
        "nmap ∆ <Plug>MoveLineDown
        nmap <M-j> <Plug>MoveLineDown " XXX: <M> is Alt modifier
        "nmap ˚ <Plug>MoveLineUp " <A-K>, i.e. Alt+K
        nmap <M-k> <Plug>MoveLineUp " <A-K>, i.e. Alt+K
        vmap ∆ <Plug>MoveBlockDown
        vmap ˚ <Plug>MoveBlockUp " <A-K>, i.e. Alt+K
    " }

    " vim-startify {
        if isdirectory(expand("~/.vim/bundle/vim-startify/"))
            "nmap <leader>sl :SessionList<CR>
            nmap <leader>ss :SSave<CR>
            nmap <leader>sc :SClose<CR>

            if has('nvim')
                    "au! TabNewEntered * Startify

            endif
            "let g:startify_list_order = [
                    "\ 'sessions',
                    "\ 'dir',
                    "\ 'files',
                    "\ ]
        endif
    " }

    " Wildfire {
    let g:wildfire_objects =
                \ {
                \ "*" : ["i'", 'i"', "i)", "i]", "i}", "ip"],
                \ "html,xml" : ["at"],
                \ }
    " }
" }

" GUI Settings {

    " GVIM- (here instead of .gvimrc)
    if has('gui_running')
        set guioptions-=T           " Remove the toolbar
        set lines=40                " 40 lines of text instead of 24
        if !exists("g:vimde_no_big_font")
            if LINUX() && has("gui_running")
                set guifont=Andale\ Mono\ Regular\ 12,Menlo\ Regular\ 11,Consolas\ Regular\ 12,Courier\ New\ Regular\ 14
            elseif OSX() && has("gui_running")
                set guifont=Andale\ Mono\ Regular:h12,Menlo\ Regular:h11,Consolas\ Regular:h12,Courier\ New\ Regular:h14
            elseif WINDOWS() && has("gui_running")
                set guifont=Andale_Mono:h10,Menlo:h10,Consolas:h10,Courier_New:h10
            endif
        endif
    else
        if &term == 'xterm' || &term == 'screen'
            set t_Co=256            " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
        elseif &term == 'nvim'
            set t_Co=256            " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
        endif
        "set term=builtin_ansi       " Make arrow and other keys work
    endif

" }

" Functions {

    " Initialize directories {
    function! InitializeDirectories()
        let parent = $HOME
        let prefix = 'vim'
        let dir_list = {
                    \ 'backup': 'backupdir',
                    \ 'views': 'viewdir',
                    \ 'swap': 'directory' }

        if has('persistent_undo')
            let dir_list['undo'] = 'undodir'
        endif

        " To specify a different directory in which to place the vimbackup,
        " vimviews, vimundo, and vimswap files/directories, add the following to
        " your .vimrc.before.local file:
        "   let g:vimde_consolidated_directory = <full path to desired directory>
        "   eg: let g:vimde_consolidated_directory = $HOME . '/.vim/'
        if exists('g:vimde_consolidated_directory')
            let common_dir = g:vimde_consolidated_directory . prefix
        else
            let common_dir = parent . '/.' . prefix
        endif

        for [dirname, settingname] in items(dir_list)
            let directory = common_dir . dirname . '/'
            if exists("*mkdir")
                if !isdirectory(directory)
                    call mkdir(directory)
                endif
            endif
            if !isdirectory(directory)
                echo "Warning: Unable to create backup directory: " . directory
                echo "Try: mkdir -p " . directory
            else
                let directory = substitute(directory, " ", "\\\\ ", "g")
                exec "set " . settingname . "=" . directory
            endif
        endfor
    endfunction
    call InitializeDirectories()
    " }

    " Initialize NERDTree as needed {
    function! NERDTreeInitAsNeeded()
        redir => bufoutput
        buffers!
        redir END
        let idx = stridx(bufoutput, "NERD_tree")
        if idx > -1
            NERDTreeMirror
            NERDTreeFind
            wincmd l
        endif
    endfunction
    " }

    " Strip whitespace {
    function! StripTrailingWhitespace()
        " Preparation: save last search, and cursor position.
        let _s=@/
        let l = line(".")
        let c = col(".")
        " do the business:
        %s/\s\+$//e
        " clean up: restore previous search history, and cursor position
        let @/=_s
        call cursor(l, c)
    endfunction
    " }

    " Shell command {
    function! s:RunShellCommand(cmdline)
        botright new

        setlocal buftype=nofile
        setlocal bufhidden=delete
        setlocal nobuflisted
        setlocal noswapfile
        setlocal nowrap
        setlocal filetype=shell
        setlocal syntax=shell

        call setline(1, a:cmdline)
        call setline(2, substitute(a:cmdline, '.', '=', 'g'))
        execute 'silent $read !' . escape(a:cmdline, '%#')
        setlocal nomodifiable
        1
    endfunction

    command! -complete=file -nargs=+ Shell call s:RunShellCommand(<q-args>)
    " e.g. Grep current file for <search_term>: Shell grep -Hn <search_term> %
    " }

    function! s:IsSpf13Fork()
        let s:is_fork = 0
        let s:fork_files = ["~/.vimrc.fork", "~/.vimrc.before.fork", "~/.vimrc.bundles.fork"]
        for fork_file in s:fork_files
            if filereadable(expand(fork_file, ":p"))
                let s:is_fork = 1
                break
            endif
        endfor
        return s:is_fork
    endfunction

    function! s:ExpandFilenameAndExecute(command, file)
        execute a:command . " " . expand(a:file, ":p")
    endfunction

    function! s:EditSpf13Config()
        if has('nvim')
            call <SID>ExpandFilenameAndExecute("tabedit", "~/.config/nvim/init.vim")
        else
            call <SID>ExpandFilenameAndExecute("tabedit", "~/.vimrc")
        endif
        call <SID>ExpandFilenameAndExecute("vsplit", "~/.vimrc.before")
        call <SID>ExpandFilenameAndExecute("vsplit", "~/.vimrc.bundles")

        execute bufwinnr(".vimrc") . "wincmd w"
        call <SID>ExpandFilenameAndExecute("split", "~/.vimrc.local")
        wincmd l
        call <SID>ExpandFilenameAndExecute("split", "~/.vimrc.before.local")
        wincmd l
        call <SID>ExpandFilenameAndExecute("split", "~/.vimrc.bundles.local")

        if <SID>IsSpf13Fork()
            execute bufwinnr(".vimrc") . "wincmd w"
            call <SID>ExpandFilenameAndExecute("split", "~/.vimrc.fork")
            wincmd l
            call <SID>ExpandFilenameAndExecute("split", "~/.vimrc.before.fork")
            wincmd l
            call <SID>ExpandFilenameAndExecute("split", "~/.vimrc.bundles.fork")
        endif

        execute bufwinnr(".vimrc.local") . "wincmd w"
    endfunction

    execute "noremap " . s:vimde_edit_config_mapping " :call <SID>EditSpf13Config()<CR>"
    if has('nvim')
        execute "noremap " . s:vimde_apply_config_mapping . " :source ~/.config/nvim/init.vim<CR>"
    else
        execute "noremap " . s:vimde_apply_config_mapping . " :source ~/.vimrc<CR>"
    endif
" }

" Use fork vimrc if available {
    if filereadable(expand("~/.vimrc.fork"))
        source ~/.vimrc.fork
    endif
" }

" Use local vimrc if available {
    if filereadable(expand("~/.vimrc.local"))
        source ~/.vimrc.local
    endif
" }

" Use local gvimrc if available and gui is running {
    if has('gui_running')
        if filereadable(expand("~/.gvimrc.local"))
            source ~/.gvimrc.local
        endif
    endif
" }

" update this repository {
    function! UpdateSelf()
        !cd ~/.vimde && git pull
        PlugUpdate
    endfunction

    " FIXME: cmap doesn't work...
    "cmap UpdateSelf <C-R>=UpdateSelf()<CR>
    "cmap <expr> UpdateSelf UpdateSelf()
    command! UpdateSelf call UpdateSelf()
" }
