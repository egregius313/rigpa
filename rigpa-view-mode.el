;; a mode for navigating pages
;; TODO: region does not persist on entering mode, e.g. for
;;       use in "narrow" functionality

(require 'chimera)
(require 'chimera-hydra)

(evil-define-state view
  "View state."
  :tag " <V> "
  :message "-- VIEW --"
  :enable (normal))

(defun rigpa-view-scroll-half-page-up ()
  (interactive)
  (evil-scroll-line-up (/ (window-total-height) 2)))

(defun rigpa-view-scroll-half-page-down ()
  (interactive)
  (evil-scroll-line-down (/ (window-total-height) 2)))

(defun rigpa-view-scroll-skip-up ()
  (interactive)
  (evil-scroll-line-up 9))

(defun rigpa-view-scroll-skip-down ()
  (interactive)
  (evil-scroll-line-down 9))

(defun rigpa-view-zoom-in ()
  "Zoom in"
  (interactive)
  (text-scale-increase 1)
  (recenter))

(defun rigpa-view-zoom-out ()
  "Zoom out"
  (interactive)
  (text-scale-decrease 1)
  (recenter))

(defun rigpa-view-reset-zoom ()
  "Reset zoom level to default"
  (interactive)
  (text-scale-adjust 0))

(defun rigpa-view-scroll-left (&optional superlative)
  "Scroll view left"
  (interactive)
  (let ((n (cond ((eq superlative nil) 3)
                 ((eq superlative 'less) 1)
                 ((eq superlative 'more) 10))))
    (scroll-right n)))

(defun rigpa-view-scroll-right (&optional superlative)
  "Scroll view right"
  (interactive)
  (let ((n (cond ((eq superlative nil) 3)
                 ((eq superlative 'less) 1)
                 ((eq superlative 'more) 10))))
    (scroll-left n)))

(defun rigpa-view-recenter-at-top ()
  "Recenter view so that selected line is at the top"
  (interactive)
  (let ((this-scroll-margin
         (min (max 0 scroll-margin)
              (truncate (/ (window-body-height) 4.0)))))
    (recenter this-scroll-margin)))

(defun rigpa-view-recenter-at-bottom ()
  "Recenter view so that selected line is at the bottom"
  (interactive)
  (let ((this-scroll-margin
         (min (max 0 scroll-margin)
              (truncate (/ (window-body-height) 4.0)))))
    (recenter (- -1 this-scroll-margin))))

(defun rigpa-view-narrow ()
  "Narrow view to definition or region."
  (interactive)
  (if mark-active
      (narrow-to-region (region-beginning) (region-end))
    (narrow-to-defun)))


(defhydra hydra-view (:columns 5
                      :post (chimera-hydra-portend-exit chimera-view-mode t)
                      :after-exit (chimera-hydra-signal-exit chimera-view-mode
                                                             #'chimera-handle-hydra-exit))
  "View mode"
  ("j" rigpa-view-scroll-down "down")
  ("k" rigpa-view-scroll-up "up")
  ("C-S-j" evil-scroll-line-down "down fine")
  ("C-S-k" evil-scroll-line-up "up fine")
  ("b" evil-scroll-page-up "page up")
  ("f" evil-scroll-page-down "page down")
  ("h" rigpa-view-scroll-left "scroll left")
  ("l" rigpa-view-scroll-right "scroll right")
  ("C-h" (lambda ()
           (interactive)
           (rigpa-view-scroll-left 'more)) "scroll left more")
  ("C-l" (lambda ()
           (interactive)
           (rigpa-view-scroll-right 'more)) "scroll right more")
  ("C-S-h" (lambda ()
             (interactive)
             (rigpa-view-scroll-left 'less)) "scroll left less")
  ("C-S-l" (lambda ()
             (interactive)
             (rigpa-view-scroll-right 'less)) "scroll right less")
  ("g" evil-goto-first-line "beginning")
  ("0" evil-goto-first-line "beginning")
  ("M-k" evil-goto-first-line "beginning")
  ("G" evil-goto-line "end")
  ("$" evil-goto-line "end")
  ("M-j" evil-goto-line "end")
  ("s-v" recenter "recenter" :exit t)
  ("v" recenter "recenter")
  ("C-k" rigpa-view-scroll-skip-up "skip up")
  ("C-j" rigpa-view-scroll-skip-down "skip down")
  ("L" rigpa-view-recenter-at-top "recenter at top")
  ("H" rigpa-view-recenter-at-bottom "recenter at bottom")
  ("<backspace>" rigpa-view-reset-zoom "reset zoom")
  ("=" rigpa-view-reset-zoom "reset zoom")
  ("K" rigpa-view-zoom-in "zoom in")
  ("J" rigpa-view-zoom-out "zoom out")
  ("u" rigpa-view-scroll-half-page-up "leap up")
  ("d" rigpa-view-scroll-half-page-down "leap down")
  ("n" rigpa-view-narrow "narrow context")
  ("w" widen "widen to full view")
  ("H-m" rigpa-toggle-menu "show/hide this menu")
  ("i" nil "exit" :exit t)
  ("<return>" rigpa-enter-lower-level "enter lower level" :exit t)
  ("<escape>" rigpa-enter-higher-level "escape to higher level" :exit t))

(defvar chimera-view-mode-entry-hook nil
  "Entry hook for rigpa view mode.")

(defvar chimera-view-mode-exit-hook nil
  "Exit hook for rigpa view mode.")

(defvar chimera-view-mode
  (make-chimera-mode :name "view"
                     :enter #'hydra-view/body
                     :entry-hook 'evil-view-state-entry-hook
                     :exit-hook 'evil-view-state-exit-hook))


(provide 'rigpa-view-mode)
