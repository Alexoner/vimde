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
/home/haodu/.vim/bundle/vim-polyglot/syntax/log.vim
90:syn match logXmlEntity       /\&\w\+;/
139:hi def link logXmlEntity Special
```

In a brutal way, we can just comment the line 90 in the specific file, then problem is solved.


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

Then get sorted time costs:

```shell
cat vim.profile|grep -i 'total time'|sort -k3,3 -r |less
```
Find the most time consuming plugins, extensions.
