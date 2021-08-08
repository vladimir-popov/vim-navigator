" ==========================================================
" This script is about items of the navigator.
" The item is a dictionary such as: >
"   { 
"     begin: <number of the first line in the section>, 
"     end: <number of the last line in the section>,
"     fold: <fold level of the line>,
"     title: <string with a name of the section in the contents>
"   }
" Items has a sorted list of items to help render them,
" and IntervalTree to find nearest to line item faster: >
"   {
"     'list': []
"     'tree': navigator#tree#interval#New()
"     'get': { lnum -> item }
"   }
" ==========================================================
function! navigator#items#Build(navigator) abort
  let items = {}

  function items.get(lnum)
    if has_key(self, 'tree')
      return self.tree.get(a:lnum)
    else 
      return {}
    endif
  endfunction


  let items.list = s:BuildList(a:navigator)
  if empty(items.list)
    return items
  endif

  let middle = len(items.list) / 2
  let items.tree = navigator#tree#interval#New(items.list[middle])

  for i in range(len(items.list))
    if i != middle
      call items.tree.add(items.list[i])
    endif
  endfor

  return items
endfunction

" If {items} has an item which include the specified line
" {lnum} then return it If no one item will be found the
" empty dict will be returned.
function! s:GetItem(items, lnum)
  let size = len(a:items)
  let middle = size / 2
  let item = a:items[middle]

  if size == 1
    return s:Include(item, a:lnum) ? item : {}
  endif

  if item.begin > a:lnum
    return navigator#items#GetItem(a:items[:middle-1], a:lnum)
  elseif item.begin < a:lnum
    return navigator#items#GetItem(a:items[middle:], a:lnum)
  else
    return a:items[middle] 
  endif
endfunction

function! s:Include(item, lnum)
  return ( a:item.begin <= a:lnum ) && (a:lnum <= a:item.end)
endfunction

" Creates list of items of current buffer according to the 
" {navigator}.
function! s:BuildList(navigator) abort
  const IsStart = s:GetFunction(a:navigator, 'beginningOfSection')

  let items = []
  let fold = 0
  for lnum in range(1, line('$'))
    if IsStart(lnum)
      let title = s:GetTitle(a:navigator, lnum)
      let fold = s:GetFold(a:navigator, lnum, fold) 
      let item = { 'begin':  lnum, 'fold': fold, 'title': title }
      call add(items, item)
    endif
    if s:IsEnd(a:navigator, lnum)
      let item = s:NotFinishedItem(items)
      let item.end = lnum 
      let fold -= 1
    endif
  endfor

  return items
endfunction

function! s:GetTitle(navigator, lnum)
  if has_key(a:navigator, 'sectionTitle')
    return a:navigator.sectionTitle(a:lnum)
  else 
    return getline(a:lnum)
  endif 
endfunction

function! s:GetFold(navigator, lnum, curfold)
  if has_key(a:navigator, 'sectionLevel')
    return a:navigator.sectionLevel(a:lnum)
  elseif has_key(a:navigator, 'endOfSection') 
    return a:curfold + 1
  else
    const ind = has_key(a:navigator, 'indentation') 
          \ ? a:navigator.indentation 
          \ : exists('shiftwidth')
          \ ? &shiftwidth
          \ : 2
    return 1 + indent(a:lnum) / ind
  endif
endfunction

function! s:IsEnd(navigator, lnum)
    return has_key(a:navigator, 'endOfSection') 
          \ && a:navigator.endOfSection(a:lnum)
endfunction 

function! s:NotFinishedItem(items) 
  for i in range(len(a:items) - 1, 0, -1)
    if !has_key(a:items[i], 'end')
      return a:items[i]
    endif
  endfor

  return {}
endfunction

" Tries to find a function inside the {navigator}.
" If the function is not found the exception will be thrown.
function! s:GetFunction(navigator, functionName) abort
  if has_key(a:navigator, a:functionName)
    let Func = a:navigator[a:functionName]
    if type(Func) == v:t_func
      return Func
    endif

    throw 'Property navigator.' .. a:functionName .. ' must be a function.'
      \ .. ' But it has type ' .. type(Func) .. '. See :help type'
  endif

  throw 'Function ' .. a:functionName .. ' was not found.'
        \ .. ' Please, set it to the navigator for ' 
        \ .. a:navigator.buffer.name 
endfunction
