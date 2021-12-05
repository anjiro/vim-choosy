let s:default_opts = #{
			\ skip_unlisted: v:false,
			\ include_self:  v:false,
			\ skip_names:    [],
			\ debug:         v:false,
			\ }


function! choosy#choosewin_command(...) abort " {{{1
	"Called by :Choosy. Parses args; only works with those found in
	" s:default_opts. Assumes the rest of the line is an ex command.
	let l:opts = copy(s:default_opts)
	let l:args = copy(a:000)

	"Argument processing
	while !empty(l:args) && l:args[0][0] ==# '-'
		let l:arg = remove(l:args, 0)
		let l:argname = l:arg[1:]
		if has_key(l:opts, l:argname)
			if type(l:opts[l:argname]) ==# v:t_bool
				let l:opts[l:argname] = !l:opts[l:argname]
			elseif type(l:opts[l:argname]) ==# v:t_list
				let l:opts[l:argname] = split(remove(l:args, 0), '\s*,\s*')
			endif
		endif
	endwhile

	let l:callback = join(l:args)
	call s:debug("choosewin_command() callback: " . l:callback, l:opts.debug)

	"Force callback to be interpreted as an ex command
	call choosy#choosewin((l:callback[0] ==# ':' ? '' : ':') . l:callback, l:opts)
endfunction


" }}}1
function! choosy#choosewin(callback='', opts={}, popup_opts={}) abort " {{{1
	let l:opts = copy(s:default_opts)
	call extend(l:opts, get(g:, 'choosy_options', {}))
	call extend(l:opts, a:opts)

	let l:popup_opts = #{
			\ highlight:       'ModeMsg',
			\ padding:         [1, 3, 1, 3],
			\ borderhighlight: ['Question'],
			\ }
	call extend(l:popup_opts, get(g:, 'choosy_popup_options', {}))
	call extend(l:popup_opts, a:popup_opts)

  "Set defaults for padding & border if empty
  for l:v in ['padding', 'border']
    if empty(get(l:popup_opts, l:v, []))
      let l:popup_opts[l:v] = [1,1,1,1]
    endif
  endfor

	let s:popups = {}
	let s:callback = a:callback

	call s:debug('choosewin() callback arg: ' . s:callback, l:opts.debug)

	let l:i = 0
	for l:win in filter(getwininfo(), {_,w ->
				\ w.tabnr == tabpagenr() && 
				\ (l:opts.include_self ? v:true : w.winid != win_getid())
				\ })
		let l:buf = getbufinfo(l:win.bufnr)[0]
		
		let l:skip = l:opts.skip_unlisted && !l:buf.listed
		for l:pattern in l:opts.skip_names
			let l:skip = l:skip || match(l:buf.name, l:pattern) >= 0
		endfor
		if l:skip | continue | endif

    let l:info = #{
					\ win:   l:win,
					\ buf:   l:buf,
					\ opts:  l:opts,
					\ }

    "Calculate size: padding and border are above/right/below/left 
    let l:padding = s:getval(l:popup_opts.padding, l:info)
    let l:border  = s:getval(l:popup_opts.border,  l:info)
    let l:pop_w = 1 + l:padding[1] + l:padding[3]
    let l:pop_h = 1 + l:padding[0] + l:padding[2]

    let l:popts = copy(l:popup_opts)->extend(#{
          \ col:    l:win.wincol + l:win.width  / 2 - l:pop_w / 2,
          \ line:   l:win.winrow + l:win.height / 2 - l:pop_h / 2,
          \ filter: 'choosy#choosewin_filter',
          \ })->map({k,v -> s:getval(v, l:info)})
    let l:key = s:getval(get(l:opts, 'key', nr2char(l:i + 65)), l:info)
    let l:info.popid = popup_create(l:key, l:popts)
		let s:popups[tolower(l:key)] = l:info
		let l:i += 1
	endfor
endfunction


" }}}1
function! choosy#choosewin_filter(winid, key) abort " {{{1
	"Fix vim/vim/issues/6424 (mouse movement) if unpatched
	if a:key ==# "\x80\xfd\d" | return v:false | endif  

	"Close popups first
	for l:popinfo in values(s:popups)
		call popup_close(l:popinfo.popid)
	endfor

	if s:popups->has_key(tolower(a:key))
		if empty(s:callback) || s:callback =~# '^:\s*$'
			echom "Chose window:" s:popups[a:key]
			let g:choosy_wininfo = s:popups[a:key]
		elseif type(s:callback) ==# v:t_func
			call s:callback(s:popups[a:key])
		elseif type(s:callback) ==# v:t_string
			if s:callback[0] ==# ':'
				let l:cmd = substitute(s:callback[1:], '{bar}', '|', 'g')
				let l:cmd = substitute(
							\ l:cmd,
							\ '{\s*\([[:alnum:]_]\+\)\.\([[:alnum:]_]\+\)\s*}',
							\ {m -> get(get(s:popups[a:key], m[1], {}), m[2], m[0])},
							\ 'g')
				call s:debug("execute command: " . l:cmd, s:popups[a:key].opts.debug)
				execute l:cmd
			else
				call call(s:callback, [s:popups[a:key]])
			endif
		else
			echom "Can't call variable of type" type(s:callback) "(see :h type)"
		endif
	endif
	return v:true
endfunction

" }}}1
function s:getval(val, info) abort " {{{1
  return type(a:val) ==# v:t_func ? call(a:val, [a:info]) : a:val
endfunction

" }}}1
function! s:debug(msg, debug) abort " {{{1
	if a:debug
		echom '[Choosy] ' . a:msg
		redraw!
	endif
endfunction

" }}}1

" vim:fdm=marker fdl=0
