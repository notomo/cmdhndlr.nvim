let s:this_dir = expand('<sfile>:h')
let s:ts_path = s:this_dir .. '/nvim-treesitter'
execute 'set runtimepath^=' .. s:ts_path
