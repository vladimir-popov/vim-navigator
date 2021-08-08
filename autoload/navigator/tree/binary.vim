" gt(x, y) = x > y: 1 else 0
function! g:navigator#tree#binary#New(gt) abort
  let tree = {
        \ 'left': g:navigator#tree#binary#New(a:gt),
        \ 'right': g:navigator#tree#binary#New(a:gt)
        \ }

  function tree.isEmpty()
    return !has_key(self, 'value')
  endfunction

  function tree.add(value) closure
    if self.isEmpty()
      let self.value = a:value
      return self
    endif

    if a:gt(a:value, self.value)
      return self.right.add(a:value)
    else
      return self.left.add(a:value)
    endif
  endfunction

endfunction
