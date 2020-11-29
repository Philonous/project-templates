(defcustom new-project--project-directory "~/projects"
  "Directory where new projects are created"
  :type 'file
  :group 'new-project)

(defcustom new-project--executable "~/bin/create-project"
  "Executable to run to create new project"
  :type 'file
  :group 'new-project)

(defcustom new-project--templates '("haskell/simple")
  "Known templates to choose from"
  :type '(repeat string)
  :group 'new-project)

(defcustom new-project--visit-file "/src/Run.hs"
  "File to visit withing the project after it is created"
  :type 'file
  :group 'new-project)

(defun new-project (dont-ask-template project-name &optional template)
  "Create a new project"
  (interactive "P\nsName: ")
  (make-directory new-project--project-directory t)
  (let* ((default-directory new-project--project-directory)
         (template (if (not dont-ask-template)
                       (completing-read "Template: " new-project--templates)))
         (output-buffer (get-buffer-create (format "*new-project:%s*" project-name))))
    (with-current-buffer output-buffer
      (delete-region (point-min) (point-max)))
    (if (eq 0 (call-process new-project--executable nil output-buffer t
                            project-name template))
        (if new-project--visit-file
            (find-file (concat new-project--project-directory "/" project-name
                               new-project--visit-file )))
      (switch-to-buffer output-buffer))))
