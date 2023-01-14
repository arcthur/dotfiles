# Zsh-Snap
# ---------------
[[ -f $ZSNAP_HOME/zsh-snap/znap.zsh ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git $ZSNAP_HOME/zsh-snap

source $ZSNAP_HOME/zsh-snap/znap.zsh

# Config
# ---------------
# directory
setopt auto_cd              # Auto changes to a directory without typing cd.
setopt auto_pushd           # Push the old directory onto the stack on cd.
setopt pushd_ignore_dups    # Do not store duplicates in the stack.
setopt pushd_silent         # Do not print the directory stack after pushd or popd.
setopt pushd_to_home        # Push to home directory when no argument is given.
setopt cdable_vars          # Change directory to a path stored in a variable.
setopt multios              # Write to multiple descriptors.
setopt extended_glob        # Use extended globbing syntax.
unsetopt clobber            # Do not overwrite existing files with > and >>. Use >! and >>! to bypass.

# General
setopt combining_chars      # Combine zero-length punctuation characters (accents) with the base character.
setopt interactive_comments # Enable comments in interactive shell.
setopt rc_quotes            # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'.
unsetopt mail_warning       # Don't print a warning message if a mail file has been accessed.

# Allow mapping Ctrl+S and Ctrl+Q shortcuts
[[ -r ${TTY:-} && -w ${TTY:-} && $+commands[stty] == 1 ]] && stty -ixon <$TTY >$TTY

# Jobs
setopt long_list_jobs     # List jobs in the long format by default.
setopt auto_resume        # Attempt to resume existing job before creating a new process.
setopt notify             # Report status of background jobs immediately.
unsetopt bg_nice          # Don't run all background jobs at a lower priority.
unsetopt hup              # Don't kill jobs on shell exit.
unsetopt check_jobs       # Don't report on jobs when shell exit.

# History
SAVEHIST=$(( 50 * 1000 ))       # For readability
HISTSIZE=$(( 1.2 * SAVEHIST ))  # Zsh recommended value
HISTFILE=$HOME/.zsh_history
zmodload -F zsh/files b:zf_mv

setopt bang_hist                 # Treat the '!' character specially during expansion.
setopt extended_history          # Write the history file in the ':start:elapsed;command' format.
setopt extendedglob              # Always be a backup file we can copy
setopt share_history             # Share history between all sessions.
setopt hist_expire_dups_first    # Expire a duplicate event first when trimming history.
setopt hist_ignore_dups          # Do not record an event that was just recorded again.
setopt hist_ignore_all_dups      # Delete an old recorded event if a new event is a duplicate.
setopt hist_find_no_dups         # Do not display a previously found event.
setopt hist_ignore_space         # Do not record an event starting with a space.
setopt hist_save_no_dups         # Do not write a duplicate event to the history file.
setopt hist_verify               # Do not execute immediately upon history expansion.
setopt hist_beep                 # Beep when accessing non-existent history.

# Move the largest "$HISTFILE <number>" file to $HISTFILE.
local -a files=( $HISTFILE(|\ <->)(OL) )
[[ -w $files[1] ]] &&
    zf_mv $files[1] $HISTFILE

# Lists the ten most used commands.
alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head"

