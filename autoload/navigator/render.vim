" ==========================================================
" This script describes how to render a contents by the list
" of sections.
" Result is a dictionary with rendered items. Key is a number
" of the line in the original buffer on wich some section 
" begin. Value is dectionary such as: >
"   {
"     'line': <number of the line in the Contents buffer>
"   }
" ==========================================================

" The simplest render which render trimmed titles with padding 
" according to the fold level of a section.
function! navigator#render#New() abort
  let render = {
        \   'padding': 2
        \ }

  function render.renderOne(section) closure
    const space_count = self.padding * a:section.fold
    return repeat(' ', space_count) .. trim(a:section.title)
  endfunction

  " Renders a contents by the {sections} from the beginning 
  " of the current buffer.
  " Returns a list of rendered sections.
  function render.renderAll(sections) abort
    execute ':1,$d'
    let items = []
    
    for section in a:sections
      let text = self.renderOne(section)
      if !empty(text)
        let line = line('$')
        call add(items, { 'line': line, 'section': section })
        call append(line - 1, text)
      endif
    endfor
    execute ':$d'

    return items
  endfunction

  return render
endfunction

