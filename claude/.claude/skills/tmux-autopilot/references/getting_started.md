# Getting Started & Vocabulary

## Core Terminology

1. **session**: Outermost tmux container, can detach/attach
2. **window**: Tab within a session, addressed as `<session>:<window>` (starts at 1)
3. **pane**: Split within a window, addressed as `<session>:<window>.<pane>` (starts at 1)
4. **prefix**: Key combination prefix, configured as `C-a`
5. **capture-pane**: Capture pane output to stdout
6. **send-keys**: Inject keystrokes/commands to a pane
7. **synchronize-panes**: Window-level broadcast toggle
8. **pipe-pane**: Stream pane output to a command/file
9. **copy-mode**: Built-in scroll/copy mode (vi-style)
10. **TPM**: Tmux Plugin Manager

## Configuration Overview

```text
Config file: ~/dotfiles/tmux/.tmux.conf (stow → ~/.tmux.conf)
Prefix:      C-a
Indexing:    Windows and panes both start at 1
Theme:       Catppuccin mocha
Plugins:     TPM managed
```

## Quick Verification (existing config)

```bash
# 1) Verify tmux version >= 3.2 (required for popup and extended-keys)
tmux -V

# 2) Verify config is active
tmux show -g prefix   # Should show C-a

# 3) Start session and verify
tmux new -s demo
# Press C-a ? to open cheatsheet popup

# 4) Basic self-test
tmux list-windows
tmux capture-pane -t demo:1.1 -p -S -10
tmux send-keys -t demo:1.1 "echo ok" Enter
```

## Best Practices

- Always use absolute targeting `<session>:<window>.<pane>`; safer for cross-session operations
- Build whitelist before batch broadcast: `tmux list-panes -a -F '#S:#I.#P #{pane_current_command}'`
- High-risk keys (`Ctrl+C`, confirmation `y`) require `capture-pane` verification first
- Use `pipe-pane` for audit logging on long tasks; close after rescue/interrupt
- Remember: indices start at 1, not 0

## Common Popups

| Shortcut | Tool | Purpose |
|----------|------|---------|
| `M-g` | lazygit | Git operations |
| `M-t` | btm | System monitoring |
| `C-a ?` | glow | Cheatsheet |

## Plugin Shortcuts

| Shortcut | Plugin | Function |
|----------|--------|----------|
| `C-a f` | sessionx | fzf + zoxide session picker |
| `C-a F` | tmux-fzf | fzf search window/pane/session |
| `C-a j` | thumbs | Quick copy screen content |
| `C-a C-s` | resurrect | Save session |
| `C-a C-r` | resurrect | Restore session |
| `C-a I` | tpm | Install plugins |
| `C-a U` | tpm | Update plugins |
