if exists('g:loaded_choosy') | finish | endif

" {{{1 Command
command! -nargs=* -complete=command Choosy call choosy#choosewin_command(<f-args>)

" {{{1 Default options
if get(g:, 'choosy_key_winnr', v:false)
	let g:choosy_options = extend(
				\ get(g:, 'choosy_options', {}),
				\ {'key': {info -> string(info.win.winnr)}},
				\ 'keep')
endif

if get(g:, 'choosy_color_popups', v:false)
	if has('gui')
		let g:choosy_hilist = []
		let i = 1
		for hex in [
					\ '#ff0000', '#ff8000', '#ffff00', '#80ff00',
					\ '#00ff00', '#00ff80', '#00ffff', '#0080ff',
					\ '#0000ff', '#8000ff', '#ff00ff', '#ff0080']
			execute 'hi ChoosyPopup' . i . ' guibg=' . hex . ' guifg=black gui=bold'
			call add(g:choosy_hilist, 'ChoosyPopup' . i)
			let i += 1
		endfor
	else
		let g:choosy_hilist = get(g:, 'choosy_hilist',
					\ ['ErrMsg', 'WarningMsg', 'CursorLineNr', 'Directory',
					\ 'DiffText', 'Folded', 'FoldColumn'])
	endif
	let g:choosy_popup_options = extend(
				\ get(g:, 'choosy_popup_options', {}),
				\ {
				\ 'highlight':       {info ->  g:choosy_hilist[info.win.winnr-1]},
				\ 'borderhighlight': {info -> [g:choosy_hilist[info.win.winnr-1]]},
				\ },
				\ 'keep')
endif


" {{{1 Example mappings

" {{{2 <Plug> mappings
"Switch to chosen window
nnoremap <silent> <Plug>(choosy-switch) :Choosy {win.winnr}wincmd w<cr>

"Split chosen window horizontally or vertically
nnoremap <silent> <Plug>(choosy-hsplit) :Choosy call win_execute({win.winid}, "sp")<cr>
nnoremap <silent> <Plug>(choosy-vsplit) :Choosy call win_execute({win.winid}, "vs")<cr>

"Close chosen window
nnoremap <silent> <Plug>(choosy-close) :Choosy {win.winnr}wincmd c<cr>

"'Duplicate' current buffer to another window and move to that window
nnoremap <silent> <Plug>(choosy-duplicate-buffer) :Choosy {win.winnr}wincmd w {bar} buffer {srcbuf.bufnr}<cr>


"Swap current and chosen window buffers {{{3
function! ChoosySwap(vars) abort
	execute "buffer " . a:vars.buf.bufnr
	call win_execute(a:vars.win.winid, "buffer " . a:vars.srcbuf.bufnr)
	if !get(a:vars.opts, 'stay', v:false)
		execute a:vars.win.winnr . 'wincmd w'
	endif
endfunction
nnoremap <silent> <Plug>(choosy-swap) :call choosy#choosewin('ChoosySwap')<cr>
nnoremap <silent> <Plug>(choosy-swap-stay) :call choosy#choosewin('ChoosySwap', #{stay:v:true})<cr>

"The swap functions can also be implemented without a function:
"nnoremap <silent> <Plug>(choosy-swap) :Choosy buffer {buf.bufnr} {bar} {win.winnr}wincmd w {bar} buffer {srcbuf.bufnr}<cr>
"nnoremap <silent> <Plug>(choosy-swap-stay) :Choosy buffer {buf.bufnr} {bar} call win_execute({win.winid}, "buffer {srcbuf.bufnr}")<cr>


"Use Choosy with NERDTree {{{3
if exists('g:NERDTree')
	function! ChoosyNERDTree(vars) abort
		let l:node = g:NERDTreeFileNode.GetSelected()
		if l:node.path.isDirectory | return | endif

		let l:cmd = get(a:vars.opts, 'cmd', 'edit')
		call win_execute(a:vars.win.winid,
					\ l:cmd . ' ' . l:node.path.str({'format': 'Edit'}))

		if nerdtree#closeTreeOnOpen() | call g:NERDTree.Close() | endif
	endfunction
	nnoremap <silent> <Plug>(choosy-nerdtree-open)  :call choosy#choosewin('ChoosyNERDTree')<cr>
	nnoremap <silent> <Plug>(choosy-nerdtree-hopen) :call choosy#choosewin('ChoosyNERDTree', #{cmd:'sp'})<cr>
	nnoremap <silent> <Plug>(choosy-nerdtree-vopen) :call choosy#choosewin('ChoosyNERDTree', #{cmd:'vs'})<cr>
endif


"Default <leader> mappings {{{2
if !get(g:, 'choosy_no_mappings', v:false)
	nmap <silent> -           <Plug>(choosy-switch)
	nmap <silent> <leader>cwh <Plug>(choosy-hsplit)
	nmap <silent> <leader>cwv <Plug>(choosy-vsplit)
	nmap <silent> <leader>cwc <Plug>(choosy-close)
	nmap <silent> <leader>cws <Plug>(choosy-swap)
	nmap <silent> <leader>cwS <Plug>(choosy-swap-stay)
	nmap <silent> <leader>cwD <Plug>(choosy-duplicate-buffer)
endif

if exists('g:NERDTree') && !get(g:, 'choosy_no_nerdtree_mappings', v:false)
	augroup ChoosyNERDTree
		au!
		au FileType nerdtree nmap <silent> <leader>cow <Plug>(choosy-nerdtree-open)
		au FileType nerdtree nmap <silent> <leader>coh <Plug>(choosy-nerdtree-hopen)
		au FileType nerdtree nmap <silent> <leader>cov <Plug>(choosy-nerdtree-vopen)
	augroup END
endif

let g:loaded_choosy = 1
" vim:fdm=marker:fdl=0:ts=2
