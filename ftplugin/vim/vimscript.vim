setlocal foldmethod=expr
setlocal foldexpr=NavigatorVimScript().foldLevel(v:lnum)

function! NavigatorVimScript()
  if !exists('b:navigator') 
    let b:navigator = g:NavigatorNew()
    let b:navigator.beginningOfSection = { lnum -> getline(lnum) =~# '\v^\s*fun' }
    let b:navigator.endOfSection = { lnum -> getline(lnum) =~# '\v^\s*endf' }
  endif

  return b:navigator
endfunction

call NavigatorVimScript()
