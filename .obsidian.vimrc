" Normal mode remappings
imap jk <Esc>

nmap j gj
nmap k gk

vmap j gj
vmap k gk

noremap l w 
noremap h b
noremap e l
noremap w h

noremap H ^
noremap L $

set clipboard=unnamed

exmap back obcommand app:go-back
nmap <C-i> :back
exmap forward obcommand app:go-forward
nmap <C-o> :forward
