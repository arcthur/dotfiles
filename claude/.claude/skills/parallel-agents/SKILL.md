---
name: parallel-agents
description: "Git worktree + tmux orchestration for parallel AI agents (Claude Code, Codex, OpenCode). Enables isolated development environments with status monitoring. Triggers: worktree, swarm, parallel agents, spawn, isolate, merge branch, agent status, inspect agents, rescue stuck."
---

# parallel-agents Skill

Orchestrate multiple AI coding agents in parallel using git worktrees for isolation and tmux for management. Supports Claude Code, Codex, and OpenCode.

## When to Use This Skill

Trigger conditions (any one):
- Need to run multiple AI agents on different tasks simultaneously
- Need isolated file system for each agent (worktree, not just branch)
- Need to monitor/inspect status of multiple running agents
- Need to rescue stuck agents waiting for confirmation
- Need to merge completed worktree branches back to main

## Not For / Boundaries

- Single-agent workflows (no parallelism needed)
- Branch-only isolation (use regular git branches)
- Non-tmux environments (requires tmux session)
- Editing tmux config (see tmux-autopilot skill)

## Relationship with tmux-autopilot

| This Skill (parallel-agents) | tmux-autopilot |
|------------------------------|----------------|
| High-level: worktree + agent workflows | Low-level: tmux primitives |
| When to use: "spawn 3 agents", "inspect swarm" | When to use: "capture pane", "send keys" |
| Knows about: git worktree, agent patterns | Knows about: keybindings, session topology |

Use **parallel-agents** when orchestrating multiple AI agents.
Use **tmux-autopilot** for direct tmux operations or when this skill references tmux commands you need help with.

## Quick Reference

### Supported Agents

| Agent | Command | Status Detection |
|-------|---------|------------------|
| Claude Code | `claude` | Full support |
| Codex | `codex` | Full support |
| OpenCode | `opencode` | Full support |

### Window Naming Convention

All worktree windows use prefix `wm-`:
- `wm-feature-auth` - worktree for auth feature
- `wm-fix-bug-123` - worktree for bug fix

### Directory Structure

```
project/
├── .git/
├── src/
└── ../project__worktrees/      # Sibling directory
    ├── feature-auth/           # Isolated worktree
    └── fix-bug-123/            # Another worktree
```

## Core Operations

### 1. Create Worktree + Agent

Create isolated environment with new branch:

```bash
# 1. Create worktree with new branch
git worktree add -b "feature-name" "../${PWD##*/}__worktrees/feature-name"

# 2. Create tmux window in worktree directory
tmux new-window -n "wm-feature-name" -c "../${PWD##*/}__worktrees/feature-name"

# 3. Start agent in the new window
session=$(tmux display-message -p '#S')
tmux send-keys -t "$session:wm-feature-name.1" "claude" Enter
```

For existing branch:
```bash
git worktree add "../${PWD##*/}__worktrees/feature-name" "feature-name"
```

### 2. List All Worktrees

```bash
# Git worktrees
git worktree list

# Tmux windows (worktree-related)
tmux list-windows -F '#I:#W' | grep 'wm-'
```

### 3. Inspect Agent Status

Detect agent state by capturing pane content:

```bash
# Capture last 50 lines (prefer absolute target for reliability)
session=$(tmux display-message -p '#S')
tmux capture-pane -t "$session:2.1" -p -S -50
```

**Status Detection Patterns:**

| Status | Pattern | Meaning |
|--------|---------|---------|
| waiting | `(y/n)`, `[Y/n]`, `approve`, `confirm` | Needs user input |
| working | `Reading`, `Writing`, `Bash`, `executing` | Actively processing |
| done | Last non-empty line matches prompt-only pattern (`$`/`>`) | Back to shell prompt |
| error | `error`, `exception`, `traceback`, `failed` | Hit an error |

### 4. Batch Inspect All Agents

```bash
# List all worktree windows and their status
session=$(tmux display-message -p '#S')  # Current session name

for w in $(tmux list-windows -F '#I:#W' | grep 'wm-'); do
  window_idx="${w%%:*}"
  window_name="${w#*:}"
  pane_target="$session:$window_idx.1"  # Absolute targeting
  content=$(tmux capture-pane -t "$pane_target" -p -S -30)

  # Detect status (priority: error > waiting > working > done > idle)
  prompt_re='^[A-Za-z0-9_@:/~._ -]*[$>][[:space:]]*$'
  last_line=$(echo "$content" | grep -v '^$' | tail -1)

  if echo "$content" | grep -qiE '(error|exception|traceback|FAILED|Permission denied)'; then
    status="error"
  elif echo "$content" | grep -qiE '(\(y/n\)|\[Y/n\]|\[y/N\]|approve|confirm|AskUserQuestion)'; then
    status="waiting"
  elif echo "$content" | grep -qiE '(Reading|Writing|Bash\(|executing|processing|Searching)'; then
    status="working"
  elif echo "$last_line" | grep -qE "$prompt_re"; then
    status="done"
  else
    status="idle"
  fi

  echo "[$status] $window_name"
done
```

> **Detection Priority**: error > waiting > working > done > idle
> - Error takes highest priority (agent hit a problem)
> - Waiting before working (user action needed even if agent was working)
> - Shell prompt at end indicates done

### 5. Rescue Stuck Agent

Send confirmation to waiting agent:

```bash
# Get current session for absolute targeting
session=$(tmux display-message -p '#S')

# First verify it's waiting (use window index, not name, for reliability)
# Find window index: tmux list-windows -F '#I:#W' | grep 'wm-feature-name'
tmux capture-pane -t "$session:2.1" -p -S -20 | grep -qiE '(\(y/n\)|\[Y/n\])'

# Then send "y" + Enter
tmux send-keys -t "$session:2.1" "y" Enter
```

> **Note**: Window name targeting (`wm-feature-name.1`) works but window index (`$session:2.1`) is more reliable. Use `tmux list-windows -F '#I:#W'` to find the index.

**Batch rescue all waiting agents:**

```bash
session=$(tmux display-message -p '#S')

for w in $(tmux list-windows -F '#I:#W' | grep 'wm-'); do
  window_idx="${w%%:*}"
  pane_target="$session:$window_idx.1"
  content=$(tmux capture-pane -t "$pane_target" -p -S -30)

  if echo "$content" | grep -qiE '(\(y/n\)|\[Y/n\]|\[y/N\]|approve|confirm)'; then
    tmux send-keys -t "$pane_target" "y" Enter
    echo "Rescued: ${w#*:}"
  fi
done
```

### 6. Merge Worktree Branch

```bash
# 1. Switch to main branch (in main worktree)
git checkout main

# 2. Merge the feature branch
git merge "feature-name"

# 3. Cleanup (see Remove Worktree)
```

### 7. Remove Worktree

```bash
# 1. Close tmux window
session=$(tmux display-message -p '#S')
tmux kill-window -t "$session:wm-feature-name" 2>/dev/null

# 2. Remove worktree (safe by default)
git worktree remove "../${PWD##*/}__worktrees/feature-name"

# 3. If it fails due to uncommitted changes, confirm then:
# git worktree remove "../${PWD##*/}__worktrees/feature-name" --force

# 4. Optionally delete branch (only after verifying merge)
git branch -d "feature-name"
```

## Agent-Specific Patterns

### Claude Code

```
WAITING:  "AskUserQuestion", "(y/n)", "approve", "Confirm"
WORKING:  "Reading file", "Writing to", "Bash(", "Searching"
DONE:     last non-empty line matches prompt-only pattern ($/>)
ERROR:    "Error:", "failed", "Permission denied"
```

### Codex

```
WAITING:  "Interrupt", "confirm", "Continue?"
WORKING:  "executing", "processing", "analyzing"
DONE:     last non-empty line matches prompt-only pattern ($/>)
ERROR:    "Error", "Exception", "FAILED"
```

### OpenCode

```
WAITING:  "input", "confirm", "[y/N]"
WORKING:  "running", "analyzing", "generating"
DONE:     last non-empty line matches prompt-only pattern ($/>)
ERROR:    "error", "failed", "Traceback"
```

## Configuration

### Project Config (.parallel-agents.yaml)

> **Note**: This is a convention file for AI reference, not auto-parsed.
> When AI creates worktrees, it should read this file if present and follow the settings.

Place in project root for project-specific settings:

```yaml
# Default agent to use
agent: claude

# Worktree directory (relative to project)
worktree_dir: "../{project}__worktrees"

# Tmux window prefix
window_prefix: "wm-"

# Status icons for tmux window names
status_icons:
  waiting: "..."
  working: ">>>"
  done: "OK"
  error: "ERR"

# Files to handle when creating worktree
files:
  # Copy these files (secrets, local config)
  copy:
    - .env
    - .env.local
  # Symlink these (large, shared)
  symlink:
    - node_modules
    - .pnpm-store
    - vendor
```

### File Operations After Worktree Creation

**Copy secrets/local config:**
```bash
cp .env "../${PWD##*/}__worktrees/feature-name/.env"
```

**Symlink node_modules (if package.json identical):**
```bash
ln -s "$(pwd)/node_modules" "../${PWD##*/}__worktrees/feature-name/node_modules"
```

## Status Display (tmux integration)

Update tmux window option for status display:

```bash
# Set status icon (shown in window name via @workmux_status)
session=$(tmux display-message -p '#S')
tmux set-option -t "$session:wm-feature-name" @workmux_status "..."
```

Your tmux.conf already has:
```
set -g @catppuccin_window_text " #W#{?@workmux_status, #{@workmux_status},}"
```

## Rules & Constraints

- MUST: Use absolute pane targeting `session:window.pane` (e.g., `main:2.1`)
- MUST: Window/pane indices start at 1 (Arthur's tmux config)
- MUST: Verify pane content before sending rescue keys
- SHOULD: Avoid `--force` with `git worktree remove` unless user confirms data loss
- SHOULD: Close tmux window before removing worktree
- NEVER: Remove worktree without user confirmation if it has uncommitted changes
- NEVER: Send destructive keys (`Ctrl+C`, `exit`) without verifying context

## Examples

### Example 1: Spawn 3 parallel feature agents

```bash
# Create 3 worktrees for parallel work
session=$(tmux display-message -p '#S')

for feature in auth payments notifications; do
  git worktree add -b "feature-$feature" "../myproject__worktrees/feature-$feature"
  tmux new-window -n "wm-feature-$feature" -c "../myproject__worktrees/feature-$feature"
  tmux send-keys -t "$session:wm-feature-$feature.1" "claude" Enter
done
```

### Example 2: Inspect and report status

```bash
echo "=== Agent Status Report ==="
session=$(tmux display-message -p '#S')

for w in $(tmux list-windows -F '#I:#W' | grep 'wm-'); do
  idx="${w%%:*}"; name="${w#*:}"
  pane="$session:$idx.1"
  content=$(tmux capture-pane -t "$pane" -p -S -30)

  # Priority: error > waiting > working > done > idle
  prompt_re='^[A-Za-z0-9_@:/~._ -]*[$>][[:space:]]*$'
  last_line=$(echo "$content" | grep -v '^$' | tail -1)

  if echo "$content" | grep -qiE '(error|exception|traceback|FAILED)'; then
    echo "[ERROR]   $name - check logs"
  elif echo "$content" | grep -qiE '(\(y/n\)|\[Y/n\]|approve|confirm)'; then
    echo "[WAITING] $name - needs input"
  elif echo "$content" | grep -qiE '(Reading|Writing|Bash\(|executing)'; then
    echo "[WORKING] $name - in progress"
  elif echo "$last_line" | grep -qE "$prompt_re"; then
    echo "[DONE]    $name"
  else
    echo "[IDLE]    $name"
  fi
done
```

### Example 3: Complete workflow

```bash
# 1. Create worktree
git worktree add -b "fix-login-bug" "../myproject__worktrees/fix-login-bug"
tmux new-window -n "wm-fix-login-bug" -c "../myproject__worktrees/fix-login-bug"
cp .env "../myproject__worktrees/fix-login-bug/"
session=$(tmux display-message -p '#S')
tmux send-keys -t "$session:wm-fix-login-bug.1" "claude 'Fix the login timeout bug in auth.ts'" Enter

# 2. Monitor progress (periodically)
tmux capture-pane -t "$session:wm-fix-login-bug.1" -p -S -30

# 3. After agent completes, merge
git checkout main
git merge fix-login-bug

# 4. Cleanup
session=$(tmux display-message -p '#S')
tmux kill-window -t "$session:wm-fix-login-bug"
git worktree remove "../myproject__worktrees/fix-login-bug"
# If removal fails due to uncommitted changes, confirm then:
# git worktree remove "../myproject__worktrees/fix-login-bug" --force
git branch -d fix-login-bug
```

## FAQ

**Q: Why worktrees instead of branches?**
A: Worktrees provide complete file system isolation. Multiple agents can edit the same file simultaneously without conflicts until merge time.

**Q: How to handle merge conflicts?**
A: Resolve conflicts in the main worktree after `git merge`. The agent's worktree remains intact for reference until you remove it.

**Q: Can I use different agents in different worktrees?**
A: Yes. Specify the agent command when starting: `claude`, `codex`, or `opencode`.

**Q: What if an agent crashes?**
A: The worktree and branch remain intact. Start a new agent in the same window or investigate the error.

**Q: How to see full agent output history?**
A: Use tmux scrollback: `C-a [` then scroll up, or `tmux capture-pane -t target -p -S -10000 > output.log`

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `fatal: 'branch' is already checked out` | Use different branch name or remove existing worktree first |
| `window not found` | Check window name with `tmux list-windows`; indices start at 1 |
| Status always "idle" | Agent may have exited; check with `tmux capture-pane` |
| Symlink node_modules fails | Ensure source exists and path is absolute |

## References

- `references/index.md` - Navigation
- `references/worktree-api.md` - Git worktree commands
- `references/agent-detection.md` - Detailed detection patterns
- `references/pane-layouts.md` - Multi-pane layouts
- `references/examples.md` - Extended workflow examples
