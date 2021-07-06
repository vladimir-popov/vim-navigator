" ==========================================================
" This script contains util methods.
" ==========================================================

" Checks is {varname} already exists. If no, it creates
" new variable {varname} with value {value}.
function! navigator#utils#DefaultValue(varname, value)
  if (exists(a:varname))
    return
  endif
  let v = (type(a:value) == v:t_string) ? "'" .. a:value .. "'" : a:value
  execute printf("let %s = %s", a:varname, v)
endfunction  

" Maps keys {keys} to {cmd} in the mode {mode}.
" For example: >
"   navigator#Keymap('f1', n, ':help')
function! navigator#utils#Keymap(keys, mode, cmd)
  let actual = maparg(a:keys, a:mode)
  if empty(actual)
    execute a:mode .. 'noremap <silent> ' .. a:keys .. ' ' .. a:cmd
  elseif actual ==? a:cmd
    " nothing to do
  else
    throw 'Command ' .. a:cmd .. ' was not mapped because ' 
          \ .. a:mode .. 'map ' .. a:keys
          \ .. ' already defined for ' .. actual
  endif
endfunction
