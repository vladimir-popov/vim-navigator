setlocal foldmethod=expr
setlocal foldexpr=NavigatorYaml().foldLevel(v:lnum)

function! NavigatorYaml()
  if !exists('b:navigator') 
    let b:navigator = g:NavigatorNew()
    let b:navigator.isSectionStart = { str -> str =~# '\v^\s*(-|_|\w)+:' }
    let b:navigator.formatText = { str -> split(trim(str), ':')[0] } 
  endif

  return b:navigator
endfunction

call NavigatorYaml()
