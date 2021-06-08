test: ./script/nvim-treesitter/parser/lua.so ./script/nvim-treesitter/parser/go.so
	vusted --shuffle
.PHONY: test

./script/nvim-treesitter:
	git clone https://github.com/nvim-treesitter/nvim-treesitter.git $@
./script/nvim-treesitter/parser/lua.so: ./script/nvim-treesitter
	nvim -u ./script/install.vim -c "TSInstallSync lua" -c quit
./script/nvim-treesitter/parser/go.so: ./script/nvim-treesitter
	nvim -u ./script/install.vim -c "TSInstallSync go" -c quit
