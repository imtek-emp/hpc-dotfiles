# HPC (*) dotfiles

![Logo](https://static.prasadt.com/my-logos/dotfiles/dotfiles-small.png)

[![build](https://github.com/imtek-emp/hpc-dotfiles/workflows/lint/badge.svg)](https://github.com/imtek-emp/hpc-dotfiles/actions)
[![License](https://img.shields.io/badge/license-MIT-orange)](https://github.com/tprasadtp/dotfiles/blob/master/LICENSE.md)


## Dev

To test installation create an empty folder `Junk` in your `$HOME`.

```console
./install.sh -i -x --test-mode
```
Dotfiles will be installed to `$HOME/Junk/`.

## Install

```console
make install
make install-tools
```
