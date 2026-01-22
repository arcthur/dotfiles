# Extended Workflow Examples

## Example 1: Parallel Feature Development

Scenario: Develop three features simultaneously with different agents.

### Setup

```bash
# Project: webapp
cd ~/projects/webapp

# Create worktree directory
mkdir -p ../webapp__worktrees

# Create three worktrees with different agents
features=("auth:claude" "payments:codex" "notifications:claude")

session=$(tmux display-message -p '#S')

for item in "${features[@]}"; do
  feature="${item%%:*}"
  agent="${item#*:}"

  # Create worktree
  git worktree add -b "feature-$feature" "../webapp__worktrees/feature-$feature"

  # Create tmux window
  tmux new-window -n "wm-feature-$feature" -c "../webapp__worktrees/feature-$feature"

  # Copy env file
  cp .env "../webapp__worktrees/feature-$feature/"

  # Start agent with task
  tmux send-keys -t "$session:wm-feature-$feature.1" "$agent 'Implement the $feature feature'" Enter

  echo "Created: feature-$feature with $agent"
done
```

### Monitor Progress

```bash
# Check all agent status
session=$(tmux display-message -p '#S')

for w in $(tmux list-windows -F '#I:#W' | grep 'wm-feature'); do
  id="${w%%:*}"
  name="${w#*:}"
  content=$(tmux capture-pane -t "$session:$id.1" -p -S -30)

  if echo "$content" | grep -qiE '(y/n|approve|confirm)'; then
    echo "[WAIT] $name"
  elif echo "$content" | grep -qiE '(error|failed)'; then
    echo "[ERR]  $name"
  elif echo "$content" | grep -qiE '(Reading|Writing|Bash)'; then
    echo "[WORK] $name"
  else
    echo "[IDLE] $name"
  fi
done
```

### Merge Completed Features

```bash
# Switch to main
git checkout main

# Merge each completed feature
session=$(tmux display-message -p '#S')
for feature in auth payments notifications; do
  echo "Merging feature-$feature..."
  git merge "feature-$feature" --no-edit

  # Cleanup
  tmux kill-window -t "$session:wm-feature-$feature" 2>/dev/null
  git worktree remove "../webapp__worktrees/feature-$feature"
  # If removal fails due to uncommitted changes, confirm then:
  # git worktree remove "../webapp__worktrees/feature-$feature" --force
  git branch -d "feature-$feature"
done
```

---

## Example 2: Bug Fix Swarm

Scenario: Multiple bugs to fix, assign to parallel agents.

### Setup

```bash
cd ~/projects/api-server

# Bugs to fix (from issue tracker)
bugs=(
  "123:Fix rate limiting on /api/users"
  "124:Handle null pointer in auth middleware"
  "125:Correct timezone in report generation"
)

session=$(tmux display-message -p '#S')

for item in "${bugs[@]}"; do
  bug_id="${item%%:*}"
  description="${item#*:}"

  # Create worktree
  git worktree add -b "fix-bug-$bug_id" "../api-server__worktrees/fix-bug-$bug_id"

  # Create tmux window
  tmux new-window -n "wm-fix-$bug_id" -c "../api-server__worktrees/fix-bug-$bug_id"

  # Start agent with bug description
  tmux send-keys -t "$session:wm-fix-$bug_id.1" "claude '$description'" Enter
done
```

### Auto-Rescue Stuck Agents

```bash
#!/usr/bin/env bash
# Run periodically to auto-confirm prompts

session=$(tmux display-message -p '#S')

while true; do
  for w in $(tmux list-windows -F '#I:#W' | grep 'wm-fix'); do
    idx="${w%%:*}"
    pane="$session:$idx.1"
    content=$(tmux capture-pane -t "$pane" -p -S -20)

    # Use same pattern as SKILL.md
    if echo "$content" | grep -qiE '(\(y/n\)|\[Y/n\]|\[y/N\]|approve|confirm)'; then
      tmux send-keys -t "$pane" "y" Enter
      echo "$(date): Rescued ${w#*:}"
    fi
  done
  sleep 30
done
```

### Collect Results

```bash
echo "=== Bug Fix Status ==="
for w in $(tmux list-windows -F '#I:#W' | grep 'wm-fix'); do
  id="${w%%:*}"
  name="${w#*:}"
  bug_id="${name#wm-fix-}"

  # Check if branch has commits
  branch="fix-bug-$bug_id"
  commits=$(git log main.."$branch" --oneline 2>/dev/null | wc -l)

  if [[ $commits -gt 0 ]]; then
    echo "[DONE] Bug $bug_id - $commits commit(s)"
  else
    echo "[WIP]  Bug $bug_id - no commits yet"
  fi
done
```

---

## Example 3: PR Review Workflow

Scenario: Review multiple PRs in parallel, each in isolated environment.

### Setup

```bash
cd ~/projects/frontend

# PRs to review
prs=(456 457 458)
session=$(tmux display-message -p '#S')

for pr in "${prs[@]}"; do
  # Fetch PR branch
  git fetch origin "pull/$pr/head:pr-$pr"

  # Create worktree
  git worktree add "../frontend__worktrees/pr-$pr" "pr-$pr"

  # Create tmux window
  tmux new-window -n "wm-pr-$pr" -c "../frontend__worktrees/pr-$pr"

  # Install dependencies and start dev server (chained with &&)
  tmux send-keys -t "$session:wm-pr-$pr.1" "npm install && npm run dev" Enter
done
```

### Review with Agent

```bash
# In each PR window, start agent for review
session=$(tmux display-message -p '#S')
for w in $(tmux list-windows -F '#I:#W' | grep 'wm-pr'); do
  id="${w%%:*}"
  pr="${w#wm-pr-}"

  # Split window for agent
  tmux split-window -t "$id" -v -l 20

  # Start agent with review task
  tmux send-keys -t "$session:$id.2" "claude 'Review this PR for bugs, security issues, and code quality'" Enter
done
```

---

## Example 4: Monorepo Package Development

Scenario: Work on multiple packages in a monorepo simultaneously.

### Setup

```bash
cd ~/projects/monorepo

packages=("core" "ui" "api" "cli")

session=$(tmux display-message -p '#S')

for pkg in "${packages[@]}"; do
  # Create worktree
  git worktree add -b "update-$pkg" "../monorepo__worktrees/update-$pkg"

  # Create tmux window
  tmux new-window -n "wm-$pkg" -c "../monorepo__worktrees/update-$pkg"

  # Symlink node_modules (shared across worktrees)
  ln -s "$(pwd)/node_modules" "../monorepo__worktrees/update-$pkg/node_modules"

  # Start agent focused on specific package
  tmux send-keys -t "$session:wm-$pkg.1" "claude 'Update the $pkg package to use the new API'" Enter
done
```

### Coordinate Agents

```bash
# Send same instruction to all agents
session=$(tmux display-message -p '#S')

for w in $(tmux list-windows -F '#I:#W' | grep 'wm-'); do
  id="${w%%:*}"
  tmux send-keys -t "$session:$id.1" "/add-context ../monorepo__worktrees/*/packages/*/src" Enter
done
```

---

## Example 5: Full CI/CD Simulation

Scenario: Test changes across multiple environments before merge.

### Setup

```bash
cd ~/projects/service

environments=("dev" "staging" "prod-like")

session=$(tmux display-message -p '#S')

for env in "${environments[@]}"; do
  # Create worktree
  git worktree add -b "test-$env" "../service__worktrees/test-$env"

  # Create tmux window with layout
  tmux new-window -n "wm-test-$env" -c "../service__worktrees/test-$env"

  # Copy environment-specific config
  cp ".env.$env" "../service__worktrees/test-$env/.env"

  # Split for tests
  tmux split-window -t "$session:wm-test-$env" -v -l 15

  # Start service in top pane
  tmux send-keys -t "$session:wm-test-$env.1" "docker-compose up" Enter

  # Run tests in bottom pane
  tmux send-keys -t "$session:wm-test-$env.2" "sleep 10 && npm run test:e2e" Enter
done
```

### Collect Test Results

```bash
echo "=== Test Results ==="
session=$(tmux display-message -p '#S')

for env in dev staging prod-like; do
  content=$(tmux capture-pane -t "$session:wm-test-$env.2" -p -S -50)

  if echo "$content" | grep -q "passed"; then
    echo "[PASS] $env"
  elif echo "$content" | grep -qiE "(failed|error)"; then
    echo "[FAIL] $env"
  else
    echo "[RUN]  $env - still running"
  fi
done
```

---

## Example 6: Emergency Hotfix

Scenario: Critical bug in production, need isolated fix with verification.

### Setup

```bash
cd ~/projects/production-app

# Create hotfix worktree from production tag
git worktree add -b "hotfix-critical" "../production-app__worktrees/hotfix-critical" v2.3.1

# Create window with split layout
tmux new-window -n "wm-hotfix" -c "../production-app__worktrees/hotfix-critical"

# Split for logs
session=$(tmux display-message -p '#S')
tmux split-window -t "$session:wm-hotfix" -v -l 10

# Start agent with urgency context
tmux send-keys -t "$session:wm-hotfix.1" "claude 'CRITICAL: Fix the memory leak in UserService.processQueue(). This is causing production outages.'" Enter

# Monitor production logs in bottom pane
tmux send-keys -t "$session:wm-hotfix.2" "kubectl logs -f deployment/production-app --tail=100" Enter
```

### Fast-Track Merge

```bash
# After fix verified
git checkout main
git merge hotfix-critical --no-edit

# Tag release
git tag v2.3.2

# Cleanup
tmux kill-window -t "$session:wm-hotfix"
git worktree remove "../production-app__worktrees/hotfix-critical"
# If removal fails due to uncommitted changes, confirm then:
# git worktree remove "../production-app__worktrees/hotfix-critical" --force
git branch -d hotfix-critical

# Deploy
git push origin main --tags
```

---

## Tips & Best Practices

### 1. Naming Conventions

```
wm-feature-{name}    # Feature work
wm-fix-{id}          # Bug fixes
wm-pr-{number}       # PR reviews
wm-test-{env}        # Testing environments
wm-hotfix-{desc}     # Emergency fixes
```

### 2. Resource Management

```bash
# Monitor system resources
tmux display-popup -E "btm"

# Check worktree disk usage
du -sh ../project__worktrees/*
```

### 3. Session Organization

```bash
# Create dedicated session for parallel work
tmux new-session -d -s parallel-work

# Move worktree windows to this session
tmux move-window -s "main:wm-feature-auth" -t "parallel-work:"
```

### 4. Cleanup Script

```bash
#!/usr/bin/env bash
# cleanup_all_worktrees.sh

cd ~/projects/myproject

echo "Cleaning up all worktrees..."

# Kill all worktree windows
for w in $(tmux list-windows -F '#W' | grep 'wm-'); do
  tmux kill-window -t "$w" 2>/dev/null
done

# Remove all worktrees
for wt in $(git worktree list --porcelain | grep '^worktree' | grep '__worktrees' | cut -d' ' -f2); do
  git worktree remove "$wt"
  # If removal fails due to uncommitted changes, confirm then:
  # git worktree remove --force "$wt"
done

# Prune stale entries
git worktree prune

# Delete merged branches
git branch --merged | grep -v '\*\|main\|master' | xargs -r git branch -d

echo "Cleanup complete."
```
