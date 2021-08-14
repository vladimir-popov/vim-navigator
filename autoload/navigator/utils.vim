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

" Trys to find the item in the collection comparing items 
" through Compare. Compare(x, y) => x > y: 1; x < y: -1; x == y: 0
" Returns index of found item or -1.
function! navigator#utils#Find(collection, item, Compare) abort
  let size = len(a:collection)
  let middle = size / 2
  
  if size == 0
    return -1
  elseif size == 1
    return a:Compare(a:item, a:collection[0]) == 0 ? 0 : -1
  endif

  if a:Compare(a:item, a:collection[middle]) == 1
    return navigator#utils#Find(a:collection[:middle-1], a:item, a:Compare)
  elseif a:Compare(a:item, a:collection[middle]) == -1
    return navigator#utils#Find(a:collection[middle:], a:item, a:Compare)
  else 
    return a:collection[middle]
  endif
endfunction
