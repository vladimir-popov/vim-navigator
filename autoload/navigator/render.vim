" ==========================================================
" This script describes how to render a contents by the list
" of items.
" ==========================================================

" Renders a contents by the {items} from the beginning 
" of the current buffer. Returns a list of rendered items.
" Function {format} with type of { str -> str } is used to
" format a text of an  item.
function! navigator#render#Render(items, format) abort
  execute ':1,$d'
  let lnum=0
  let contents = []
  let rendered_items = []
  for item in a:items
    if has_key(item, 'text')
      call add(contents, s:CreateLine(item, a:format))
      call add(rendered_items, item)
    endif
  endfor
  call append(0, contents)
  execute ':$d'

  return rendered_items
endfunction

functio! s:CreateLine(item, format)
  const space_count = g:navigator_tab_size * a:item.fold
  return repeat(' ', space_count) .. a:format(trim(a:item.text))
endfunction
