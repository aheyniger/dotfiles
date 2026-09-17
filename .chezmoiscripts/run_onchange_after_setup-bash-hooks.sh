#!/usr/bin/env bash
set -euo pipefail

BASHRC="$HOME/.bashrc"
touch "$BASHRC"

add_hook() {
    local line="$1"
    if ! grep -qF "$line" "$BASHRC"; then
        printf '\n# added by chezmoi\n%s\n' "$line" >> "$BASHRC"
    fi
}

add_hook '[ -f ~/.bash_aliases ] && source ~/.bash_aliases'
add_hook '[ -f ~/.bash_prompt ] && source ~/.bash_prompt'
