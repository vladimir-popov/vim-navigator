setlocal foldmethod=expr
setlocal foldexpr=NavigatorVimScript().foldLevel(v:lnum)

function! g:NavigatorVimScript()
  if !exists('b:navigator') 
    let parser = navigator#parser#New()
    let parser.function = {
          \  'begin': { lnum -> getline(lnum) =~# '\v^\s*fun' },
          \  'end': { lnum -> getline(lnum) =~# '\v^\s*endf' }
          \}
    let b:navigator = g:NavigatorNew(parser)
  endif

  return b:navigator
endfunction

call g:NavigatorVimScript()
