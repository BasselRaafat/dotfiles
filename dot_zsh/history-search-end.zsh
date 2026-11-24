# Keep prefix-based Up/Down history search, but place the cursor at line end.
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

for keymap in emacs viins vicmd; do
  bindkey -M "$keymap" '^[[A' history-beginning-search-backward-end
  bindkey -M "$keymap" '^[[B' history-beginning-search-forward-end
done
