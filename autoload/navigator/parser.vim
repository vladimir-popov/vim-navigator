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

  function parser.parse() abort
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
  let current_fold = 0

  function! Open(newSection, lnum) closure
    let title = s:GetTitle(a:newSection, a:lnum)
    let current_fold = s:GetFold(a:newSection, a:lnum, current_fold) 
    let us = { 
          \ 'begin':  a:lnum, 
          \ 'fold': current_fold, 
          \ 'title': title, 
          \ 'type': a:newSection.type 
          \ }
    call add(sections, us)
    call add(unfinished_sections, { 'description': a:newSection, 'section': us })
  endfunction

  function! Close(lnum) closure
    let section = unfinished_sections[-1].section
    let section.end = a:lnum 
    let current_fold -= 1
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

function! s:MaybeNewSection(parser, lnum)
  let descriptions = filter(a:parser, 'v:key !~ "parse"')
  for type in keys(descriptions)
    let description = a:parser[type]
    if description.Begin(a:lnum)
      let description.type = type
      return description
    endif
  endfor

  return {}
endfunction

function! s:IsEnd(unfinished_section, lnum) abort
  return has_key(a:unfinished_section.description, 'End')
        \ ? a:unfinished_section.description.End(lnum)
        \ :
endfunction

function! s:GetTitle(description, lnum)
  if has_key(a:description, 'Title')
    return a:description.Title(a:lnum)
  else 
    return getline(a:lnum)
  endif 
endfunction

function! s:GetFold(description, lnum, curfold)
  if has_key(a:description, 'Fold')
    return a:description.Fold(a:lnum)
  else
    return a:curfold + 1
  endif
endfunction

" If {sections} has an section which include the specified line
" {lnum} then return it If no one section will be found the
" empty dict will be returned.
function! s:GetSection(sections, lnum)
  let size = len(a:sections)
  let middle = size / 2
  let section = a:sections[middle]

  if size == 1
    return ( a:section.begin <= a:lnum ) && (a:lnum <= a:section.end) 
          \ ? section
          \ : {}
  endif

  if section.begin > a:lnum
    return s:GetSection(a:sections[:middle-1], a:lnum)
  elseif section.begin < a:lnum
    return s:GetSection(a:sections[middle:], a:lnum)
  else
    return a:sections[middle] 
  endif
endfunction
