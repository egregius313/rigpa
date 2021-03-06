(require 'ace-window)
(require 'winner)
(require 'chimera)
(require 'chimera-hydra)

(evil-define-state window
  "Window state."
  :tag " <W> "
  :message "-- WINDOW --"
  :enable (normal))

;; configure home-row hotkeys to index windows in ace-window,
;; used as "search" feature in window mode
(setq aw-keys '(?h ?j ?k ?l ?g ?f ?d ?s ?a))

;; enable winner mode, used to provide "undo/redo" functionality
;; in window mode
(winner-mode t)

(defun rigpa-window-mru ()
  "Jump to most recent window, or other window if there is only one other.

TODO: This doesn't work with more than 2 windows that are all the same buffer."
  (interactive)
  (let ((num-windows (length (window-list))))
    (if (= num-windows 2)
        (other-window 1)
      (evil-window-mru))))

(defun rigpa-window-quit-other ()
  "Quit other window without changing focus."
  (interactive)
  (other-window 1)
  (quit-window))

(defhydra hydra-window (:columns 4
                        :post (chimera-hydra-portend-exit chimera-window-mode t)
                        :after-exit (chimera-hydra-signal-exit chimera-window-mode
                                                               #'chimera-handle-hydra-exit))
  "Window mode"
  ("h" evil-window-left "left")
  ("j" evil-window-down "down")
  ("k" evil-window-up "up")
  ("l" evil-window-right "right")
  ("H" evil-window-move-far-left "move to far left")
  ("J" evil-window-move-very-bottom "move to bottom")
  ("K" evil-window-move-very-top "move to top")
  ("L" evil-window-move-far-right "move to far right")
  ("x" evil-window-delete "delete")
  ("c" evil-window-delete)
  ("Q" rigpa-window-quit-other "quit other window" :exit t)
  ("o" rigpa-window-mru "Jump to most recent (like Alt-Tab)" :exit t)
  ("n" other-window "next")
  ("w" delete-other-windows "maximize" :exit t)
  ("s" evil-window-split "split horizontally")
  ("_" evil-window-split "")
  ("v" evil-window-vsplit "split vertically")
  ("|" evil-window-vsplit "")
  ("u" winner-undo "undo")
  ("C-r" winner-redo "redo")
  ("/" ace-window "search")
  ("+" evil-window-increase-height "expand vertically")
  ("-" evil-window-decrease-height "shrink vertically")
  (">" evil-window-increase-width "expand horizontally")
  ("<" evil-window-decrease-width "shrink horizontally")
  ("=" balance-windows "balance")
  ("r" evil-window-rotate-downwards "rotate downwards")
  ("R" evil-window-rotate-upwards "rotate upwards")
  ("f" ffap-other-window "go to file in other window" :exit t)
  ("i" nil "exit" :exit t)
  ("H-m" rigpa-toggle-menu "show/hide this menu")
  ("<return>" rigpa-enter-lower-level "enter lower level" :exit t)
  ("<escape>" rigpa-enter-higher-level "escape to higher level" :exit t))

(defvar chimera-window-mode-entry-hook nil
  "Entry hook for rigpa window mode.")

(defvar chimera-window-mode-exit-hook nil
  "Exit hook for rigpa window mode.")

(defvar chimera-window-mode
  (make-chimera-mode :name "window"
                     :enter #'hydra-window/body
                     :entry-hook 'evil-window-state-entry-hook
                     :exit-hook 'evil-window-state-exit-hook))


(provide 'rigpa-window-mode)
;;; rigpa-window-mode.el ends here
