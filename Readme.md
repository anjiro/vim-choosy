# Introduction

This is a simple Vim plugin for quickly selecting windows and then performing
actions on them. It was inspired by
[vim-choosewin](https://github.com/t9md/vim-choosewin) but takes the philosophy
of allowing the user to specify the actions to take on the chosen window. It's
also not as compatible as vim-choosewin, because it requires the popup window
feature from Vim 8.1 and up.

## Features

When run, Choosy displays a popup at the center of each window. Each popup has
a letter or a number (configurable). To choose the window, type the given
letter. Choosy closes all of the popups it opened and executes an action.

What actions? Pretty much anything you like. Choosy comes with a number of
example actions such as jumping to a window, splitting
a window, closing a window, or swapping buffers between windows. But part of
the power of Choosy is that you can easily set up your own actions. Here's an
example call to Choosy that splits a selected window into 3 parts:

    nnoremap <leader>3 :Choosy call win_execute({win.winid}, "sp {bar} sp")<cr>

See [the docs](blob/main/doc/choosy.txt) for full information.

## Default mappings

Choosy comes with a set of default mappings starting with `<leader>cw` ("<b>c</b>hoose
<b>w</b>indow"):

- `<leader>cwh`: split the chosen window <b>h</b>orizontally
- `<leader>cwv`: split the chosen window <b>v</b>ertically
- `<leader>cwc`: <b>c</b>lose the chosen window
- `<leader>cws`: <b>s</b>wap the buffers in this window and the chosen one, with the
  cursor following this buffer
- `<leader>cwS`: swap the buffers in this window and the chosen one, with the
  cursor <b>S</b>taying in the current window
- `<leader>cwD`: show this buffer in the chose window ("<b>D</b>uplicate")

If NERDTree is installed, an additional set of mappings are available to
open files from NERDTree in a chosen window. These start with `<leader>co` ("<b>c</b>hoose <b>o</b>pen"):

- `<leader>cow`: open in the chosen <b>w</b>indow
- `<leader>coh`: open in a <b>h</b>orizontal split of the chosen window
- `<leader>cov`: open in a <b>v</b>ertical split of the chosen window   

# Installing

Choosy requires a recent Vim which supports popup windows
and optional function arguments.

Choosy has not been tested on versions < 8.1 (patch 2110), nor on nvim.

To install, use your package manager of choice.

# Screenshots

Note that these screenshots have syntax higlighting turned off to make the
Choosy popups more visible.

Basic configuration:

<center>
  <img src="screenshots/choosy-basic.gif" width="75%">
</center>

With `g:choosy_color_popups` and `g:choosy_key_winnr` set:

<center>
  <img src="screenshots/choosy-winnr-colors.gif" width="75%">
</center>
