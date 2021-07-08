" ==========================================================
" This script describes a logic to build and show a Contents 
" of the current buffer.
" ==========================================================

" Clears the {navigator}, creates a new buffer and render 
" the contents of the {navigator.buffer} in the created 
" buffer.
" @param navigator - the {navigator} which should be shown.
function! navigator#contents#Show(navigator) abort
  if navigator#contents#IsContentsShown(a:navigator)
    return 0
  endif

  call a:navigator.update()
  let item = a:navigator.getItem(line('.'))
  call s:CreateBuffer(a:navigator)
  " getting a function to apply a custom format of a section title 
  let Format = (has_key(a:navigator, 'formatSectionName'))
        \ ? a:navigator.formatSectionName
        \ : { s -> s }
  let a:navigator.contents.items = navigator#render#Render(
        \     a:navigator.items(),
        \     Format
        \   )
  let lnum = s:Find(a:navigator.contents.items, item) + 1
  execute lnum
  setlocal nomodifiable
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

  const lnum = max([ line('.') - 1, 0 ])
  const goto_line = b:navigator.contents.items[lnum].line
  call navigator#contents#Close(b:navigator)
  execute goto_line
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

  " cleanup the navigator
  unlet a:navigator.contents
endfunction

" Returns the number of item in the list by the 
" line number or 0.
function! s:Find(items, item)
  if empty(a:item)
    return 0
  endif

  let l = 0 
  while l < len(a:items)
    if a:items[l].line == a:item.line
      return l
    endif
    let l += 1
  endwhile
  return 0
endfunction

function! s:CreateBuffer(navigator) abort
  let a:navigator.contents = {}

  let a:navigator.contents.buffer = 
        \ 'contents_of_' .. a:navigator.buffer.name 
  let a:navigator.contents.bid = bufadd(a:navigator.contents.buffer)
  if (a:navigator.mode() == 'r')
    execute 'silent! botright vsplit ' .. a:navigator.contents.buffer
  else
    execute 'silent buffer! ' .. a:navigator.contents.bid
  endif

  " configurations of the new buffer:
  setlocal buftype=nofile bufhidden=hide nospell nowrap 
  setlocal noswapfile noshowcmd nobuflisted
  setlocal nonumber norelativenumber nocursorcolumn nolist 
  setlocal foldmethod=indent

  " keymapping:
  execute 'nnoremap <silent> <nowait> <buffer> ' 
        \ .. g:navigator_close_nmap .. ' :NavigatorClose<cr>'
  execute 'nnoremap <silent> <nowait> <buffer> ' 
        \ .. g:navigator_goto_nmap .. ' :call navigator#contents#Goto()<cr>'

  let b:navigator = a:navigator
endfunction  
