#!/bin/bash
rm -rf ~/.cache/opencode ~/.local/share/opencode/{log,project} ~/.claude/{debug,projects} ~/.cache/claude*

if [[ "$(uname -s)" == "Darwin" ]]; then
    rm -rf ~/Library/Caches/Claude ~/Library/Application\ Support/Claude/Caches*
fi
