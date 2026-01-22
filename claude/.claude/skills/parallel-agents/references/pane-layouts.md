# Pane Layout Reference

## Overview

Configure tmux pane layouts for worktree windows. Layouts define how to split the window and what commands to run in each pane.

## Layout Specification

### YAML Format

```yaml
# Layout name (filename without .yaml)
panes:
  - command: <agent>        # First pane (main)
    focus: true             # Receives initial focus
  - command: npm run dev    # Second pane
    split: horizontal       # Split direction
    size: 12                # Size in lines/columns
```

### Pane Properties

| Property | Type | Description |
|----------|------|-------------|
| `command` | string | Command to run (use `<agent>` for agent placeholder) |
| `split` | string | `horizontal` or `vertical` |
| `size` | number | Absolute size in lines (h) or columns (v) |
| `percentage` | number | Size as percentage (1-100) |
| `focus` | boolean | Set initial focus to this pane |

### Placeholders

| Placeholder | Replaced With |
|-------------|---------------|
| `<agent>` | Agent command (claude, codex, opencode) |
| `<branch>` | Branch/worktree name |
| `<project>` | Project directory name |

## Built-in Layouts

### default

Agent only, full window.

```yaml
panes:
  - command: <agent>
    focus: true
```

### agent-with-server

Agent + dev server.

```yaml
panes:
  - command: <agent>
    focus: true
  - command: npm run dev
    split: horizontal
    size: 12
```

### agent-with-logs

Agent + log tailing.

```yaml
panes:
  - command: <agent>
    focus: true
  - command: tail -f logs/app.log
    split: horizontal
    size: 15
```

### agent-with-tests

Agent + test watcher.

```yaml
panes:
  - command: <agent>
    focus: true
  - command: npm run test:watch
    split: horizontal
    percentage: 30
```

### full-stack

Agent + server + logs.

```yaml
panes:
  - command: <agent>
    focus: true
  - command: npm run dev
    split: horizontal
    size: 10
  - command: tail -f logs/app.log
    split: vertical
    percentage: 50
```

## Creating Layouts with tmux Commands

### Basic Two-Pane (Horizontal)

```
┌─────────────────────────┐
│        Agent            │
├─────────────────────────┤
│      Dev Server         │
└─────────────────────────┘
```

```bash
# Create window with agent
tmux new-window -n "wm-feature" -c "$WORKTREE_PATH"
session=$(tmux display-message -p '#S')
tmux send-keys -t "$session:wm-feature.1" "claude" Enter

# Split horizontally, 12 lines for bottom pane
tmux split-window -t "$session:wm-feature" -v -l 12 -c "$WORKTREE_PATH"
tmux send-keys -t "$session:wm-feature.2" "npm run dev" Enter

# Focus back to agent pane
tmux select-pane -t "$session:wm-feature.1"
```

### Basic Two-Pane (Vertical)

```
┌────────────┬────────────┐
│            │            │
│   Agent    │   Logs     │
│            │            │
└────────────┴────────────┘
```

```bash
# Create window with agent
tmux new-window -n "wm-feature" -c "$WORKTREE_PATH"
session=$(tmux display-message -p '#S')
tmux send-keys -t "$session:wm-feature.1" "claude" Enter

# Split vertically, 40% for right pane
tmux split-window -t "$session:wm-feature" -h -p 40 -c "$WORKTREE_PATH"
tmux send-keys -t "$session:wm-feature.2" "tail -f logs/app.log" Enter

# Focus back to agent pane
tmux select-pane -t "$session:wm-feature.1"
```

### Three-Pane L-Shape

```
┌─────────────────────────┐
│        Agent            │
├────────────┬────────────┤
│   Server   │   Logs     │
└────────────┴────────────┘
```

```bash
# Create window with agent
tmux new-window -n "wm-feature" -c "$WORKTREE_PATH"
session=$(tmux display-message -p '#S')
tmux send-keys -t "$session:wm-feature.1" "claude" Enter

# Split horizontally for bottom section
tmux split-window -t "$session:wm-feature" -v -l 12 -c "$WORKTREE_PATH"
tmux send-keys -t "$session:wm-feature.2" "npm run dev" Enter

# Split bottom pane vertically
tmux split-window -t "$session:wm-feature.2" -h -p 50 -c "$WORKTREE_PATH"
tmux send-keys -t "$session:wm-feature.3" "tail -f logs/app.log" Enter

# Focus back to agent pane
tmux select-pane -t "$session:wm-feature.1"
```

### Four-Pane Grid

```
┌────────────┬────────────┐
│   Agent    │   Tests    │
├────────────┼────────────┤
│   Server   │   Logs     │
└────────────┴────────────┘
```

```bash
# Create window with agent
tmux new-window -n "wm-feature" -c "$WORKTREE_PATH"
session=$(tmux display-message -p '#S')
tmux send-keys -t "$session:wm-feature.1" "claude" Enter

# Split into 4 panes
tmux split-window -t "$session:wm-feature" -h -p 50 -c "$WORKTREE_PATH"
tmux split-window -t "$session:wm-feature.1" -v -p 50 -c "$WORKTREE_PATH"
tmux split-window -t "$session:wm-feature.2" -v -p 50 -c "$WORKTREE_PATH"

# Start commands
tmux send-keys -t "$session:wm-feature.2" "npm run test:watch" Enter
tmux send-keys -t "$session:wm-feature.3" "npm run dev" Enter
tmux send-keys -t "$session:wm-feature.4" "tail -f logs/app.log" Enter

# Focus agent pane
tmux select-pane -t "$session:wm-feature.1"
```

## tmux Split Commands Reference

### split-window

```bash
tmux split-window [options] [command]
```

| Option | Description |
|--------|-------------|
| `-v` | Vertical split (panes stacked) |
| `-h` | Horizontal split (panes side by side) |
| `-l N` | Size in lines (v) or columns (h) |
| `-p N` | Size as percentage |
| `-c PATH` | Start directory |
| `-t TARGET` | Target pane |

### select-pane

```bash
tmux select-pane -t TARGET
```

### Pane Numbering

With `pane-base-index 1` (Arthur's config):

```
Single pane:  .1

Two panes (horizontal):
┌───┐
│ 1 │
├───┤
│ 2 │
└───┘

Two panes (vertical):
┌───┬───┐
│ 1 │ 2 │
└───┴───┘
```

## Project-Specific Layout

Create `.parallel-agents.yaml` in project root:

```yaml
# Use built-in layout
layout: agent-with-server

# Or define custom
layout:
  panes:
    - command: <agent>
      focus: true
    - command: docker-compose logs -f
      split: horizontal
      size: 15
```

## Layout Generation Script

```bash
#!/usr/bin/env bash
# apply_layout.sh
# Usage: apply_layout.sh <session:window> <layout_name> <agent>

WINDOW="$1"
LAYOUT="${2:-default}"
AGENT="${3:-claude}"
if [[ "$WINDOW" != *:* ]]; then
  echo "Usage: $0 <session:window> <layout_name> <agent>"
  exit 1
fi
WORKTREE_PATH=$(tmux display-message -t "$WINDOW" -p '#{pane_current_path}')

case "$LAYOUT" in
  default)
    tmux send-keys -t "$WINDOW.1" "$AGENT" Enter
    ;;

  agent-with-server)
    tmux send-keys -t "$WINDOW.1" "$AGENT" Enter
    tmux split-window -t "$WINDOW" -v -l 12 -c "$WORKTREE_PATH"
    tmux send-keys -t "$WINDOW.2" "npm run dev" Enter
    tmux select-pane -t "$WINDOW.1"
    ;;

  agent-with-tests)
    tmux send-keys -t "$WINDOW.1" "$AGENT" Enter
    tmux split-window -t "$WINDOW" -v -p 30 -c "$WORKTREE_PATH"
    tmux send-keys -t "$WINDOW.2" "npm run test:watch" Enter
    tmux select-pane -t "$WINDOW.1"
    ;;

  *)
    echo "Unknown layout: $LAYOUT"
    exit 1
    ;;
esac
```

## See Also

- [SKILL.md](../SKILL.md) - Main skill guide
- [examples.md](examples.md) - Complete workflow examples
- tmux-autopilot skill - Low-level tmux operations
