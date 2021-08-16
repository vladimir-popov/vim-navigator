" see https://en.wikipedia.org/wiki/Interval_tree
"
" let interval = { 'begin': number, 'end': number }
" let tree = { 'left': tree, 'right': tree, 'middle': number, 'intervals': [interval] }
function! navigator#intervaltree#FromList(intervals) abort 
  let middle = len(a:intervals) / 2
  let tree = navigator#intervaltree#New(a:intervals[middle])

  for i in range(len(a:intervals))
    if i != middle
      call tree.add(a:intervals[i])
    endif
  endfor

  return tree
endfunction

function! navigator#intervaltree#New(root) abort
  if !(has_key(a:root, 'begin') && has_key(a:root, 'end'))
    throw 'Illegal interval: ' .. string(a:root)
  endif

  let tree = { 
        \ 'intervals': [a:root],
        \ 'middle': (a:root.begin + a:root.end) / 2, 
        \ }

  function tree.add(interval) abort
    if (a:interval.begin > self.middle) && (a:interval.end > self.middle)
      return s:AddRight(self, a:interval)
    elseif (a:interval.begin < self.middle) && (a:interval.end < self.middle)
      return s:AddLeft(self, a:interval)
    else
      call add(self.intervals, a:interval)
      return self
    endif
  endfunction

  function tree.get(x) abort
    let all = self.getAll(a:x) 
    let result = {}
    let min = 9999999
    for i in range(len(all))
      let interval = all[i]
      let length = interval.end - interval.begin
      if length < min
        let result = interval
        let min = length
      endif
    endfor

    return result
  endfunction

  function tree.getAll(x)
    let result = s:Contained(self.intervals, a:x)

      if a:x < self.middle && has_key(self, 'left')
        let result += self.left.getAll(a:x)
      elseif a:x > self.middle && has_key(self, 'right')
        let result += self.right.getAll(a:x)
      endif

    return result
  endfunction

  return tree
endfunction

function! s:AddRight(tree, interval)
  if has_key(a:tree, 'right')
    return a:tree.right.add(a:interval)
  else
    let a:tree.right = navigator#intervaltree#New(a:interval)
    return a:tree
  endif
endfunction

function! s:AddLeft(tree, interval)
  if has_key(a:tree, 'left')
    return a:tree.left.add(a:interval)
  else
    let a:tree.left = navigator#intervaltree#New(a:interval)
    return a:tree
  endif
endfunction

" returns a list of intervals with x
function! s:Contained(intervals, x)
  let result = []
  for i in range(len(a:intervals))
    let interval = a:intervals[i]
    if  s:IsContains(interval, a:x) 
      call add(result, interval)
    endif
  endfor

  return result
endfunction

" (middle1 < middle2) ? 1 : 0
function! s:CompareIntervals(x1, x2)
  let m1 = a:x1.end - a:x1.begin
  let m2 = a:x2.end - a:x2.begin
  return m1 < m2 ? 1 : 0
endfunction

" include boundaries
function! s:IsContains(interval, x)
  return (a:interval.begin <= a:x) && (a:interval.end >= a:x)
endfunction
