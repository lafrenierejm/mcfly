;;; -*- lexical-binding: t; -*-

(defvar mcfly-commands
  '(query-replace-regexp
    flush-lines
    keep-lines))

(defun mcfly-back-to-present ()
  (remove-hook 'pre-command-hook 'mcfly-back-to-present t)
  (cond ((equal (this-command-keys-vector) (kbd "M-p"))
         ;; repeat one time to get straight to the first history item
         (setq unread-command-events
               (append unread-command-events
                       (listify-key-sequence (kbd "M-p")))))
        ((memq this-command '(self-insert-command))
         (if (not (= (point) (minibuffer-prompt-end)))
             (delete-region (point) (point-max))
           (delete-region (minibuffer-prompt-end)
                          (point-max))))))

(defun mcfly-time-travel ()
  (when (memq this-command mcfly-commands)
    (let* ((kbd (kbd "M-n"))
           (cmd (key-binding kbd))
           (future (and cmd
                        (with-temp-buffer
                          (when (ignore-errors
                                  (call-interactively cmd) t)
                            (buffer-string))))))
      (when future
        (save-excursion
          (insert (propertize future 'face 'shadow)))
        (add-hook 'pre-command-hook 'mcfly-back-to-present nil t)))))

;; setup code
(add-hook 'minibuffer-setup-hook #'mcfly-time-travel)
(with-eval-after-load 'ivy
  (push (cons 'swiper 'mcfly-swiper)
        ivy-hooks-alist)
  (defun mcfly-swiper ()
    (let ((sym (with-ivy-window
                 (thing-at-point 'symbol))))
      (when sym
        (add-hook 'pre-command-hook 'mcfly-back-to-present nil t)
        (save-excursion
          (insert (propertize sym 'face 'shadow)))))))



