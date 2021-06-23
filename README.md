# Vim Navigator

The main goal of this plugin is to help you navigate around the buffer.
When the navigator for the current type of buffer exists, you can open the
buffer's contents to go through it faster. Also, the same logic which is
used to build the contents is used for folding.

## Installation 

To install this plugin with the [Plug](https://github.com/junegunn/vim-plug),
add this `'vladimir-popov/vim-navigator'` to your `.vimrc` and run `:PlugInstall`.

## Commands:

- `:NavigatorShow` - to show a contents of the current buffer (`<F12>` by default).
- `:NavigatorClose` - to close the contents and return back to the
buffer(`<ESC>` by default).

## Key mapping

By default, you can show a contents by pressing `<F12>` and close it by
pressing the same key. To go to selected section the `<ENTER>` is used. But you
can change key mapping just set the variables:

```vimscript
" Keymap to show the contents:
let g:navigator_show_nmap='<f12>'

" Keymap to close the contents:
g:navigator_close_nmap='<f12>'

" Keymap to go to the selected section
g:navigator_goto_nmap='<cr>'
```
