" ==========================================================
" This script is about default parser.
"
" The Parser is a dictionary with method `parse` which should
" parse the current buffer and return the Sections: >
"   {
"     'parse': { () -> <sections> }
"   }
" 
" The parser can have arbitrary properties with description of 
" a document section. The Description should be a dictionary 
" with folow functions: >
"   {
"     'Begin': { lnum -> <bool> },   " to find the first line of the section;
"     'End':   { lnum -> <bool> } ,  " opt; to find the last line of the section;
"     'Title': { lnum -> <string> }, " opt; can be used to set more specific
"                                    " section title;
"     'Fold':  { lnum -> <number> }  " opt; to specify a custom fold level for
"                                    " the section;
"   }
"
" The Sections is a dictionary which has a sorted list of 
" sections to help rendering them, and navigator#intervaltree
" to find nearest to line section faster: >
"   {
"     'list': [<section>]
"     'tree': navigator#intervaltree#New()
"     'Get': { lnum -> <section> }
"   }
"
" The Section is a dictionary such as: >
"   { 
"     type: <string>,  " string with type of the section
"     begin: <number>, " count of the first line in the section
"     end: <number>,   " count of the last line in the section
"     fold: <number>,  " fold level of the line
"     title: <string>  " string with a name of the section
"   }
" ==========================================================
function! navigator#parser#New() abort
  let parser = {}

  function parser.parse()
    let sections = {}

    function sections.get(lnum)
      if has_key(self, 'tree')
        return self.tree.get(a:lnum)
      else 
        return {}
      endif
    endfunction


    let sections.list = s:BuildSectionsList(self)
    if empty(sections.list)
      return sections
    endif

    let sections.tree = navigator#intervaltree#FromList(sections.list)

    return sections
  endfunction

  return parser
endfunction

" Creates list of sections of current buffer
function! s:BuildSectionsList(parser) abort
  let sections = []
  " [ { 'constructor': newSection, 'section': section }  ]
  let unfinished_sections = []

  function! Open(description, lnum) closure
    let title = s:GetTitle(a:description, a:lnum)
    let fold = has_key(a:description, 'Fold')
          \ ? a:description.Fold(a:lnum)
          \ : !empty(unfinished_sections) 
          \ ? unfinished_sections[-1].section.fold + 1
          \ : 1
    " prevents two sequential sections with the same fold level
    let fold = empty(sections) ? fold : sections[-1].fold == fold ? fold + 1 : fold
    let section = { 
          \ 'begin':  a:lnum, 
          \ 'fold': fold, 
          \ 'title': title, 
          \ 'type': a:description.type 
          \ }
    call add(sections, section)
    call add(unfinished_sections, { 'description': a:description, 'section': section })
  endfunction

  function! Close(lnum) closure
    let section = unfinished_sections[-1].section
    let section.end = a:lnum 
    call remove(unfinished_sections, -1)
  endfunction

  for lnum in range(1, line('$'))
    " description with additional 'type' property of the section
    " which begins on lnum, or empty dict
    let newSection = s:MaybeNewSection(a:parser, lnum)

    " try to open a section
    if !empty(newSection)
      " if previous section doesn't have End function
      if !empty(unfinished_sections) 
            \ && !has_key(unfinished_sections[-1].description, 'End')
        call Close(lnum - 1)
      endif

      call Open(newSection, lnum)
    endif

    " try to close a section using specific function if exists
    if !empty(unfinished_sections) 
          \ && has_key(unfinished_sections[-1].description, 'End')
          \ && unfinished_sections[-1].description.End(lnum)
      call Close(lnum)
    endif
  endfor

  " close all unclosed sections
  for us in unfinished_sections 
    let us.section.end = line('$')
  endfor

  return sections
endfunction

function! s:MaybeNewSection(parser, lnum) abort
  for type in keys(a:parser)
    if type !~ 'parse'
      let description = a:parser[type]
      if description.Begin(a:lnum)
        let description.type = type
        return description
      endif
    endif
  endfor

  return {}
endfunction

function! s:GetTitle(description, lnum)
  if has_key(a:description, 'Title')
    return a:description.Title(a:lnum)
  else 
    return getline(a:lnum)
  endif 
endfunction
