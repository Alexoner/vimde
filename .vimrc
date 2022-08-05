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
        source ~/.vimde/.vimrc.before
    endif
" }

" Use bundles config {
    if filereadable(expand("~/.vimde/.vimrc.bundles"))
        source ~/.vimde/.vimrc.bundles
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

    " syntax settings, to mitigate some performance issue with large files
    set cursorline!
    set lazyredraw
    set synmaxcol=128
    syntax sync minlines=256

    function! IsWSL()
      if has("unix")
        let lines = readfile("/proc/version")
        if lines[0] =~ "microsoft"
            " echo "WINDOWS SUBSYSTEM LINUX!"
          return 1
        endif
      endif
      return 0
    endfunction

    if IsWSL()
        " WSL yank support
        let s:clip = '/mnt/c/Windows/System32/clip.exe'  " change this path according to your mount point
        if executable(s:clip)
            augroup WSLYank
                autocmd!
                autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
            augroup END
        endif

        " may still need to remove xclip from Linux to work.
        let g:clipboard = {
                \   'name': 'WslClipboard',
                \   'copy': {
                \      '+': 'clip.exe',
                \      '*': 'clip.exe',
                \    },
                \   'paste': {
                \      '+': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                \      '*': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                \   },
                \   'cache_enabled': 0,
                \ }
    elseif exists('$TMUX')
        let g:clipboard = {
            \   'name': 'myClipboard',
            \   'copy': {
            \      '+': 'tmux load-buffer -',
            \      '*': 'tmux load-buffer -',
            \    },
            \   'paste': {
            \      '+': 'tmux save-buffer -',
            \      '*': 'tmux save-buffer -',
            \   },
            \   'cache_enabled': 1,
            \ }
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
   "
    " highlighting popup menu {
        " fg: font foregroud, bg: backround, cterm: colorful term; Pmenu: popup menu,
        " PmenuSel: selected item,
        hi Pmenu  guifg=#000000 guibg=#F8F8F8 ctermfg=black ctermbg=Lightgray
        hi PmenuSel cterm=bold ctermfg=239 ctermbg=1 gui=bold guifg=#504945 guibg=#83a598
        hi PmenuSbar  guifg=#8A95A7 guibg=#F8F8F8 gui=NONE ctermfg=darkcyan ctermbg=lightgray cterm=NONE
        hi PmenuThumb  guifg=#F8F8F8 guibg=#8A95A7 gui=NONE ctermfg=lightgray ctermbg=darkcyan cterm=NONE
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
    " set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
    " set listchars=tab:¦\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
    set listchars=tab:▸\ ,trail:•,eol:¬,extends:#,nbsp:.  " Highlight problematic whitespace
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
    set smartindent
    set smarttab                    " 
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
    autocmd FileType c,cpp,objc,objcpp setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
    autocmd FileType haskell,puppet,ruby,yml,helm,javascript,jsx,javascript.jsx,html,xhtml,xml,css,json setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
    "autocmd FileType go autocmd BufWritePre <buffer> Fmt
    autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
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
    command Ccp let @+ = expand("%:p") " Copy current File full Path into unnamedplus register
    command Ccn let @+ = expand("%") " just filename
    " relative path
    " :let @+ = expand("%")

    " WSL(Windows subsystem for Linux) support
    if system('uname -r') =~ "Microsoft"
        command! Ccp call system(s:clip, expand("%:p")) " command! to override previously defined commands
        command! Ccn call system(s:clip, expand("%:t")) " command! to override previously defined commands
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

    " change square brackets [] to curly brackets {}
    " vnoremap <silent> <leader>b :'<,'>s/\[/{/g | '<,'>s/]/}/g<CR>
    " map to multiple :commands: use pipe with <bar>
    " do multiple substitution in visual block: substitute, gv to se
    vnoremap <silent> <leader>{ :s/\[/{/g<CR> gv :s/]/}/g<CR>
    " FIXME: below doesn't work as expected
    vnoremap <silent> <leader>[ :s/{/[/g<CR> gv :s/}/]/g<CR>
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

    " coc.nvim {
        " Conquer of Completion, language server leveraging VSCode plugins
        if count(g:vimde_bundle_groups, 'coc.nvim')

            if filereadable(expand("~/.vimde/conf.d/.vimrc.coc.nvim"))
                source ~/.vimde/conf.d/.vimrc.coc.nvim
            endif

            if filereadable(expand("~/.vimde/conf.d/.vimrc.coc-snippets"))
                source ~/.vimde/conf.d/.vimrc.coc-snippets
            endif

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
    " }

    lua << EOF
    require("nvim-tree.main")
EOF
    "{
        map <leader>e :NvimTreeFindFile<CR>
        nmap <leader>nt :NvimTreeToggle<CR>
    "}


    " NerdTree {
        if isdirectory(expand("~/.vim/bundle/nerdtree"))
            "map <C-e> <plug>NERDTreeTabsToggle<CR>
            " map <leader>e :NERDTreeFind<CR>
            " nmap <leader>nt :NERDTreeFind<CR>

            let NERDTreeWinSize          = 60
            let NERDTreeShowBookmarks    = 1
            let NERDTreeIgnore           = ['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$', '.DS_Store']
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
            "
            " xmap a <Plug>(EasyAlign)
            " vmap a <Plug>(EasyAlign)


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

    " {
    " ctrp, deprecated
    " }


    " Syntastic {
    " deprecated
    " }

    " YouCompleteMe {
        if count(g:vimde_bundle_groups, 'youcompleteme')

            if filereadable(expand("~/.vimde/conf.d/.vimrc.youcompleteme"))
                source ~/.vimde/conf.d/.vimrc.youcompleteme
            endif

        endif
    " }

    " echodoc {
        "set cmdheight=2
        "let g:echodoc_enable_at_startup = 1
    " }

    "neocomplete {
    " ...
    "}

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
        " if isdirectory(expand("~/.vim/bundle/indentLine/"))
        
            " prevent indentLine overwrite
            " let g:indentLine_setConceal = 0

            let g:indentLine_defaultGroup = 'SpecialKey'
            let g:indentLine_char = '|'
            let g:indentLine_char_list = ['|', '¦', '┆', '┊']

            " Vim
            let g:indentLine_color_term = 239

            " GVim
            if has('gui_running')
                let g:indentLine_color_gui = '#A4E57E'
            endif

            " none X terminal
            let g:indentLine_color_tty_light = 7 " (default: 4)
            let g:indentLine_color_dark = 1 " (default: 2)

            " Background (Vim, GVim)
            if has('gui_running')
                let g:indentLine_bgcolor_term = 202
                let g:indentLine_bgcolor_gui = '#FF5F00'
            endif

        " endif
        
    " }

    " vim-airline {
        if filereadable(expand("~/.vimde/conf.d/.vimrc.vim-airline"))
            source ~/.vimde/conf.d/.vimrc.vim-airline
        endif
    " }
    
    " lightline.vim {
        if filereadable(expand("~/.vimde/conf.d/.vimrc.lightline.vim"))
            source ~/.vimde/conf.d/.vimrc.lightline.vim
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
        " python-mode, jedi, deprecated in favor of coc.nvim
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
            " vim-go not used

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

        " markdown-preview.nvim {
            if filereadable(expand("~/.vimde/conf.d/.vimrc.markdown-preview.nvim"))
                source ~/.vimde/conf.d/.vimrc.markdown-preview.nvim
            endif
        " }

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
        source ~/.vimde/.vimrc.fork
    endif
" }

" Use local vimrc if available {
    if filereadable(expand("~/.vimrc.local"))
        source ~/.vimde/.vimrc.local
    endif
" }

" Use local gvimrc if available and gui is running {
    if has('gui_running')
        if filereadable(expand("~/.gvimrc.local"))
            source ~/.vimde/.gvimrc.local
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
