# Keybindings Cheatsheet

## Tmux (prefix: C-a)

### Session
| Key | Action |
|-----|--------|
| `C-a d` | Detach |
| `C-a C-Space` | Last session |
| `C-a C-t` | Choose tree |
| `C-a f` | Sessionx (fzf) |

### Window
| Key | Action |
|-----|--------|
| `C-a c` | New window |
| `C-a Space` | Last window |
| `C-a <` / `>` | Swap left/right |
| `M-1`..`M-5` | Switch to window 1-5 |

### Pane
| Key | Action |
|-----|--------|
| `C-a \|` | Split horizontal |
| `C-a -` | Split vertical |
| `C-a \\` | Split full-width |
| `C-a _` | Split full-height |
| `C-a h/j/k/l` | Select pane |
| `C-a H/J/K/L` | Resize pane |
| `C-a C-h/j/k/l` | Swap pane |
| `C-a b` | Break to window |
| `C-a m/M` | Merge from window |
| `C-a t` | Thumbs (pick/copy/open) |

### Copy Mode
| Key | Action |
|-----|--------|
| `C-a Escape` | Enter copy mode |
| `v` | Begin selection |
| `V` | Select line |
| `C-v` | Rectangle toggle |
| `y` | Yank and exit |
| `C-a p` | Paste |
| `C-Up/C-Down` | Jump to prompt |

### Popup
| Key | Action |
|-----|--------|
| `M-g` | Lazygit |
| `M-t` | Bottom (btm) |

### Misc
| Key | Action |
|-----|--------|
| `C-a r` | Reload config |
| `C-a g` | Menus |
| `C-a C-o` | Clear screen |
| `C-a ?` | This cheatsheet |

---

## Zsh (z4m)

### Navigation (Unified: Neovim ↔ Tmux ↔ Zsh)
| Key | Action |
|-----|--------|
| `C-h/j/k/l` | Move left/down/up/right (smart boundary) |

### Directory Navigation
| Key | Action |
|-----|--------|
| `M-h` | cd back |
| `M-l` | cd forward |
| `M-k` | cd up (parent) |
| `M-j` | cd history (fzf) |
| `Shift+←/→` | cd back/forward |
| `Shift+↑/↓` | cd up/subdirectory |

### Word Movement
| Key | Action |
|-----|--------|
| `M-b` / `M-←` | Backward word |
| `M-f` / `M-→` | Forward word |
| `C-←` / `C-→` | Backward/forward word |
| `C-M-←` / `C-M-→` | Backward/forward zword |

### Deletion
| Key | Action |
|-----|--------|
| `M-Backspace` | Kill word backward |
| `C-w` | Kill word backward |
| `M-d` / `C-Delete` | Kill word forward |
| `C-M-w` | Kill zword backward |
| `C-M-d` | Kill zword forward |
| `C-u` | Kill to line start |
| `M-u` | Kill to line end |
| `M-i` | Kill whole line |

### History & Completion
| Key | Action |
|-----|--------|
| `↑` / `↓` | History (prefix match) |
| `C-↑` / `C-↓` | Global history |
| `C-r` | Fuzzy history (atuin/fzf) |
| `Tab` | Fuzzy completion |
| `C-Space` | Expand alias/glob |

### Editing
| Key | Action |
|-----|--------|
| `M-e` | Edit in $EDITOR |
| `C-M-h` | Show command help |
| `C-/` / `Shift+Tab` | Undo |
| `M-/` | Redo |
| `C-z` | Toggle fg/bg |
| `C-d` | Exit / delete char |

---

## FZF (inside widgets)
| Key | Action |
|-----|--------|
| `C-u` / `C-d` | Preview scroll |
| `Tab` | Select multiple |
| `Enter` | Confirm |
| `Escape` | Cancel |
