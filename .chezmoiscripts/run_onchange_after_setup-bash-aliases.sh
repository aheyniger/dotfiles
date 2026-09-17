#!/usr/bin/env bash
set -euo pipefail

HOOK_LINE='[ -f ~/.bash_aliases ] && source ~/.bash_aliases'
BASHRC="$HOME/.bashrc"

touch "$BASHRC"
if ! grep -qF "$HOOK_LINE" "$BASHRC"; then
    printf '\n# added by chezmoi\n%s\n' "$HOOK_LINE" >> "$BASHRC"
fi
