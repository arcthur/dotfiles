# tmux-autopilot References

Based on Arthur's dotfiles configuration (TPM + Catppuccin + custom keybindings)

## File Navigation

| File | Contents |
|------|----------|
| `getting_started.md` | Core terminology, config overview, quick verification |
| `api.md` | Tmux command/option reference, common format strings |
| `examples.md` | Extended script examples (inspection, recording, swarm collaboration) |
| `troubleshooting.md` | Symptom → diagnosis → fix |

## Configuration File Locations

- Main config: `~/dotfiles/tmux/.tmux.conf` (stow managed)
- Cheatsheet: `~/dotfiles/tmux/cheatsheet.md`
- TPM plugins: `~/.tmux/plugins/`
- Active config: `~/.tmux.conf` (stow symlink)

## Key Differences (vs default tmux)

| Item | Arthur's Config | Default |
|------|-----------------|---------|
| prefix | `C-a` | `C-b` |
| base-index | 1 | 0 |
| pane-base-index | 1 | 0 |
| copy-mode entry | `Escape` | `[` |
| splitting | `\|` `-` | `"` `%` |
| window switching | `M-1..5` (no prefix) | requires prefix |

## Plugin List

| Plugin | Shortcut | Function |
|--------|----------|----------|
| tpm | `C-a I` / `C-a U` | Plugin install/update |
| tmux-sessionx | `C-a f` | fzf + zoxide session picker |
| tmux-fzf | `C-a F` | fzf search window/pane/session |
| tmux-thumbs | `C-a t` | Quick copy screen content |
| tmux-yank | - | Enhanced copy |
| tmux-resurrect | `C-a C-s` / `C-a C-r` | Session save/restore |
| tmux-continuum | - | Auto save/restore |
| tmux-battery | - | Status bar battery display |
| tmux-menus | Right-click | Context menu |
| catppuccin/tmux | - | Theme |
