# hpc-dotfiles

[![build](https://github.com/imtek-emp/hpc-dotfiles/workflows/lint/badge.svg)](https://github.com/imtek-emp/hpc-dotfiles/actions)
[![License](https://img.shields.io/badge/license-MIT-orange)](https://github.com/tprasadtp/dotfiles/blob/master/LICENSE.md)

## Dev

To test installation create an empty folder `Junk` in your `$HOME`.

```console
make shellcheck
make test-install-default
```
Dotfiles will be installed to `$HOME/Junk/`.

## Help

```console
./install.sh --help
make help
```

## Install

```console
make install-tools
make install
```
