Catala Code Formatting tool
===========================

`catala-format` is a code formatter for Catala.

This tool is based on [topiary](https://github.com/tweag/topiary), a
generic formatting tool.

## Installation

Pre-requisite: [opam package manager](https://opam.ocaml.org/).

### `opam`

Run `opam install catala-format` in a terminal.

### From sources

Run `opam install .` in the root directory after cloning the
repository.

## Usage

Run `catala-format <CATALA_FILE>`

*Note:* it may be slow the first time invoking the command at it
requires downloading and compiling the Catala's tree-sitter grammar in
background.

## Integration in editors

### VSCode

`catala-format` is linked to the `Format document` VSCode command in the
[Catala extension](https://github.com/CatalaLang/catala-language-server/).
Installing `catala-lsp` is required.

### Emacs

An Emacs plugin is present in `emacs/catala-format.el`. This plugin is
installed in the `opam`'s Emacs shared plugins directory, i.e.,
`<opam_dir>/share/emacs/site-lisp/`. The default `<opam_dir>`
can be found by invoking the `opam var prefix` shell command.

This script depends on the `catala-ts-mode.el` plugin which can be
found in root directory of the [Catala tree-sitter
repository](https://github.com/CatalaLang/tree-sitter-catala) which
needs to be copied over manually (e.g., in the same opam directory).

An example of `.emacs` configuration would look like:
```elisp
;; Change the <opam_dir> path by yours - find it with
(add-to-list 'load-path "~/<opam_dir>/share/emacs/site-lisp")

(require 'catala-ts-mode)
(require 'catala-format)

;; Attempt to format the Catala file when saving
(add-hook 'before-save-hook 'catala-format-before-save)
```

## License

The code contained in this repository is released under the [Apache
license (version 2)](LICENSE.txt) unless another license is explicited
for a sub-directory.
