" https://github.com/itchyny/lightline.vim

let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste'  ],
      \             [ 'readonly', 'filename', 'modified', 'charvaluehex'  ] ]
      \ },
      \ 'component': {
      \   'charvaluehex': '0x%B'
      \ },
      \ }

highlight IsModified    ctermbg=red
highlight IsNotModified ctermbg=green
