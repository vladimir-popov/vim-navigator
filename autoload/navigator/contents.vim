" ==========================================================
" This script describes a logic of building and showing a 
" Contents of the current buffer.
" Contents is a dictionary such as: >
" {
"   'buffer': <string>,   " name of the Contents buffer
"   'bid': <number>,      " id of the Contents buffer
"   'items': <list>,      " list of items
"   'getItem': <funcref>, " function  { Section -> Item } or 
"                         " { Lnum -> Item } to get an item 
"                         " corresponding to the section or 
"                         " number of line in the Contents
"                         " buffer.
"   'index_by_sections': <dict>,
"   'index_by_items': <dict>,
" } 
" Every Item of the Contents is a dictionary such as: >
" {
"   'line': <number>,   " number of the line in the Contents 
"                       " buffer where Item has been rendered
"   'section': <dict>,  " corresponding section
" }
" ==========================================================

" Clears the {navigator}, creates a new buffer and render 
" the contents of the {navigator.buffer} in the created 
" buffer.
" @param navigator - the {navigator} which should be shown.
function! navigator#contents#Show(navigator) abort
  if navigator#contents#IsContentsShown(a:navigator)
    return 0
  endif

  try
    call a:navigator.update()
    let line = line('.')
    let section = a:navigator.getSection(line)
    call s:CreateBuffer(a:navigator)
    let a:navigator.contents.items = a:navigator.render
          \.renderAll(a:navigator.listOfSections())
    
    " all changes are done, let's make buffer read only
    setlocal nomodifiable

    " put cursor on the line with appropriate item
    let item = a:navigator.contents.getItem(section)
    execute empty(item) ? 0 : item.line 
  catch 
    call navigator#contents#Close(a:navigator)
    throw string(v:exception)
  endtry
endfunction

" Checks that the {navigator} has the 'contents.bid'
" and it equals to the current buffer.
function! navigator#contents#IsContentsShown(navigator)
  return has_key(a:navigator, 'contents') 
        \ && has_key(a:navigator.contents, 'bid') 
        \ && a:navigator.contents.bid == bufnr("%")
endfunction

function! navigator#contents#Goto() abort
  if !exists('b:navigator') ||
        \ !navigator#contents#IsContentsShown(b:navigator)
    throw "Navigator's buffer is not active. Current is " 
          \ .. bufname('%')
  endif

  let lnum = max([ line('.'), 1 ])
  let item = b:navigator.contents.getItem(lnum)
  call navigator#contents#Close(b:navigator)
  execute empty(item) ? 0 : item.section.begin
endfunction

" If the {navigator} is shown returns 0, else 
" opens the buffer for which was created the {navigator}
" and wipeout the buffer with contents.
function! navigator#contents#Close(navigator)
  if !navigator#contents#IsContentsShown(a:navigator)
    return 0
  endif
  if (a:navigator.mode() == 'b')
    " open original buffer
    execute 'buffer ' .. a:navigator.buffer.id
  else " if (a:navigator.mode() == 'r')
    " move focus back
    " execute 'wincmd h'
    call win_gotoid(bufwinid(a:navigator.buffer.name))
  endif

  " close the buffer with a contents.
  execute 'silent!  bwipeout ' .. a:navigator.contents.buffer
endfunction

function! s:CreateBuffer(navigator) abort
  let contents = {}

  function contents.refreshIndexes()
    if !(
          \has_key(self, 'items') 
          \&& has_key(self, 'index_by_sections') 
          \&& has_key(self, 'index_by_items')
          \)
      let self.index_by_sections = {}
      let self.index_by_items = {}
      for item in self.items
        let self.index_by_sections[item.section.begin] = item
        let self.index_by_items[item.line] = item
      endfor
    endif
  endfunction

  function contents.getItem(key)
    if !has_key(self, 'items') 
      return {}
    endif
    call self.refreshIndexes()
    if type(a:key) == v:t_dict && !empty(a:key)
      return get(self.index_by_sections, a:key.begin, {})
    elseif type(a:key) == v:t_number
      return get(self.index_by_items, a:key, {})
    else
      return {}
    endif
  endfunction

  let contents.buffer = 'contents of [' .. a:navigator.buffer.name .. ']'
  let contents.bid = bufadd(contents.buffer)

  let a:navigator.contents = contents

  if (a:navigator.mode() == 'r')
    execute 'silent! botright vsplit ' .. a:navigator.contents.buffer
  else " if mode == 'b'
    execute 'silent buffer! ' .. a:navigator.contents.bid
  endif

  " configurations of the new buffer:
  setlocal buftype=nofile bufhidden=hide nospell nowrap 
  setlocal noswapfile noshowcmd nobuflisted
  setlocal nonumber norelativenumber nocursorcolumn nolist 
  setlocal foldmethod=indent
  " make buffer temporary modifiable to rendering
  setlocal modifiable

  " keymapping:
  execute 'nnoremap <silent> <nowait> <buffer> ' 
        \ .. g:navigator_close_nmap .. ' :NavigatorClose<cr>'
  execute 'nnoremap <silent> <nowait> <buffer> ' 
        \ .. g:navigator_goto_nmap .. ' :call navigator#contents#Goto()<cr>'

  let b:navigator = a:navigator
endfunction  
