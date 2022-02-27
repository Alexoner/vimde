if isdirectory(expand("~/.vim/bundle/ctrlp.vim/"))

	" FIXME: conflicts with digraph
	"inoremap <silent><expr> ( complete_parameter#pre_complete("()")
	"inoremap <silent><expr><c-j> complete_parameter#pre_complete("()") " doesn't work...
	inoremap <silent><expr><m-j> complete_parameter#pre_complete("()")
	smap <c-j> <Plug>(complete_parameter#goto_next_parameter)
	imap <c-j> <Plug>(complete_parameter#goto_next_parameter)
	smap <c-k> <Plug>(complete_parameter#goto_previous_parameter)
	imap <c-k> <Plug>(complete_parameter#goto_previous_parameter)

endif
