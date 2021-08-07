" ==========================================================
" This script builds a list of items the current buffer 
" which will be used to build a contents of the buffer.
"
" The list of items contains dictionaries such as: >
"   { 
"     line: <number of line>, 
"     fold: <fold level of the {line}>,
"     title: <optional string with a name of the section in the contents>
"   }
" ==========================================================

function! navigator#items#Build(navigator) abort
  let IsStart = s:GetFunction(a:navigator, 'start')

  if has_key(a:navigator, 'endOfSection')
    let IsEnd = s:GetFunction(a:navigator, 'end')
    return s:BuildByStartEnd(IsStart, IsEnd)
  elseif has_key(a:navigator, 'sectionLevel')
    let Fold = { i -> a:navigator.sectionLevel(getline(i)) }
    return s:BuildWithCustomFold(IsStart, Fold)
  else
    const ind = has_key(a:navigator, 'indentation') 
          \ ? a:navigator.indentation 
          \ : exists('shiftwidth')
          \ ? &shiftwidth
          \ : 2
    let Fold = { i -> 1 + indent(i) / ind }
    return s:BuildWithCustomFold(IsStart, Fold)
  endif  
endfunction

" If {items} has an item on the specified line {lnum}
" then return it else the nearest item with low line
" number will be returned. If no one item will be found
" the empty dict will be returned.
function! navigator#items#GetItem(items, lnum)
  let size = len(a:items)
  let middle = size / 2
  let line = a:items[middle].line

  if size == 1
    return (line <= a:lnum) 
          \ ? a:items[0] 
          \ : {}
  endif

  if line > a:lnum
    return navigator#items#GetItem(a:items[:middle-1], a:lnum)
  elseif line < a:lnum
    return navigator#items#GetItem(a:items[middle:], a:lnum)
  else
    return a:items[middle] 
  endif
endfunction

function! s:BuildWithCustomFold(sectionStart, fold) abort
  let items = []
  for i in range(1, line('$'))
    let curline = getline(i)
    if a:sectionStart(curline)
      let item = s:NewItem(i, a:fold(i), curline)
      call add(items, item)
    endif  
  endfor

  return items
endfunction

function! s:BuildByStartEnd(sectionStart, sectionEnd) abort
  let items = []
  let current_fold = 0

  for i in range(1, line('$'))
    let cur = getline(i)
    let prev = getline(i-1)

    if a:sectionStart(cur)
      let current_fold += 1
      let item = s:NewItem(i, current_fold, cur)
      call add(items, item)
    endif 

    if a:sectionEnd(prev)
      let current_fold -= 1
      let item = s:NewItem(i, current_fold)
      call add(items, item)
    endif
  endfor

  return items
endfunction

function s:NewItem(line, fold, ...) 
  let item = { 'line':  a:line, 'fold': a:fold }
  if a:0 > 0 
    let item.text = a:1
  endif
  return item
endfunction    

" Tries to find a function inside the {navigator}
" or global scope.
" If the function is not found the exception will be thrown.
function! s:GetFunction(navigator, funsuf)
  let functionName = (a:funsuf ==? 'start') ? 'beginningOfSection' : 'endOfSection'
  if has_key(a:navigator, functionName)
    return a:navigator[functionName]
  else
    throw 'Function to find the ' .. a:funsuf .. ' of a section was not found.'
          \ .. ' You can set it to the navigator object directly with the name ' 
          \ .. '"' .. functionName .. '".'
  endif
endfunction
