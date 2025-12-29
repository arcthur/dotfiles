# dotfiles

Configuration files for editors and other UNIX tools. This is to make it easier to setup programming environment for me.

## Brew

`brew bundle install`

## RIME

- [Rime-Ice](https://github.com/iDvel/rime-ice)
- [Plum](https://github.com/rime/plum)

`bash rime-install iDvel/rime-ice:others/recipes/full`

- add `- schema: wubi_pinyin` to default config

## ZSH

- [Z4H](https://github.com/romkatv/zsh4humans)

## NeoVim

- copy from https://github.com/LazyVim

## TMUX

- [TPM](https://github.com/tmux-plugins/tpm)

## Git SSH Signing

Enable SSH commit signing for verified commits on GitHub.

```bash
# 1. Add SSH key to agent (with Keychain persistence)
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# 2. Grant gh CLI permission to manage SSH keys
gh auth refresh -h github.com -s admin:public_key
gh auth refresh -h github.com -s admin:ssh_signing_key

# 3. Add SSH key to GitHub (authentication + signing)
gh ssh-key add ~/.ssh/id_ed25519.pub --title "MacBook" --type authentication
gh ssh-key add ~/.ssh/id_ed25519.pub --title "MacBook Signing" --type signing

# 4. Test SSH connection
ssh -T git@github.com

# 5. Create allowed_signers file
mkdir -p ~/.config/git
echo "arthurtemptation@gmail.com $(cat ~/.ssh/id_ed25519.pub)" > ~/.config/git/allowed_signers

# 6. Stow git config
cd ~/dotfiles && stow --dotfiles -R git
```

Config in `.gitconfig`:
- `user.signingkey` - SSH public key path
- `gpg.format = ssh` - Use SSH instead of GPG
- `commit.gpgsign = true` - Sign all commits
- `gpg.ssh.allowedSignersFile` - For verifying signatures locally
