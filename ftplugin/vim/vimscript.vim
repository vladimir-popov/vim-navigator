setlocal foldmethod=expr
setlocal foldexpr=NavigatorVimScript().foldLevel(v:lnum)

function! g:NavigatorVimScript()
  if !exists('b:navigator') 
    let b:navigator = g:NavigatorNew()
    let b:navigator.parser.function = {
          \  'Begin': { lnum -> getline(lnum) =~# '\v^\s*fun' },
          \  'End': { lnum -> getline(lnum) =~# '\v^\s*endf' }
          \}
  endif

  return b:navigator
endfunction

call g:NavigatorVimScript()
