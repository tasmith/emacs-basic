There should be only two files in the repo that need to be
"installed" in ~/.emacs.d, init.el and early-init.el.

An easy way to do so is:

$ cd ~/dotfiles/emacs-basic
$ mkdir ~/.emacs.d
$ rsync -av ./init.el ./early-init.el ~/.emacs.d

