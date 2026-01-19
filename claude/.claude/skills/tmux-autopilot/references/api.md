# API / CLI / Config Reference

## Structured Quick Reference (by scenario)

### Topology & Targeting

```bash
# List sessions
tmux list-sessions

# List windows (with flags)
tmux list-windows -a -F '#S:#I:#W#F'

# List panes (with command and title)
tmux list-panes -a -F '#S:#I.#P #{pane_current_command} #{pane_title}'

# Get current pane working directory
tmux display-message -pt <s:w.p> '#{pane_current_path}'

# Check if pane is in copy-mode
tmux display-message -pt <s:w.p> '#{pane_in_mode}'
```

### Reading Output

```bash
# Capture last N lines
tmux capture-pane -t <s:w.p> -p -S -120

# Full capture to file
tmux capture-pane -t <s:w.p> -p -S -100000 > pane.log

# Real-time mirror to file
tmux pipe-pane -t <s:w.p> -o 'cat >> /tmp/pane.log'

# Stop mirroring
tmux pipe-pane -t <s:w.p>
```

### Sending Keys/Commands

```bash
# Send string + Enter
tmux send-keys -t <s:w.p> "command here" Enter

# Send single key
tmux send-keys -t <s:w.p> C-c       # Ctrl+C
tmux send-keys -t <s:w.p> Escape    # Escape
tmux send-keys -t <s:w.p> Space     # Space
tmux send-keys -t <s:w.p> Tab       # Tab

# Send confirmation
tmux send-keys -t <s:w.p> "y" Enter

# Exit copy-mode before sending
tmux send-keys -t <s:w.p> Escape
```

### Broadcast / Synchronize

```bash
# Enable current window broadcast
tmux set-window-option synchronize-panes on

# Disable broadcast (do this immediately after!)
tmux set-window-option synchronize-panes off

# Check broadcast status
tmux show-window-options | grep synchronize
```

### Session/Window/Pane Management

```bash
# New session (background)
tmux new-session -d -s <name> -n <win> 'cmd'

# New window
tmux new-window -t <s> -n <name> 'cmd'

# Split (Arthur's config uses | - \ _, CLI version)
tmux split-window -t <s:w> -h          # Horizontal
tmux split-window -t <s:w> -v          # Vertical
tmux split-window -t <s:w> -fh         # Full-width horizontal
tmux split-window -t <s:w> -fv         # Full-height vertical

# Rename window
tmux rename-window -t <s:w> <new>

# Select pane
tmux select-pane -t <s:w.p>

# Resize pane
tmux resize-pane -t <s:w.p> -L 5       # Left
tmux resize-pane -t <s:w.p> -R 5       # Right
tmux resize-pane -t <s:w.p> -U 5       # Up
tmux resize-pane -t <s:w.p> -D 5       # Down
```

### Popup Windows

```bash
# Open popup (Arthur's config example)
tmux display-popup -T " Title " -w 80% -h 80% -E "command"

# Example: temporary shell
tmux display-popup -E "bash"
```

## Common Format Strings

| Variable | Meaning |
|----------|---------|
| `#S` | Session name |
| `#I` | Window index |
| `#W` | Window name |
| `#P` | Pane index |
| `#F` | Window flags |
| `#{pane_current_path}` | Pane current directory |
| `#{pane_current_command}` | Pane current command |
| `#{pane_in_mode}` | Whether in copy-mode |
| `#{pane_title}` | Pane title |

## Key Config Settings (Arthur's)

```bash
# Prefix
set -g prefix C-a

# Index starts at 1
set -g base-index 1
setw -g pane-base-index 1

# Vi mode
set -g status-keys vi
setw -g mode-keys vi

# Copy-mode entry/exit
bind Escape copy-mode      # C-a Escape to enter
bind p paste-buffer        # C-a p to paste

# Splitting
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Reload config
bind r source-file ~/.tmux.conf \; display "Configuration reloaded"
```

## Common Mistakes & Fixes

| Mistake | Fix |
|---------|-----|
| Using `-t 0` hitting wrong pane | Always use `<s:w.p>` full targeting, indices start at 1 |
| Broadcast left enabled | Disable `synchronize-panes off` immediately after use |
| send-keys ineffective | Check if in copy-mode, `send-keys Escape` to exit |
| Config not applied | `C-a r` reload or `tmux source ~/.tmux.conf` |
| Plugins not working | `C-a I` to install plugins |
