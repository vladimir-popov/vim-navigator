" ==========================================================
" This script describes how to render a contents by the list
" of sections.
" ==========================================================

" The simplest render which render trimmed titles with padding 
" according to the fold level of a section.
function! navigator#render#SimpleRender(sections, ...) abort
  let settings = a:0 > 0 ? a:2 : {
        \   'padding': 2
        \ }

  functio! RenderSection(section) closure
    const space_count = settings.padding * a:section.fold
    return repeat(' ', space_count) .. trim(a:section.title)
  endfunction

  call s:RenderSections(a:sections, function('RenderSection'))

endfunction

" Renders a contents by the {sections} from the beginning 
" of the current buffer.
function! s:RenderSections(sections, Render) abort
  execute ':1,$d'
  let lnum=0
  for section in a:sections
    call append(line('$'), a:Render(section))
  endfor
endfunction
