# vim-airline-two-char-unique-tail

A lightweight tabline formatter for [vim-airline](https://github.com/vim-airline/vim-airline).

It shortens parent directory names to two characters while preserving enough path information to distinguish buffers with duplicate filenames.

## Features

### Two-Character Directory Names

For normal buffer paths, intermediate directory components are shortened to two characters using Vim's `pathshorten(..., 2)` behavior.

This provides more path information than the standard one-character shortening while keeping the tabline compact.

### Unique Tail for Duplicate Filenames

When multiple buffers have the same filename, the formatter keeps enough parent-directory information to distinguish them.

Intermediate directories that are not required for identification can be represented by an ellipsis (`…`).

### Optional Nerd Font Icons

If [vim-nerdfont](https://github.com/lambdalisue/vim-nerdfont) is installed, file-type icons can be enabled with:

    let g:airline_two_char_unique_tail_nerdfont = 1

The default is `0` (disabled).

## Tested Environments (Author's Environment Only)

- **Vim:** 9.20+
- **OS / Terminals:**
  - Windows 10 / 11 (Terminal / gVim)
  - WSL2 (Ubuntu 24.04)

**Disclaimer:** This plugin is provided "as is" for the author's personal environment. No support or compatibility guarantees are provided for other configurations.

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

    Plug 'gafutek/vim-airline-two-char-unique-tail'

Using [dein.vim](https://github.com/Shougo/dein.vim):

    call dein#add('gafutek/vim-airline-two-char-unique-tail')

## Configuration

Enable the vim-airline tabline and select this formatter in your `.vimrc` or `init.vim`:

    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#formatter = 'two_char_unique_tail'

The formatter is intentionally not selected automatically by the plugin. Keeping this setting in `.vimrc` or `init.vim` avoids plugin load-order dependencies and keeps formatter selection explicit.

### Nerd Font Icons

If `vim-nerdfont` is installed, enable file-type icons with:

    let g:airline_two_char_unique_tail_nerdfont = 1

To disable the icons:

    let g:airline_two_char_unique_tail_nerdfont = 0

## License

MIT License. Copyright (c) 2026
