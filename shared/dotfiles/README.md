# Spigell Dotfiles (bash, git, vim)

This directory vendors the bash, git, and vim configuration from [`spigell/dotfiles`](https://github.com/spigell/dotfiles) so workbench images can consume the same defaults without pulling the repo at build time.

Contents:
- `bash/` – `bashrc` and `bash_profile` with history, completion, aliases, and helper functions.
- `git/` – Git config with aliases and user identity placeholder values.
- `vim/` – `vimrc` and `pluginsrc` based on the minimal `amix/vimrc` setup with Vundle plugin declarations.

Keep these files in sync with the upstream dotfiles when updating shell defaults.
