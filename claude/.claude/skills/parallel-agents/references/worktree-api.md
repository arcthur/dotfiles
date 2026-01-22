# Git Worktree API Reference

## Overview

Git worktrees allow multiple working directories attached to a single repository. Each worktree has its own checked-out branch, enabling true parallel development.

## Commands

### git worktree add

Create a new worktree.

```bash
# Create worktree with new branch
git worktree add -b <new-branch> <path>

# Create worktree for existing branch
git worktree add <path> <existing-branch>

# Create worktree with detached HEAD
git worktree add --detach <path> <commit>
```

**Examples:**

```bash
# New branch from current HEAD
git worktree add -b feature-auth ../project__worktrees/feature-auth

# New branch from specific commit
git worktree add -b hotfix-v2 ../project__worktrees/hotfix-v2 v2.0.0

# Existing branch
git worktree add ../project__worktrees/develop develop
```

**Options:**

| Option | Description |
|--------|-------------|
| `-b <branch>` | Create new branch |
| `-B <branch>` | Create or reset branch |
| `--detach` | Detached HEAD |
| `--checkout` | Checkout after adding (default) |
| `--no-checkout` | Don't checkout |
| `--lock` | Lock worktree after creation |

### git worktree list

List all worktrees.

```bash
git worktree list
git worktree list --porcelain  # Machine-readable
```

**Output format:**

```
/path/to/main       abc1234 [main]
/path/to/feature-a  def5678 [feature-a]
/path/to/feature-b  ghi9012 [feature-b]
```

**Porcelain format:**

```
worktree /path/to/main
HEAD abc1234abc1234abc1234abc1234abc1234abc123
branch refs/heads/main

worktree /path/to/feature-a
HEAD def5678def5678def5678def5678def5678def567
branch refs/heads/feature-a
```

### git worktree remove

Remove a worktree.

```bash
git worktree remove <worktree>
git worktree remove --force <worktree>  # Even with uncommitted changes
```

**Examples:**

```bash
# Safe remove (fails if dirty)
git worktree remove ../project__worktrees/feature-auth

# Force remove (discards changes)
git worktree remove --force ../project__worktrees/feature-auth
```

### git worktree prune

Clean up stale worktree entries.

```bash
git worktree prune
git worktree prune --dry-run  # Show what would be pruned
git worktree prune --verbose  # Show details
```

### git worktree lock/unlock

Prevent/allow worktree removal.

```bash
# Lock worktree
git worktree lock <worktree>
git worktree lock --reason "In use by CI" <worktree>

# Unlock worktree
git worktree unlock <worktree>
```

### git worktree move

Move a worktree to new location.

```bash
git worktree move <worktree> <new-path>
```

### git worktree repair

Repair worktree administrative files.

```bash
git worktree repair
git worktree repair <path>...
```

## Directory Structure Best Practices

### Recommended Layout

```
~/projects/
├── myproject/                    # Main worktree (git clone location)
│   ├── .git/
│   ├── src/
│   └── ...
└── myproject__worktrees/         # Sibling directory for worktrees
    ├── feature-auth/
    ├── feature-payments/
    └── fix-bug-123/
```

### Why Sibling Directory?

1. **Clean separation** - Worktrees don't clutter main project
2. **Easy cleanup** - `rm -rf myproject__worktrees` removes all
3. **IDE friendly** - Main project stays clean in file tree
4. **Git ignore** - Main project's `.gitignore` doesn't affect worktrees

### Naming Convention

```
{project}__worktrees/{branch-name}
```

Examples:
- `webapp__worktrees/feature-auth`
- `api-server__worktrees/fix-rate-limit`
- `mobile-app__worktrees/refactor-navigation`

## Common Patterns

### Create worktree from PR branch

```bash
# Fetch PR branch
git fetch origin pull/123/head:pr-123

# Create worktree
git worktree add ../project__worktrees/pr-123 pr-123
```

### Create worktree for release

```bash
# Create release branch worktree
git worktree add -b release-v2.1 ../project__worktrees/release-v2.1 main
```

### Batch create worktrees

```bash
for feature in auth payments notifications; do
  git worktree add -b "feature-$feature" "../project__worktrees/feature-$feature"
done
```

### Cleanup all worktrees

```bash
# List and remove all
for wt in $(git worktree list --porcelain | grep '^worktree' | grep '__worktrees' | cut -d' ' -f2); do
  git worktree remove --force "$wt"
done

# Prune stale entries
git worktree prune
```

## Limitations

1. **One branch per worktree** - Can't checkout same branch in multiple worktrees
2. **Shared .git** - All worktrees share refs, stash, etc.
3. **No nested worktrees** - Worktree can't be inside another worktree
4. **Submodules** - Need separate initialization per worktree

## Integration with tmux

After creating worktree, create matching tmux window:

```bash
# Create worktree
git worktree add -b "feature-x" "../project__worktrees/feature-x"

# Create tmux window in that directory
tmux new-window -n "wm-feature-x" -c "../project__worktrees/feature-x"
```

See [SKILL.md](../SKILL.md) for full workflow integration.
