" Copyright 2021 Vladimir Popov <vladimir@dokwork.ru>
" 
" Permission is hereby granted, free of charge, to any person
" obtaining a copy of this software and associated
" documentation files (the "Software"), to deal in the
" Software without restriction, including without limitation
" the rights to use, copy, modify, merge, publish, distribute,
" sublicense, and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished to do so,
" subject to the following conditions:
" 
" The above copyright notice and this permission notice shall
" be included in all copies or substantial portions of the
" Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
" KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
" WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
" PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
" OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
" OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
" OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
" SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



" ==========================================================
" Custom configurations of the Navigator plugin
" ==========================================================

" Keymap to show the contents of the current buffer
call navigator#utils#DefaultValue('g:navigator_show_nmap', '<f12>')
" Keymap to close the contents
call navigator#utils#DefaultValue('g:navigator_close_nmap', '<f12>')
" Keymap to go to the selected section
call navigator#utils#DefaultValue('g:navigator_goto_nmap', '<cr>')
" Size of tabulation in the Contents
call navigator#utils#DefaultValue('g:navigator_padding_size', 2)
" Where the buffer with contents should be opened 
call navigator#utils#DefaultValue('g:navigator_open_mode', 'r')


" ==========================================================
" Initialization of the commands and keymap biding
" ==========================================================

command! NavigatorShow :echo g:NavigatorShow()
command! NavigatorClose :call g:NavigatorClose()

call navigator#utils#Keymap(g:navigator_show_nmap, 'n', ':NavigatorShow<cr>')


" ==========================================================
" Auto reset the navigator on everey buffer change
" ==========================================================

augroup navigator 
  autocmd!
  autocmd TextChanged,TextYankPost,InsertLeave,BufWrite 
        \ * :call g:NavigatorReset()
augroup END  


" ==========================================================
" The main functions of the plugin
" ==========================================================

" If {b:navigator} already exists, it shows a contents of the
" current buffer, else just returns message that {b:navigator}
" is not exists.
function! g:NavigatorShow()
  if exists('b:navigator')
    call navigator#contents#Show(b:navigator)
    return ''
  else
    return 'Navigator is not defined for ' .. bufname('%')
  endif  
endfunction  

functio! g:NavigatorClose()
  if exists('b:navigator')
    call navigator#contents#Close(b:navigator)
  endif
endfunction

function! g:NavigatorReset()
  if exists('b:navigator')
    call b:navigator.reset()
  endif
endfunction  

" Constructor of the {navigator}
function! g:NavigatorNew()
  let navigator = { 
        \  'buffer': { 
        \     'id': bufnr('%'), 
        \     'name':  bufname('%') 
        \   },
        \   'formatTitle': { s -> s }
        \ }

  " Lazy getter of the items - a list of dictionaries such as:
  " { 'line': <number>, 'fold': <number>[, 'title': <string>] }
  " where:
  "   - 'line' is a number of the line in the buffer;
  "   - 'fold' is a fold level on the 'line';
  "   - 'title' is an optional title of the 'line'.
  "      Defined title means that its 'line' is a header.
  function navigator.items() abort
    if has_key(self, '__items')
      return self.__items 
    else
      let self.__items = navigator#items#Build(self)
      return self.__items
    endif
  endfunction

  function navigator.reset() 
    if has_key(self, '__items')
      unlet self.__items
    endif  
  endfunction

  function navigator.update()
    call self.reset()
    call self.items()
  endfunction  

  function navigator.getItem(lnum)
    return navigator#items#GetItem(self.items(), a:lnum)
  endfunction

  " Returns {foldlevel} of the line {lnum}
  " according to the current {items}.
  function navigator.foldLevel(lnum) abort
    let item = self.getItem(a:lnum)
    return (has_key(item, 'fold')) ? item.fold : 0
  endfunction  

  " Possible values:
  "   b - deafult; Contents is apeare in the same window 
  "   l - to show in the new window on the left; 
  "   r - to show in the new window on the right;
  function navigator.mode()
    if (!exists('g:navigator_open_mode'))
      return 'b'
    else
      return (g:navigator_open_mode ==# 'r') ? 'r' : 'b'
    endif
  endfunction

  function navigator.settings()
    return { 'padding': g:navigator_padding_size }
  endfunction

  return navigator
endfunction  
