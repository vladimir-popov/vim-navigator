setlocal foldmethod=expr
setlocal foldexpr=NavigatorMarkdown().foldLevel(v:lnum)

function! NavigatorMarkdown()
  if !exists('b:navigator') 
    let b:navigator = g:NavigatorNew()
    let b:navigator.beginningOfSection = { str -> str =~# '\v^\s*\#+' }
    let b:navigator.sectionLevel = { str -> len(matchstr(str, '\v\#+', 0, 1)) }
  endif

  return b:navigator
endfunction

call NavigatorMarkdown()
