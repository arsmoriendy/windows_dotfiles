"-- KEYMAPS --"
"indent all lines
function IndentAll()
  return "gg=G" . line(".") . "G"
endfunction
nnoremap <expr> == IndentAll()

"-- LOAD LUA CONFIGS --"
exec "source " .. stdpath("config") .. "/lua/init.lua"

