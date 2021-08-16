setlocal foldmethod=expr
setlocal foldexpr=NavigatorMarkdown().foldLevel(v:lnum)

function! NavigatorMarkdown()
  function! s:Begin(lnum)
    return getline(a:lnum) =~# '\v^\#+'
  endfunction

  function! s:End(lnum)
    return getline(a:lnum + 1) =~# '\v^\s*$' && s:Begin(a:lnum + 2)
  endfunction

  function! s:Fold(lnum)
    return len(matchstr(getline(a:lnum), '\v\#+', 0, 1)) 
  endfunction

  if !exists('b:navigator') 
    let b:navigator = g:NavigatorNew()
    let b:navigator.parser.section = {
          \ 'Begin': function('s:Begin'),
          \ 'End': function('s:End'),
          \ 'Fold': function('s:Fold') 
          \ }
  endif
  return b:navigator
endfunction

call NavigatorMarkdown()
