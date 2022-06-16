Improve VIM performance

## Profiling vim startup time

    nvim --startuptime start.txt

## Fix slow scrolling in vim

reference: https://eduncan911.com/software/fix-slow-scrolling-in-vim-and-neovim.html

Profiling syntax time with `syntime` (when synx is slow):
```vim
:syntime on " then move around
" after moving around, report the profile
:syntime report
```

In the report, you will see statistics like this:
```text
  TOTAL      COUNT  MATCH   SLOWEST     AVERAGE   NAME               PATTERN
 99.409365   3010   432     1.261013    0.033026  logXmlEntity       \&\w\+;
  0.123857   2578   0       0.007106    0.000048  logDate            \(\(Mon\|Tue\|Wed\|Thu\|Fri\|Sat\|Sun\) \)\?\(Jan\|Feb\|Mar\|Apr\|May\|Jun\|Jul\|Aug\|Sep\|Oct\|Nov\|Dec\) [0-9 ]\d
  0.047088   2578   0       0.001418    0.000018  logDomain          \v(^|\s)(\w|-)+(\.(\w|-)+)+\s
  0.038096   3723   1566    0.000409    0.000010  logUUID            \w\{8}-\w\{4}-\w\{4}-\w\{4}-\w\{12}
  0.034865   3808   1443    0.001703    0.000009  logFilePath        [^a-zA-Z0-9"']\@<=\/\w[^\n|,; ()'"\]{}]\+
  0.028783   11193  9453    0.000294    0.000003  logOperator        [;,\?\:\.\<=\>\~\/\@\&\!$\%\&\+\-\|\^(){}\*#]
  0.021265   2578   0       0.002118    0.000008  logMD5             \<[a-z0-9]\{32}\>
  0.020206   2578   0       0.000490    0.000008  logIPV6            \<\x\{1,4}\(:\x\{1,4}\)\{7}\>
  0.018780   3202   728     0.000247    0.000006  logIPV4            \<\d\{1,3}\(\.\d\{1,3}\)\{3}\>
  0.018253   5526   3697    0.000121    0.000003  logFloatNumber     \<\d.\d\+[eE]\?\>
  0.016740   3528   1703    0.000227    0.000005  logNumber          \<-\?\d\+\>
  0.015917   2683   318     0.000328    0.000006  logDate            \d\{2,4}[-\/]\(\d\{2}\|Jan\|Feb\|Mar\|Apr\|May\|Jun\|Jul\|Aug\|Sep\|Oct\|Nov\|Dec\)[-\/]\d\{2,4}T\?
  0.015867   2578   0       0.000126    0.000006  logFilePath        \<\w:\\[^\n|,; ()'"\]{}]\+
  0.015751   2578   0       0.000118    0.000006  logMacAddress      \<\x\{2}\(:\x\{2}\)\{5}
  0.014779   4243   2414    0.000174    0.000003  logHexNumber       \<\d\x\+\>
  0.014255   2578   0       0.000256    0.000006  logBrackets        [\[\]]
  0.014056   2998   633     0.000099    0.000005  logUrl             http[s]\?:\/\/[^\n|,; '"]\+
  0.012822   2578   0       0.000116    0.000005  logTime            \d\{2}:\d\{2}:\d\{2}\(\.\d\{2,6}\)\?\(\s\?[-+]\d\{2,4}\|Z\)\?\>
  0.010585   2578   0       0.000094    0.000004  logEmptyLines      =\{3,}
  0.010214   2578   0       0.000549    0.000004  logEmptyLines      -\{3,}
  0.009426   2578   0       0.000100    0.000004  logEmptyLines      \*\{3,}
  0.001354   2578   0       0.000079    0.000001  logHexNumber       \<0[xX]\x\+\>
  0.001327   105    105     0.000059    0.000013  logString          $
  0.001318   2578   0       0.000063    0.000001  logBinaryNumber    \<0[bB][01]\+\>
  0.000970   2578   0       0.000056    0.000000  logDate            ^20\d\{6}
  0.000757   2998   420     0.000013    0.000000  logString          '\(s \|t \| \w\)\@!
  0.000623   2578   0       0.000004    0.000000  logXmlCData        <!\[CDATA\[.*\]\]>
  0.000585   2578   0       0.000078    0.000000  logEmptyLines      - -
  0.000386   2578   0       0.000114    0.000000  logString          "
  0.000279   2578   0       0.000028    0.000000  logXmlHeader       <?\(\w\|-\)\+\(\s\+\w\+\(="[^"]*"\|='[^']*'\)\?\)*?>
  0.000256   2578   0       0.000011    0.000000  logXmlTag          <\/\?\(\(\w\|-\)\+:\)\?\(\w\|-\)\+\(\(\n\|\s\)\+\(\(\w\|-\)\+:\)\?\(\w\|-\)\+\(="[^"]*"\|='[^']*'\)\?\)*\s*\/\?>
  0.000246   2578   0       0.000012    0.000000  logXmlDoctype      <!DOCTYPE[^>]*>
  0.000245   2578   0       0.000001    0.000000  logXmlComment      <!--
  0.000111   105    0       0.000002    0.000001  logString          s
  0.000055   105    105     0.000002    0.000001  logString          '
  0.000013   105    0       0.000000    0.000000  logString          \\.

 99.919495   101470
```
Now, the name `logXmlEntity` consumes most of time. But we don't know which plugin causes this.

Do *SEARCH IN TEXT*!
```shell
ag 'logXmlEntity' ~/.vim/bundle
```
After doing `text search`, we found the culprit:

```text
~/.vim/bundle/vim-polyglot/syntax/log.vim
90:syn match logXmlEntity       /\&\w\+;/
139:hi def link logXmlEntity Special
```

In a brutal way, we can just comment the line 90 in the specific file, or just disable the plugin, then problem is solved.

```vim
set cursorline!
set lazyredraw
set synmaxcol=128
syntax sync minlines=256
```


## Profiling runtime performance of plugins

Reference: https://stackoverflow.com/questions/12213597/how-to-see-which-plugins-are-making-vim-slow?answertab=active#tab-top

```vim
:profile start vim.profile
:profile func *
:profile file *
" At this point do slow operations
:profile dump
:profile pause

```

Sample content
```text
FUNCTION  sy#start()
    Defined: ~/.vim/bundle/vim-signify/autoload/sy.vim line 7
Called 25 times
Total time:   7.443873
 Self time:   0.214259

count  total (s)   self (s)
   25              0.000058   if g:signify_locked
                                call sy#verbose('Locked.')
                                return
   25              0.000052   endif
                            
   25              0.000175   let bufnr = a:0 && has_key(a:1, 'bufnr') ? a:1.bufnr : bufnr('')
   25              0.000126   let sy = getbufvar(bufnr, 'sy')
                            
   25              0.000056   if empty(sy)
    1   0.019030   0.000015     let path = s:get_path(bufnr)
    1   0.009387   0.000027     if s:skip(bufnr, path)
                                  call sy#verbose('Skip file: '. path)
                                  return
    1              0.000000     endif
    1   0.000043   0.000024     call sy#verbose('Register new file: '. path)
    1   0.004916   0.004852     let new_sy = { 'path':       path, 'buffer':     bufnr, 'detecting':  0, 'vcs':        [], 'hunks':      [], 'signid':     0x100, 'updated_by': '', 'stats':      [-1, -1, -1], 'info':       {    'dir':  fnamemodify(path, ':p:h'),    'path': sy#util#escape(path),    'file': sy#util#escape(fnamemodify(path, ':t')) }}
    1              0.000011     call setbufvar(bufnr, 'sy', new_sy)
    1   0.000802   0.000011     call sy#set_buflocal_autocmds(bufnr)
    1   0.009517   0.000033     call sy#repo#detect(bufnr)
   24              0.000187   elseif has('vim_starting')
                                call sy#verbose("Don't run Sy more than once during startup.")
                                return
   24              0.000018   else
   24   7.016266   0.000400     let path = s:get_path(bufnr)
   24              0.201131     if !filereadable(path)
                                  call sy#stop()
                                  return

FUNCTIONS SORTED ON TOTAL TIME
count  total (s)   self (s)  function
   25   7.443873   0.214259  sy#start()
   25   7.034880             <SNR>210_get_path()
    9   1.437161   0.000176  nerdtree#ui_glue#invokeKeyMap()
    9   1.436985   0.000822  79()
  881   1.360072   1.350915  <SNR>209_parse_screen()
    9   1.226106   0.000233  78()
    6   0.893418   0.000094  <SNR>67_customOpenDir()
    6   0.893092   0.000090  <SNR>67_activateDirNode()
    6   0.892019   0.000177  136()
    6   0.697042   0.000091  170()
    5   0.695272   0.000141  159()
    9   0.688980   0.000383  158()
    6   0.675053   0.001586  156()
   47   0.609598   0.002821  35()
   47   0.602849   0.304622  37()
  212   0.547341   0.415978  134()
 1600   0.400291   0.235017  airline#check_mode()
 1477   0.365474   0.206023  airline#extensions#hunks#get_hunks()
 1485   0.329073             SearchCount()
    1   0.326914   0.000022  <SNR>67_customOpenFile()

FUNCTIONS SORTED ON SELF TIME
count  total (s)   self (s)  function
   25              7.034880  <SNR>210_get_path()
  881   1.360072   1.350915  <SNR>209_parse_screen()
  212   0.547341   0.415978  134()
 1485              0.329073  SearchCount()
   47   0.602849   0.304622  37()
   95              0.299347  36()
   12   0.289146   0.286383  150()
 1600   0.400291   0.235017  airline#check_mode()
   25   7.443873   0.214259  sy#start()
 1477   0.365474   0.206023  airline#extensions#hunks#get_hunks()
   22   0.183317   0.178078  sy#repo#get_diff()
14787              0.135653  airline#util#winwidth()
10339              0.126365  airline#util#append()
 1003   0.133277   0.125144  <SNR>120_notify()
  922              0.107019  <SNR>142_Highlight_Matching_Pair()
    1   0.317199   0.103677  16()
 5135   0.128203   0.096371  30()
 3732              0.088881  <SNR>160_get_syn()
 8910              0.067991  airline#util#prepend()
  933   0.158121   0.064426  airline#highlighter#get_highlight()

```

Then get sorted time costs:

```shell
cat vim.profile|grep -i 'total time'|sort -k3,3 -r |less
```
Find the most time consuming plugins, extensions.
