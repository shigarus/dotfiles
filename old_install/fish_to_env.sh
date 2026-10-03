#!/usr/env/bin bash
if command -v fish > /dev/null 2>&1; then
	ln -s $(which fish) /usr/local/bin/fish
else
	echo "fish is not install"
fi
