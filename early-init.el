;;; early-init.el --- Early Init File -*- lexical-binding: t -*-

;;; Code:

;; Precompute package activation actions to speed up startup.
(defvar package-quickstart t)

;; Do not resize the frame at this early stage.
(setq frame-inhibit-implied-resize t)

;; Disable GUI elements
(tool-bar-mode -1)
(scroll-bar-mode -1)

(unless (string-equal "darwin" system-type)
  (menu-bar-mode -1))

(setq inhibit-splash-screen t
      inhibit-startup-screen t
      inhibit-startup-buffer-menu t)

(unless (version< emacs-version "28.0")
  (setq native-comp-async-report-warnings-errors 'silent))

;;; early-init.el ends here
