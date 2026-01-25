# Agent Status Detection Reference

## Overview

Detect AI agent status by analyzing tmux pane content. This document provides detailed patterns for each supported agent.

## Detection Strategy

### Multi-Layer Approach

1. **Pattern Matching** (primary) - Regex on captured pane content
2. **Output Rate** (secondary) - High activity = working
3. **Time Heuristics** (fallback) - Long idle = likely waiting or done

### Capture Command

```bash
# Capture last N lines from pane (prefer absolute target)
tmux capture-pane -t "session:window.pane" -p -S -N

# Examples
tmux capture-pane -t "main:2.1" -p -S -50    # Last 50 lines
tmux capture-pane -t "dev:3.1" -p -S -100    # Last 100 lines
```

## Claude Code Patterns

### Status: Waiting for Input

**Triggers:**
```regex
AskUserQuestion
\(y/n\)
\[Y/n\]
\[y/N\]
approve|Approve
confirm|Confirm
Do you want to
Would you like to
Press Enter to continue
waiting for.*input
```

**Example Output:**
```
Do you want to proceed with these changes? (y/n)
```

### Status: Working

**Triggers:**
```regex
Reading\s+file
Writing\s+to
Bash\(
Searching\s+for
Analyzing
Editing
Creating\s+file
Running\s+command
```

**Example Output:**
```
Reading file: src/components/Auth.tsx
Writing to: src/utils/helpers.ts
Bash(npm test)
```

### Status: Done

**Triggers (prompt-only line preferred):**
```regex
^[A-Za-z0-9_@:/~._ -]*[$>][[:space:]]*$
```

**Example Output:**
```
Changes applied successfully.
$
```

### Status: Error

**Triggers:**
```regex
Error:
ERROR
failed|Failed|FAILED
Permission denied
command not found
TypeError|SyntaxError|ReferenceError
Traceback
Exception
```

## Codex Patterns

### Status: Waiting for Input

**Triggers:**
```regex
Interrupt
Continue\?
confirm
\[y/N\]
Press.*to continue
Waiting for
```

### Status: Working

**Triggers:**
```regex
executing
processing
analyzing
generating
Thinking\.\.\.
```

### Status: Done

**Triggers (prompt-only line preferred):**
```regex
^[A-Za-z0-9_@:/~._ -]*[$>][[:space:]]*$
```

### Status: Error

**Triggers:**
```regex
Error
Exception
FAILED
Traceback
```

## OpenCode Patterns

### Status: Waiting for Input

**Triggers:**
```regex
input
confirm
\[y/N\]
\[Y/n\]
>.*\?
```

### Status: Working

**Triggers:**
```regex
running
analyzing
generating
Processing
```

### Status: Done

**Triggers (prompt-only line preferred):**
```regex
^[A-Za-z0-9_@:/~._ -]*[$>][[:space:]]*$
```

### Status: Error

**Triggers:**
```regex
error
failed
Traceback
Exception
```

## Universal Detection Script

```bash
#!/usr/bin/env bash
# detect_agent_status.sh
# Usage: detect_agent_status.sh <pane_target>

set -euo pipefail

PANE="${1:-}"
if [[ -z "$PANE" ]]; then
  echo "Usage: $0 <session:window.pane>"
  exit 1
fi

content=$(tmux capture-pane -t "$PANE" -p -S -50 2>/dev/null || echo "")

if [[ -z "$content" ]]; then
  echo "empty"
  exit 0
fi

# Priority order: error > waiting > working > done > unknown

# Check for errors first
if echo "$content" | grep -qiE '(error|exception|traceback|failed|FAILED|Permission denied)'; then
  echo "error"
  exit 0
fi

# Check for waiting
if echo "$content" | grep -qiE '(\(y/n\)|\[Y/n\]|\[y/N\]|approve|confirm|AskUserQuestion|Continue\?|waiting for)'; then
  echo "waiting"
  exit 0
fi

# Check for working
if echo "$content" | grep -qiE '(Reading|Writing|Bash\(|executing|processing|analyzing|Searching|Thinking)'; then
  echo "working"
  exit 0
fi

# Check for done (shell prompt on last non-empty line)
prompt_re='^[A-Za-z0-9_@:/~._ -]*[$>][[:space:]]*$'
last_line=$(echo "$content" | grep -v '^$' | tail -1)
if echo "$last_line" | grep -qE "$prompt_re"; then
  echo "done"
  exit 0
fi

echo "unknown"
```

## Batch Inspection

For batch inspection of all worktree windows, see [SKILL.md Core Operations: Batch Inspect All Agents](../SKILL.md#4-batch-inspect-all-agents).

## Status Update in tmux

Update window status for display:

```bash
# Set status icon
session=$(tmux display-message -p '#S')
tmux set-option -t "$session:wm-feature-name" @workmux_status "..."

# Clear status
tmux set-option -t "$session:wm-feature-name" -u @workmux_status
```

### Status Icons

| Status | Default Icon | Meaning |
|--------|--------------|---------|
| waiting | `...` | Needs user input |
| working | `>>>` | Actively processing |
| done | `OK` | Completed |
| error | `ERR` | Hit an error |
| unknown | `-` | Can't determine |

## Troubleshooting

### False Positives

**"waiting" when actually working:**
- Agent output contains words like "confirm" in different context
- Solution: Check last few lines only, not full buffer

**"done" when still working:**
- Agent printed a `$` in output (e.g., variable interpolation)
- Solution: Check if line starts with typical prompt pattern

### False Negatives

**"unknown" when should be "working":**
- Agent uses different terminology
- Solution: Add agent-specific patterns

### No Output Captured

```bash
# Verify pane exists
tmux list-panes -a | grep "target"

# Check pane is not in copy mode
tmux send-keys -t "target" Escape
```

## Integration Notes

This detection system works with tmux-autopilot skill. For low-level tmux operations, refer to that skill.

See [SKILL.md](../SKILL.md) for complete workflow integration.
