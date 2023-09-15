" /etc/vimrc - configuration file for vim

set nocompatible        " Use Vim defaults instead of 100% vi compatibility
set ignorecase         " Do case insensitive matching
set autoindent          " always set autoindenting on
set linebreak           " Don't wrap words by default
set tabstop=2
set sw=2
set noet
set nowrap
set ai
set modeline
set modelines=5

set dir=/tmp

set linebreak           " Don't wrap words by default
set textwidth=0         " Don't wrap lines by default
set ruler               " show the cursor position all the time

"--- Sane tab navigation
nmap <C-t><Left> :tabprevious<cr>
map  <C-t><Left> :tabprevious<cr>
imap <C-t><Left> <ESC>:tabprevious<cr>
nmap <C-t><Right> :tabnext<cr>
map  <C-t><Right> :tabnext<cr>
imap <C-t><Right> <ESC>:tabnext<cr>
nmap <C-t>c :tabnew .<cr>
imap <C-t>c <ESC>:tabnew .<cr>
map  <C-t>c :tabnew .<cr>

