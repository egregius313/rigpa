(require 'chimera)
(require 'chimera-hydra)

(evil-define-state activity
  "Activity state."
  :tag " <A> "
  :message "-- ACTIVITY --"
  :enable (normal))

(setq my-accumulate-buffer-name "MY-CLIPBOARD")

(defun my-yank-and-accumulate ()
  "'Yank'/accumulate text in a temporary buffer."
  (interactive)
  (unless (get-buffer my-accumulate-buffer-name)
    (my-new-empty-buffer my-accumulate-buffer-name))
  (append-to-buffer my-accumulate-buffer-name
                    (region-beginning)
                    (region-end))
  (deactivate-mark))

(defun my-paste-and-clear ()
  "Paste contents of paste buffer and empty it."
  (interactive)
  (insert-buffer my-accumulate-buffer-name)
  (kill-buffer my-accumulate-buffer-name))

(defun my-goto-older-change ()
  "docstring"
  (interactive)
  (call-interactively 'goto-last-change))

(defun my-goto-newer-change ()
  "docstring"
  (interactive)
  (when (eq last-command 'my-goto-older-change)
    ;; emacs only cycles "forwards" through the change list
    ;; if the previous command was a "backwards" navigation
    ;; through this list. Since we're wrapping the internal
    ;; commands, we need to manually indicate that the last
    ;; command was equivalent to the internal backwards
    ;; changelist navigation command
    (setq last-command 'goto-last-change))
  (call-interactively 'goto-last-change-reverse))


(defhydra hydra-activity (:columns 2
                          :post (chimera-hydra-portend-exit chimera-activity-mode t)
                          :after-exit (chimera-hydra-signal-exit chimera-activity-mode
                                                                 #'chimera-handle-hydra-exit))
  "Activity mode"
  ("h" my-goto-older-change "previous change in buffer")
  ("C-j" evil-jump-backward "jump backward") ;; TODO: these jumps don't work via hydra atm
  ("C-k" evil-jump-forward "jump forward")
  ("l" my-goto-newer-change "next change in buffer")
  ("m" evil-set-marker "set mark")
  ("g" evil-goto-mark "go to mark")
  ("y" my-yank-and-accumulate "yank and accumulate") ;; TODO: these don't work via hydra atm
  ("p" my-paste-and-clear "paste and clear")
  ("a" my-goto-older-change "previous change in buffer" :exit t)
  ("s-a" my-goto-older-change "previous change in buffer" :exit t)
  ("i" ignore "exit" :exit t)
  ("H-m" rigpa-toggle-menu "show/hide this menu")
  ("<return>" rigpa-enter-lower-level "enter lower level" :exit t)
  ("<escape>" rigpa-enter-higher-level "escape to higher level" :exit t))

(defvar chimera-activity-mode-entry-hook nil
  "Entry hook for rigpa activity mode.")

(defvar chimera-activity-mode-exit-hook nil
  "Exit hook for rigpa activity mode.")

(defvar chimera-activity-mode
  (make-chimera-mode :name "activity"
                     :enter #'hydra-activity/body
                     :entry-hook 'evil-activity-state-entry-hook
                     :exit-hook 'evil-activity-state-exit-hook))


(provide 'rigpa-activity-mode)
