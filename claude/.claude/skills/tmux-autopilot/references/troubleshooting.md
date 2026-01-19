# Troubleshooting & Edge Cases

Format: Symptom → Possible cause → Diagnosis → Fix

## Basic Issues

### `no such session` / `no current client`
→ Session name typo or not attached
→ `tmux list-sessions` to verify; create with `tmux new -s <name>` if needed
→ Retry with absolute target: `-t <s:w.p>`

### send-keys ineffective, stuck in copy-mode
→ Pane is in copy-mode
→ `tmux display-message -pt <t> '#{pane_in_mode}'`
→ `tmux send-keys -t <t> Escape` first, then send command

### Broadcast affecting unintended panes
→ `synchronize-panes` left enabled
→ `tmux show-window-options | grep synchronize`
→ `tmux set-window-option synchronize-panes off`

### Config not taking effect
→ Config not reloaded
→ Verify `~/.tmux.conf` symlink is correct
→ `C-a r` or `tmux source ~/.tmux.conf`

## Index-Related

### `-t 0:0.0` pane not found
→ Arthur's config indices start at 1
→ Use `-t <session>:1.1`
→ `tmux list-panes -a -F '#S:#I.#P'` to verify

### `M-1` to `M-5` not working
→ Terminal doesn't support Alt key or captured by another program
→ Check terminal settings, ensure Alt sends Meta
→ Fallback: `C-a 1` to `C-a 5`

## Plugin Issues

### Plugins not working
→ TPM not installed or initialized
→ Check if `~/.tmux/plugins/tpm` exists
→ Run `C-a I` to install plugins

### Sessionx (C-a f) unresponsive
→ Sessionx or fzf not installed
→ `C-a I` to install; verify fzf is in PATH
→ Check `~/.tmux/plugins/tmux-sessionx`

### Thumbs (C-a j) unresponsive
→ tmux-thumbs requires Rust compilation
→ First use triggers auto-compile, wait briefly
→ Check `~/.tmux/plugins/tmux-thumbs/target`

### Catppuccin theme abnormal
→ Terminal doesn't support true color
→ Verify `echo $TERM` shows `tmux-256color` or similar
→ Check terminal's true color support

## Popup Issues

### `M-g` / `M-t` unresponsive
→ tmux version < 3.2 doesn't support display-popup
→ `tmux -V` to check version
→ Upgrade tmux or use traditional window approach

### Popup tools (lazygit/btm) not found
→ Tools not installed
→ `brew install lazygit bottom`
→ Verify in PATH

## Display Issues

### Status bar symbols garbled
→ Font doesn't support Nerd Font icons
→ Install Nerd Font and set in terminal
→ Or disable icons in catppuccin config

### Status bar duplicated/misaligned
→ Terminal wide-character issues or config loaded multiple times
→ `tmux -f /dev/null -L test` to test clean environment
→ Verify config loads only once

### Colors incorrect
→ TERM setting wrong
→ Should be `tmux-256color`, check `echo $TERM`
→ Verify `terminal-features` settings are correct

## Copy Mode Issues

### `v` / `y` not working
→ Not in copy-mode
→ `C-a Escape` first to enter copy-mode
→ Verify `mode-keys vi` setting

### Clipboard empty after copy
→ System clipboard integration issue
→ Check `set-clipboard on` setting
→ macOS should work automatically; Linux needs xclip/xsel

## Session Recovery Issues

### Resurrect restore failed
→ Save file corrupted or missing
→ Check `~/.tmux/resurrect/` directory
→ Manually backup important session layouts

### Continuum not auto-restoring
→ First tmux launch may have delay
→ Verify `@continuum-restore 'on'`
→ Manual trigger: `C-a C-r`

## Performance Issues

### Input lag
→ escape-time set too high
→ Config already set to 0: `set -sg escape-time 0`
→ If still laggy, check network (remote tmux)

### Stuttering on heavy output
→ history-limit too large or pipe-pane performance issue
→ Config set to 50000 lines, usually sufficient
→ Use `capture-pane` on-demand instead of continuous pipe

## Debug Commands

```bash
# View all settings
tmux show -g

# View window settings
tmux show-window-options

# View key bindings
tmux list-keys

# View specific key binding
tmux list-keys | grep <key>

# Test clean environment
tmux -f /dev/null -L test

# Check tmux version
tmux -V

# View plugin directory
ls ~/.tmux/plugins/
```
