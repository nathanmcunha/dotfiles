;;; custom.el --- Local customizations -*- lexical-binding: t -*-
;; This file is writable — Emacs saves safe-local-variable values here.

;; Mark C++ compile-command eval in .dir-locals.el as safe
(add-to-list 'safe-local-eval-forms
             '(setq-local compile-command
                (concat "g++ -std=c++23 -Wall -Wextra -O2 -o "
                 (file-name-sans-extension (file-name-nondirectory buffer-file-name))
                 " "
                 (shell-quote-argument buffer-file-name))))

;; Match the terminal palette theme.
(load-theme 'modus-operandi t)

(provide 'custom)
;;; custom.el ends here