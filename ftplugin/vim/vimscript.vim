setlocal foldmethod=expr
setlocal foldexpr=NavigatorVimScript().foldLevel(v:lnum)

function! NavigatorVimScript()
  if !exists('b:navigator') 
    let b:navigator = g:NavigatorNew()
    let b:navigator.beginningOfSection = { str -> str =~# '\v^\s*fun' }
    let b:navigator.endOfSection = { str -> str =~# '\v^\s*endfunction' }
  endif

  return b:navigator
endfunction

call NavigatorVimScript()
