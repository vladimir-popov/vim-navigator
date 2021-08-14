" ==========================================================
" This script describes how to render a contents by the list
" of sections.
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
    let rendered_sections = {}
    for section in a:sections
      let r_section = self.renderOne(section)
      if !empty(r_section)
        let line = line('$')
        let rendered_sections[section.begin] = { 'line': line }
        call append(line - 1, r_section)
      endif
    endfor
    execute ':$d'

    return rendered_sections
  endfunction

  return render
endfunction

