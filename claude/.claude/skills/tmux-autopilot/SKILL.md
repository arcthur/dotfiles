---
name: tmux-autopilot
description: "Tmux automation: read/broadcast/rescue session|window|pane. Enables AI to safely control terminals based on Arthur's dotfiles. Triggers: capture-pane, send-keys, batch inspection, swarm collaboration, stuck process rescue, keybinding lookup."
---

# tmux-autopilot Skill

Operate tmux like a seasoned sysadmin: read terminal output, send keystrokes, batch inspection, collaborate with or rescue other terminals. Based on Arthur's dotfiles (TPM + Catppuccin).

## When to Use This Skill

Trigger conditions (any one):
- Need to read/copy latest output from a tmux pane (logs, prompts, errors)
- Need to send keystrokes/commands to a specific pane (`y`, `Enter`, `Ctrl+C`, broadcast)
- Need batch inspection/takeover of multiple AI terminals (swarm collaboration, auto-rescue stuck tasks)
- Need quick recall of keybindings, prefix, or synchronized pane operations
- Need to operate lazygit/btm in popup windows

## Not For / Boundaries

- Not for non-tmux environments (create session/window/pane first if target doesn't exist)
- Don't edit `~/.tmux.conf` directly (config at `~/dotfiles/tmux/.tmux.conf`, managed by stow)
- Never blindly send destructive keys: `kill-server`, `rm -rf` require capture-pane context verification first
- If tmux version < 3.2, some features (display-popup, extended-keys) unavailable

## Quick Reference

### Configuration Overview

| Item | Value |
|------|-------|
| Prefix | `C-a` |
| Config file | `~/dotfiles/tmux/.tmux.conf` |
| Plugin manager | TPM (`~/.tmux/plugins/tpm`) |
| Theme | Catppuccin mocha |
| Window/pane base index | 1 |
| Status bar position | Top |
| Mouse | Enabled |

### Common Keybindings (prefix = C-a)

**Splitting**
```text
C-a |    Horizontal split (current directory)
C-a -    Vertical split (current directory)
C-a \    Full-width horizontal split
C-a _    Full-height vertical split
```

**Pane Operations**
```text
C-a h/j/k/l    Select pane (left/down/up/right)
C-a H/J/K/L    Resize pane (repeatable)
C-a C-h/j/k/l  Swap pane position
C-a b          Break pane to new window
C-a m/M        Merge window as pane (horizontal/vertical)
```

**Window**
```text
C-a c          New window (current directory)
C-a Space      Toggle to last window
C-a </>        Swap window position left/right
M-1 to M-5     Direct switch to window 1-5 (no prefix)
```

**Session**
```text
C-a C-Space    Toggle to last session
C-a C-t        Session/window tree
C-a f          Sessionx (fzf session picker)
C-a d          Detach
```

**Copy Mode (vi-style)**
```text
C-a Escape     Enter copy mode
v              Begin selection
V              Line selection
C-v            Rectangle selection
y              Yank and exit
C-a p          Paste
C-Up/C-Down    Jump to shell prompt
```

**Popup Tools**
```text
M-g            Lazygit (90%x90%)
M-t            Bottom/btm (80%x80%)
C-a ?          Cheatsheet (glow)
```

**Plugin Shortcuts**
```text
C-a t          Thumbs (quick copy screen content)
C-a f          Sessionx (fzf + zoxide session picker)
C-a F          Tmux-fzf (fzf search window/pane/session)
```

**Miscellaneous**
```text
C-a r          Reload config
C-a C-o        Clear screen
```

### Common Command Patterns

**Enumerate topology**
```bash
tmux list-sessions
tmux list-windows -a -F '#S:#I:#W#F'
tmux list-panes   -a -F '#S:#I.#P #{pane_current_command} #{pane_title}'
```

**Capture last 120 lines from specific pane**
```bash
tmux capture-pane -t <session>:<window>.<pane> -p -S -120
```

**Send confirmation to specific pane**
```bash
tmux send-keys -t <session>:<window>.<pane> "y" Enter
```

**Safely interrupt stuck task**
```bash
tmux capture-pane -t <session>:<window>.<pane> -p -S -20 | grep -qi "safe to interrupt" && \
  tmux send-keys -t <session>:<window>.<pane> C-c
```

**Window broadcast toggle**
```bash
tmux set-window-option synchronize-panes on
tmux set-window-option synchronize-panes off
```

**Inspect all panes and capture output**
```bash
for p in $(tmux list-panes -a -F '#S:#I.#P'); do
  tmux capture-pane -t "$p" -p -S -80 | sed "s/^/[$p] /";
done
```

**Remote rescue: detect prompt and send y**
```bash
target="main:1.1"  # Note: windows start at 1
tmux capture-pane -t "$target" -p -S -50 | grep -qi "(y/n)" && \
  tmux send-keys -t "$target" "y" Enter
```

**Create AI swarm workspace**
```bash
tmux new-session -d -s ai-hub -n commander 'bash'
tmux new-window  -t ai-hub -n worker1 'claude'
tmux new-window  -t ai-hub -n worker2 'claude'
tmux new-window  -t ai-hub -n worker3 'claude'
tmux attach -t ai-hub
```

**Record pane output to file**
```bash
tmux pipe-pane -t <session>:<window>.<pane> -o 'cat >> /tmp/tmux-<session>-<window>-<pane>.log'
```

## Rules & Constraints

- MUST: Use `capture-pane` to verify target context before sending keys; always use absolute targeting `<session>:<window>.<pane>`
- MUST: Note that window/pane indices start at 1, not 0
- MUST: Config changes via `~/dotfiles/tmux/.tmux.conf`, deploy with `stow tmux`
- SHOULD: Grep for keywords (`(y/n)`, `password`) before rescue/confirmation, only send to matching targets
- SHOULD: Enable `pipe-pane` for audit logging on long tasks; disable `synchronize-panes` immediately after broadcast
- NEVER: Send destructive commands to unknown panes; NEVER send `Ctrl+C`/`Ctrl+D` to root sessions without confirmation

## Examples

### Example 1: Auto-confirm stuck installation script
- Input: Install script stuck at `Proceed? (y/n)`, location `main:1.1` (note: windows start at 1)
- Steps:
  1) `tmux capture-pane -t main:1.1 -p -S -50 | grep -qi "(y/n)"` to verify waiting for input
  2) `tmux send-keys -t main:1.1 "y" Enter` to send confirmation
- Acceptance: Script continues, no extraneous input

### Example 2: Swarm inspection + auto-rescue
- Input: 4 AI terminals distributed across windows in session `ai-hub`
- Steps:
  1) Run Quick Reference inspection loop to collect last 80 lines and observe status
  2) Trigger remote rescue snippet to send `y` to panes matching `"(y/n)"`
  3) For panes with `Traceback` or `ERROR`, `capture-pane` to log then escalate to human
- Acceptance: Waiting terminals resume, normal tasks unaffected; inspection logs saved locally

### Example 3: Quick popup operations
- Input: Need to check git status and commit
- Steps:
  1) `M-g` to open lazygit popup
  2) Operate within lazygit
  3) `q` to exit, popup auto-closes
- Acceptance: Git operations complete, return to original pane

## FAQ

- Q: Why do window numbers start at 1 instead of 0?
  - A: Config sets `set -g base-index 1` and `setw -g pane-base-index 1`, matching keyboard layout (M-1 maps to window 1)

- Q: How to broadcast only to current window without affecting others?
  - A: Execute `set-window-option synchronize-panes on` only for current window, disable immediately after use

- Q: How to verify current working directory before remote command?
  - A: `tmux display-message -pt <target> '#{pane_current_path}'`

- Q: Why doesn't Ctrl+h/j/k/l directly switch panes?
  - A: Config uses unified navigation; these keys pass through to neovim/zsh; use `C-a h/j/k/l` for explicit pane switching

## Troubleshooting

Quick fixes (see `references/troubleshooting.md` for details):

| Symptom | Quick Fix |
|---------|-----------|
| `no such session/window/pane` | Indices start at 1, verify with `list-panes -a` |
| send-keys has no effect | `send-keys -t <t> Escape` to exit copy-mode |
| Plugins not working | `C-a I` to install plugins |

## References

- `references/index.md`: Navigation and file overview
- `references/getting_started.md`: Terminology, minimal setup steps
- `references/api.md`: Tmux commands and config options
- `references/examples.md`: Swarm protocol scripts and extended examples
- `references/troubleshooting.md`: Symptom to fix mapping

## Maintenance

- Sources: `~/dotfiles/tmux/.tmux.conf`, `~/dotfiles/tmux/cheatsheet.md`
- Last updated: 2026-01-19
- Known limits: Does not cover TPM plugin development; multi-user permission sharing requires separate handling
