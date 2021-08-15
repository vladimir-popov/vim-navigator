setlocal foldmethod=expr
setlocal foldexpr=NavigatorMarkdown().foldLevel(v:lnum)

function! NavigatorMarkdown()
  if !exists('b:navigator') 
    let b:navigator = g:NavigatorNew()
    let b:navigator.parser.section = {
          \ 'Begin': { lnum -> getline(lnum) =~# '\v^\s*\#+' },
          \ 'Fold':  { lnum -> len(matchstr(getline(lnum), '\v\#+', 0, 1)) }
          \ }
  endif

  return b:navigator
endfunction

call NavigatorMarkdown()
