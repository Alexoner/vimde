# vimde: Vim Development Environment


                        _
                __   __(_)_ __ ___
                \ \ / /| | '_ ` _ \
                 \ V / | | | | | | |
                  \_/  |_|_| |_| |_|


vimde is a distribution of vim plugins and resources for Neovim, Vim, Gvim and [MacVim].

It is a good starting point for anyone intending to use VIM for development running equally well on Windows, Linux, \*nix and Mac.

The distribution is completely customisable using a `~/.vimrc.local`, `~/.vimrc.bundles.local`, and `~/.vimrc.before.local` Vim RC files.

![vimde image][vimde-img]

Unlike traditional VIM plugin structure, which similar to UNIX throws all files into common directories, making updating or disabling plugins a real mess, vimde 3 uses the [Vundle] plugin management system to have a well organized vim directory (Similar to mac's app folders). Vundle also ensures that the latest versions of your plugins are installed and makes it easy to keep them up to date.

Great care has been taken to ensure that each plugin plays nicely with others, and optional configuration has been provided for what we believe is the most efficient use.

Lastly (and perhaps, most importantly) It is completely cross platform. It works well on Windows, Linux and OSX without any modifications or additional configurations. If you are using [MacVim] or Gvim additional features are enabled. So regardless of your environment just clone and run.

# Installation
## Requirements
To make all the plugins work, specifically asynchronous plugins like [vim-plug](https://github.com/junegunn/vim-plug), you need [Neovim](https://github.com/neovim/neovim).

## Linux, \*nix, Mac OSX Installation

The easiest way to install vimde is to use our [automatic installer](https://raw.githubusercontent.com/Alexoner/vimde/3.0/bootstrap.sh) by simply copying and pasting the following line into a terminal. This will install vimde and backup your existing vim configuration.

*Requires Git 1.7+ and Vim 7.3+*

On Linux:
```bash
sudo apt install neovim        # install neovim, recommended
sudo apt-get install ripgrep   # fast grep
```

```bash
    # for Mac OSX with homebrew
    brew install neovim/neovim/neovim
    pip3 install neovim && pip2 install neovim

    curl https://raw.githubusercontent.com/Alexoner/vimde/master/bootstrap.sh -L > vimde.sh && sh vimde.sh
```

If you have a bash-compatible shell you can run the script directly:
```bash

    sh <(curl https://raw.githubusercontent.com/Alexoner/vimde/master/bootstrap.sh -L)
```

## Installing on Windows

On Windows and \*nix [Git] and [Curl] are required. Also, if you haven't done so already, you'll need to install [Vim].
The quickest option to install all three dependencies ([Git], [Curl], [Vim] and [vimde]) is via [Chocolatey] NuGet. After installing [Chocolatey], execute the following commands on the _command prompt_:

    C:\> choco install vimde

_Note: The [vimde package] will install Vim also!_

If you want to install [msysgit], [Curl] and [vimde] individually, follow the directions below.

### Installing dependencies

#### Install [Vim]

After the installation of Vim you must add a new directory to your environment variables path to make it work with the script installation of vimde.

Open Vim and write the following command, it will show the installed directory:

    :echo $VIMRUNTIME
    C:\Program Files (X86)\Vim\vim74

Then you need to add it to your environment variable path. After that try execute `vim` within command prompt (press Win-R, type `cmd`, press Enter) and you’ll see the default vim page.

#### Install [msysgit]

After installation try running `git --version` within _command prompt_ (press Win-R,  type `cmd`, press Enter) to make sure all good:

    C:\> git --version
    git version 1.7.4.msysgit.0

#### Setup [Curl]
_Instructions blatently copied from vundle readme_
Installing Curl on Windows is easy as [Curl] is bundled with [msysgit]!
But before it can be used with [Vundle] it's required make `curl` run in _command prompt_.
The easiest way is to create `curl.cmd` with [this content](https://gist.github.com/912993)

    @rem Do not use "echo off" to not affect any child calls.
    @setlocal

    @rem Get the abolute path to the parent directory, which is assumed to be the
    @rem Git installation root.
    @for /F "delims=" %%I in ("%~dp0..") do @set git_install_root=%%~fI
    @set PATH=%git_install_root%\bin;%git_install_root%\mingw\bin;%PATH%

    @if not exist "%HOME%" @set HOME=%HOMEDRIVE%%HOMEPATH%
    @if not exist "%HOME%" @set HOME=%USERPROFILE%

    @curl.exe %*


And copy it to `C:\Program Files\Git\cmd\curl.cmd`, assuming [msysgit] was installed to `c:\Program Files\Git`

to verify all good, run:

    C:\> curl --version
    curl 7.21.1 (i686-pc-mingw32) libcurl/7.21.1 OpenSSL/0.9.8k zlib/1.2.3
    Protocols: dict file ftp ftps http https imap imaps ldap ldaps pop3 pop3s rtsp smtp smtps telnet tftp
    Features: Largefile NTLM SSL SSPI libz


#### Installing vimde on Windows

The easiest way is to download and run the vimde-windows-install.cmd file. Remember to run this file in **Administrator Mode** if you want the symlinks to be created successfully.

## Updating to the latest version
The simpliest (and safest) way to update is to run customized vim command ':UpdateSelf'. It will completely and non destructively upgrade to the latest version.

    vim +UpdateSelf +qall

Or you can simply rerun the installer.

    curl https://raw.githubusercontent.com/Alexoner/vimde/master/bootstrap.sh -L -o - | sh


Alternatively you can manually perform the following steps. If anything has changed with the structure of the configuration you will need to create the appropriate symlinks.

```bash
    cd $HOME/to/vimde/
    git pull
    vim +PlugInstall! +PlugClean +q
```

### Fork me on GitHub

This distribution started as a fork of spf13-vim.
I'm always happy to take pull requests from others. A good number of people are already [contributors] to [vimde]. Go ahead to fork and customize.

## Installing fonts

### Unicode support

To display unicode symbols like: ¦.

	sudo apt install fonts-noto


### Install NerdFont

[NerdFont](https://www.nerdfonts.com/).

## For WSL

- Use [Windows Terminal].
- choose font `DroidSans Mono`
- [webinstall.dev](https://webinstall.dev/nerdfont/)


# A highly optimized .vimrc config file

![vimderc image][vimderc-img]

The .vimrc file is suited to programming. It is extremely well organized and folds in sections.
Each section is labeled and each option is commented.

It fixes many of the inconveniences of vanilla vim including

 * A single config can be used across Windows, Mac and linux
 * Eliminates swap and backup files from littering directories, preferring to store in a central location.
 * Fixes common typos like :W, :Q, etc
 * Setup a solid set of settings for Formatting (change to meet your needs)
 * Setup the interface to take advantage of vim's features including
   * omnicomplete
   * line numbers
   * syntax highlighting
   * A better ruler & status line
   * & more
 * Configuring included plugins

## Customization

Create `~/.vimrc.local` and `~/.gvimrc.local` for any local
customizations.

For example, to override the default color schemes:

```bash
    echo colorscheme ir_black  >> ~/.vimrc.local
```

### Before File

Create a `~/.vimrc.before.local` file to define any customizations
that get loaded *before* the vimde `.vimrc`.

For example, to prevent autocd into a file directory:
```bash
    echo let g:vimde_no_autochdir = 1 >> ~/.vimrc.before.local
```
For a list of available vimde specific customization options, look at the `~/.vimrc.before` file.


### Fork Customization

There is an additional tier of customization available to those who want to maintain a
fork of vimde specialized for a particular group. These users can create `.vimrc.fork`
and `.vimrc.bundles.fork` files in the root of their fork.  The load order for the configuration is:

1. `.vimrc.before` - vimde before configuration
2. `.vimrc.before.fork` - fork before configuration
3. `.vimrc.before.local` - before user configuration
4. `.vimrc.bundles` - vimde bundle configuration
5. `.vimrc.bundles.fork` - fork bundle configuration
6. `.vimrc.bundles.local` - local user bundle configuration
6. `.vimrc` - vimde vim configuration
7. `.vimrc.fork` - fork vim configuration
8. `.vimrc.local` - local user configuration

See `.vimrc.bundles` for specifics on what options can be set to override bundle configuration. See `.vimrc.before` for specifics
on what options can be overridden. Most vim configuration options should be set in your `.vimrc.fork` file, bundle configuration
needs to be set in your `.vimrc.bundles.fork` file.

You can specify the default bundles for your fork using `.vimrc.before.fork` file. Here is how to create an example `.vimrc.before.fork` file
in a fork repo for the default bundles.
```bash
    echo let g:vimde_bundle_groups=[\'general\', \'programming\', \'misc\', \'youcompleteme\'] >> .vimrc.before.fork
```
Once you have this file in your repo, only the bundles you specified will be installed during the first installation of your fork.

You may also want to update your `README.markdown` file so that the `bootstrap.sh` link points to your repository and your `bootstrap.sh`
file to pull down your fork.

For an example of a fork of vimde that provides customization in this manner see [taxilian's fork](https://github.com/taxilian/vimde).

### Easily Editing Your Configuration

`<Leader>ev` opens a new tab containing the .vimrc configuration files listed above. This makes it easier to get an overview of your
configuration and make customizations.

`<Leader>sv` sources the .vimrc file, instantly applying your customizations to the currently running vim instance.

These two mappings can themselves be customized by setting the following in .vimrc.before.local:
```bash
let g:vimde_edit_config_mapping='<Leader>ev'
let g:vimde_apply_config_mapping='<Leader>sv'
```
# Key mapping

## `<leader>`
`<leader>` is mapped to ','.

## Fast tab navigation
- `alt+h/l`: previous/next tab

## switch buffer easily
- `tab/shift+tab`: next/previous buffer

## fuzzy find
- `ctrl+p`: fuzzy find git files
- `ctrl+alt+p`: fuzzy find files in current directory

## highlight words
`<leader>k`

# Plugins

vimde contains a curated set of popular vim plugins, colors, snippets and syntaxes. Great care has been made to ensure that these plugins play well together and have optimal configuration.

## Adding new plugins

Create `~/.vimrc.bundles.local` for any additional bundles.

To add a new bundle, just add one line for each bundle you want to install. The line should start with the word "Plug" followed by a string of either the vim.org project name or the githubusername/githubprojectname. For example, the github project [xxx/yyy](https://github.com/xxx/yyy) can be added with the following command

```bash
    echo Plug \'xxx/yyy\' >> ~/.vimrc.bundles.local
```

Once new plugins are added, they have to be installed.

```bash
    vim +PlugInstall! +PlugClean +q
```

<!--## Removing (disabling) an included plugin-->

<!--Create `~/.vimrc.local` if it doesn't already exist.-->

<!--Add the UnBundle command to this line. It takes the same input as the Plug line, so simply copy the line you want to disable and add 'Un' to the beginning.-->

<!--For example, disabling the 'AutoClose' and 'scrooloose/syntastic' plugins-->

<!---->
    <!--echo UnBundle \'AutoClose\' >> ~/.vimrc.bundles.local-->
    <!--echo UnBundle \'scrooloose/syntastic\' >> ~/.vimrc.bundles.local-->
<!---->

<!--**Remember to run ':PlugClean!' after this to remove the existing directories**-->


Here are a few of the plugins:

## [vim-plug](https://github.com/junegunn/vim-plug)
Minimalist Vim Plugin Manager

![image](https://raw.githubusercontent.com/junegunn/i/master/vim-plug/installer.gif)

## [YouCompleteMe]

YouCompleteMe is another amazing completion engine. It is slightly more involved to set up as it contains a binary component that the user needs to compile before it will work. As a result of this however it is very fast.

To enable YouCompleteMe add `youcompleteme` to your list of groups by overriding it in your `.vimrc.before.local` like so: `let g:vimde_bundle_groups=['general', 'programming', 'misc', 'scala', 'youcompleteme']` This is just an example. Remember to choose the other groups you want here.

Once you have done this you will need to get Vundle to grab the latest code from git. You can do this by calling `:PlugInstall!`. You should see YouCompleteMe in the list.

You will now have the code in your bundles directory and can proceed to compile the core. Change to the directory it has been downloaded to. If you have a vanilla install then `cd ~/.vimde-3/.vim/bundle/YouCompleteMe/` should do the trick. You should see a file in this directory called install.sh. There are a few options to consider before running the installer:

  * Do you want clang support (if you don't know what this is then you likely don't need it)?
    * Do you want to link against a local libclang or have the installer download the latest for you?
  * Do you want support for c# via the omnisharp server?

The plugin is well documented on the site linked above. Be sure to give that a read and make sure you understand the options you require.

For java users wanting to use eclim be sure to add `let g:EclimCompletionMethod = 'omnifunc'` to your .vimrc.local.

To generate compilation database file for YouCompleteMe to parse, refer to [bear](https://github.com/rizsotto/Bear).

For example, using `scons`:

    bear scons -uj`nproc` .

If you run into linking error, you can skip that submodule by compiling it without bear, then compile incrementally with `bear`.


## [ale](https://github.com/w0rp/ale)
Asynchronous lint engine.

## [fzf.vim](https://github.com/junegunn/fzf.vim)
Blazing fast fuzzy finder!
**QuickStart** Launch using `<c-p>`.


## [NERDTree]

NERDTree is a file explorer plugin that provides "project drawer"
functionality to your vim editing.  You can learn more about it with
`:help NERDTree`.

**QuickStart** Launch using `<Leader>e`.

**Customizations**:

* Use `<C-E>` to toggle NERDTree
* Use `<leader>e` or `<leader>nt` to load NERDTreeFind which opens NERDTree where the current file is located.
* Hide clutter ('\.pyc', '\.git', '\.hg', '\.svn', '\.bzr')
* Treat NERDTree more like a panel than a split.

## [Undotree]

If you undo changes and then make a new change, in most editors the changes you undid are gone forever, as their undo-history is a simple list.
Since version 7.0 vim uses an undo-tree instead. If you make a new change after undoing changes, a new branch is created in that tree.
Combined with persistent undo, this is nearly as flexible and safe as git ;-)

Undotree makes that feature more accessible by creating a visual representation of said undo-tree.

**QuickStart** Launch using `<Leader>u`.

## [Abolish](https://github.com/tpope/vim-abolish)
Want to turn `fooBar` into `foo_bar`?  Press `crs` (coerce to
snake\_case).  MixedCase (`crm`), camelCase (`crc`), snake\_case
(`crs`), UPPER\_CASE (`cru`), dash-case (`cr-`), dot.case (`cr.`),
space case (`cr<space>`), and Title Case (`crt`) are all just 3
keystrokes away.  These commands support
[repeat.vim](https://github.com/tpope/vim-repeat).

## [ctrlp]
DEPRECATED, in favor of fzf.vim.
Ctrlp replaces the Command-T plugin with a 100% viml plugin. It provides an intuitive and fast mechanism to load files from the file system (with regex and fuzzy find), from open buffers, and from recently used files.

**QuickStart** Launch using `<c-p>`.


## [Surround]

This plugin is a tool for dealing with pairs of "surroundings."  Examples
of surroundings include parentheses, quotes, and HTML tags.  They are
closely related to what Vim refers to as text-objects.  Provided
are mappings to allow for removing, changing, and adding surroundings.

Details follow on the exact semantics, but first, consider the following
examples.  An asterisk (*) is used to denote the cursor position.

      Old text                  Command     New text ~
      "Hello *world!"           ds"         Hello world!
      [123+4*56]/2              cs])        (123+456)/2
      "Look ma, I'm *HTML!"     cs"<q>      <q>Look ma, I'm HTML!</q>
      if *x>3 {                 ysW(        if ( x>3 ) {
      my $str = *whee!;         vllllS'     my $str = 'whee!';

For instance, if the cursor was inside `"foo bar"`, you could type
`cs"'` to convert the text to `'foo bar'`.

There's a lot more, check it out at `:help surround`

## [NERDCommenter]

NERDCommenter allows you to wrangle your code comments, regardless of
filetype. View `help :NERDCommenter` or checkout my post on [NERDCommenter](http://vimde.com/post/vim-plugins-nerd-commenter).

**QuickStart** Toggle comments using `<Leader>c<space>` in Visual or Normal mode.

## [neocomplete]

Neocomplete is an amazing autocomplete plugin with additional support for snippets. It can complete simulatiously from the dictionary, buffer, omnicomplete and snippets. This is the one true plugin that brings Vim autocomplete on par with the best editors.

**QuickStart** Just start typing, it will autocomplete where possible

**Customizations**:

 * Automatically present the autocomplete menu
 * Support tab and enter for autocomplete
 * `<C-k>` for completing snippets using [Neosnippet](https://github.com/Shougo/neosnippet.vim).

![neocomplete image][autocomplete-img]

## [deoplete.nvim]
Deprecated.

Auto-completion engine

<!--## [deoplete-jedi]-->

<!--Auto-completion engine source for python-->

<!--## [deoplete-ternjs]-->

<!--Auto-completion engine source for javascript-->

<!--## [deoplete-rust]-->

<!--Auto-completion engine source for rust-->

<!--## [deoplete-go]-->

<!--Auto-completion engine source for go-->

<!--## [deoplete-clang]-->

<!--Auto-completion engine source for clang, but *YouCompleteMe* is recommended.-->

## [Syntastic]

Syntastic is a syntax checking plugin that runs buffers through external syntax
checkers as they are saved and opened. If syntax errors are detected, the user
is notified and is happy because they didn't have to compile their code or
execute their script to find them.

## [Neomake]
Deprecated, in favor of ale

`:Neomake` to run lint code

## [vim-quickrun]

`<leader>r` to run

## [auto-pairs]

Automatically insert pairs, such as '', "", (), [], {}

## [AutoClose]

AutoClose does what you expect. It's simple, if you open a bracket, paren, brace, quote,
etc, it automatically closes it. It handles curlys correctly and doesn't get in the
way of double curlies for things like jinja and twig.

## [Fugitive]

Fugitive adds pervasive git support to git directories in vim. For more
information, use `:help fugitive`

Use `:Gstatus` to view `git status` and type `-` on any file to stage or
unstage it. Type `p` on a file to enter `git add -p` and stage specific
hunks in the file.

Use `:Gdiff` on an open file to see what changes have been made to that
file

**QuickStart** `<leader>gs` to bring up git status

**Customizations**:

 * `<leader>gs` :Gstatus<CR>
 * `<leader>gd` :Gdiff<CR>
 * `<leader>gc` :Gcommit<CR>
 * `<leader>gb` :Gblame<CR>
 * `<leader>gl` :Glog<CR>
 * `<leader>gp` :Git push<CR>
 * `<leader>gw` :Gwrite<CR>
 * :Git ___ will pass anything along to git.

    ![fugitive image][fugitive-img]

## [livedown](https://github.com/shime/vim-livedown)
Preview markdown instantly.

<!--## [PIV]-->

<!--The most feature complete and up to date PHP Integration for Vim with proper support for PHP 5.3+ including latest syntax, functions, better fold support, etc.-->

<!--PIV provides:-->

 <!--* PHP 5.3 support-->
 <!--* Auto generation of PHP Doc (,pd on (function, variable, class) definition line)-->
 <!--* Autocomplete of classes, functions, variables, constants and language keywords-->
 <!--* Better indenting-->
 <!--* Full PHP documentation manual (hit K on any function for full docs)-->

<!--![php vim itegration image][phpmanual-img]-->

## [Ack.vim]

Ack.vim uses ack to search inside the current directory for a pattern.
You can learn more about it with `:help Ack`

**QuickStart** :Ack

## [Tabularize]

Tabularize lets you align statements on their equal signs and other characters

**Customizations**:

 * `<Leader>a= :Tabularize /=<CR>`
 * `<Leader>a: :Tabularize /:<CR>`
 * `<Leader>a:: :Tabularize /:\zs<CR>`
 * `<Leader>a, :Tabularize /,<CR>`
 * `<Leader>a<Bar> :Tabularize /<Bar><CR>`

## [Tagbar]

vimde includes the Tagbar plugin. This plugin requires exuberant-ctags and will automatically generate tags for your open files. It also provides a panel to navigate easily via tags

**QuickStart** `CTRL-]` while the cursor is on a keyword (such as a function name) to jump to its definition.

**Customizations**: vimde binds `<Leader>tt` to toggle the tagbar panel

![tagbar image][tagbar-img]

**Note**: For full language support, run `brew install ctags` to install
exuberant-ctags.

**Tip**: Check out `:help ctags` for information about VIM's built-in
ctag support. Tag navigation creates a stack which can traversed via
`Ctrl-]` (to find the source of a token) and `Ctrl-T` (to jump back up
one level).

## [EasyMotion]

EasyMotion provides an interactive way to use motions in Vim.

It quickly maps each possible jump destination to a key allowing very fast and
straightforward movement.

**QuickStart** EasyMotion is triggered using the normal movements, but prefixing them with `<leader><leader>`

For example this screen shot demonstrates pressing `,,w`

![easymotion image][easymotion-img]

## [Airline]

Airline provides a lightweight themable statusline with no external dependencies. By default this configuration uses the symbols `‹` and `›` as separators for different statusline sections but can be configured to use the same symbols as [Powerline]. An example first without and then with powerline symbols is shown here:

![airline image][airline-img]

To enable powerline symbols first install one of the [Powerline Fonts] or patch your favorite font using the provided instructions. Configure your terminal, MacVim, or Gvim to use the desired font. Finally add `let g:airline_powerline_fonts=1` to your `.vimrc.before.local`.

## [vim-autoformat]
In normal mode, press`<F3>` to format.

## Additional Syntaxes

vimde ships with a few additional syntaxes:

* Markdown (bound to \*.markdown, \*.md, and \*.mk)
* Twig
* Git commits (set your `EDITOR` to `mvim -f`)

## Amazing Colors

vimde includes [solarized] and [vimde vim color pack](https://github.com/vimde/vim-colors/):

* NeoSolarized
* flattened_dark/flattened_light
* gruvbox
* ir_black
* molokai
* peaksea

Use `:color molokai` to switch to a color scheme.

Terminal Vim users will benefit from solarizing their terminal emulators and setting solarized support to 16 colors:

    let g:solarized_termcolors=16
    color NeoSolarized

Terminal emulator colorschemes:

* http://ethanschoonover.com/solarized (iTerm2, Terminal.app)
* https://github.com/phiggins/konsole-colors-solarized (KDE Konsole)
* https://github.com/sigurdga/gnome-terminal-colors-solarized (Gnome Terminal)

### [NeoSolarized](https://github.com/iCyMind/NeoSolarized)
The solarized color scheme that works in terminal, without having to change terminal color scheme, really!


## Snippets

It also contains a very complete set of [snippets](https://github.com/vimde/snipmate-snippets) for use with snipmate or [neocomplete].


# Intro to VIM

Here's some tips if you've never used VIM before:

## Tutorials

* Type `vimtutor` into a shell to go through a brief interactive
  tutorial inside VIM.
* Read the slides at [VIM: Walking Without Crutches](https://walking-without-crutches.heroku.com/#1).

## Modes

* VIM has two (common) modes:
  * insert mode- stuff you type is added to the buffer
  * normal mode- keys you hit are interpreted as commands
* To enter insert mode, hit `i`
* To exit insert mode, hit `<ESC>`

## Useful commands

* Use `:q` to exit vim
* Certain commands are prefixed with a `<Leader>` key, which by default maps to `\`.
  vimde uses `let mapleader = ","` to change this to `,` which is in a consistent and
  convenient location.
* Keyboard [cheat sheet](http://www.viemu.com/vi-vim-cheat-sheet.gif).

[![Analytics](https://ga-beacon.appspot.com/UA-7131036-5/vimde/readme)](https://github.com/igrigorik/ga-beacon)
[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/vimde/vimde/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

# Tune vim for better experience
## Accessing system clipboard
- `set clipboard=unnamedplus`
- (Optional) Configure `tmux` to use system clipboard
- Install `xsel` and make sure `DISPLAY` variable is set correctly

## Profiling vim startup time

    nvim --startuptime start.txt  # or
	time vim --startuptime start.log +:q
	cat start.log|less

The time stamp indicates when the specific plugin is done loading.
For example if `python3.vim` is slow to load, set `let g:python3_host_prog='python'` in vimrc
will let the python provider skip detecting usable python to speed up loading.


[Git]:http://git-scm.com
[Curl]:http://curl.haxx.se
[Neovim]:https://neovim.io
[Vim]:http://www.vim.org/download.php#pc
[msysgit]:http://msysgit.github.io
[Chocolatey]: http://chocolatey.org/
[vimde package]: https://chocolatey.org/packages/vimde
[MacVim]:http://code.google.com/p/macvim/
[vimde]:https://github.com/alexoner/vimde
[contributors]:https://github.com/alexoner/vimde/contributors

[Vundle]:https://github.com/gmarik/vundle
[PIV]:https://github.com/vimde/PIV
[NERDCommenter]:https://github.com/scrooloose/nerdcommenter
[Undotree]:https://github.com/mbbill/undotree
[NERDTree]:https://github.com/scrooloose/nerdtree
[ctrlp]:https://github.com/kien/ctrlp.vim
[eugen0329/vim-esearch]:https://github.com/eugen0329/vim-esearch
[solarized]:https://github.com/altercation/vim-colors-solarized
[neocomplete]:https://github.com/shougo/neocomplete
[Fugitive]:https://github.com/tpope/vim-fugitive
[Surround]:https://github.com/tpope/vim-surround
[Tagbar]:https://github.com/majutsushi/tagbar
[Neomake]:https://github.com/neomake/neomake
[auto-pairs]:https://github.com/jiangmiao/auto-pairs
[vim-quickrun]:https://github.com/thinca/vim-quickrun
[Syntastic]:https://github.com/scrooloose/syntastic
[vim-easymotion]:https://github.com/Lokaltog/vim-easymotion
[deoplete.nvim]:https://github.com/Shougo/deoplete.nvim
[deoplete-jedi]:https://github.com/zchee/deoplete-jedi
[deoplete-ternjs]:https://github.com/carlitux/deoplete-ternjs
[deoplete-rust]:https://github.com/sebastianmarkow/deoplete-rust
[deoplete-go]:https://github.com/zchee/deoplete-go
[deoplete-clang]:https://github.com/zchee/deoplete-clang
[deoplete-padawan]:https://github.com/pbogut/deoplete-padawan
[YouCompleteMe]:https://github.com/Valloric/YouCompleteMe
[Matchit]:http://www.vim.org/scripts/script.php?script_id=39
[Tabularize]:https://github.com/godlygeek/tabular
[EasyMotion]:https://github.com/Lokaltog/vim-easymotion
[Airline]:https://github.com/bling/vim-airline
[Powerline]:https://github.com/lokaltog/powerline
[Powerline Fonts]:https://github.com/Lokaltog/powerline-fonts
[AutoClose]:https://github.com/vimde/vim-autoclose
[Ack.vim]:https://github.com/mileszs/ack.vim
[vim-autoformat]:https://github.com/Chiel92/vim-autoformat
[romainl/flattened]:https://github.com/romainl/flattened
[iCyMind/NeoSolarized]:https://github.com/iCyMind/NeoSolarized

[vimde-img]:./vimde.png
[vimderc-img]:https://i.imgur.com/kZWj1.png
[autocomplete-img]:https://i.imgur.com/90Gg7.png
[tagbar-img]:https://i.imgur.com/cjbrC.png
[fugitive-img]:https://i.imgur.com/4NrxV.png
[nerdtree-img]:https://i.imgur.com/9xIfu.png
[phpmanual-img]:https://i.imgur.com/c0GGP.png
[easymotion-img]:https://i.imgur.com/ZsrVL.png
[airline-img]:https://i.imgur.com/D4ZYADr.png
