;; Taken from uncledavesemacs
;;  EXWM

(use-package exwm
  :ensure t
  :config

    ;; necessary to configure exwm manually
    (require 'exwm-config)

    ;; fringe size, most people prefer 1 
    (fringe-mode 3)
    
    ;; emacs as a daemon, use "emacsclient <filename>" to seamlessly edit files from the terminal directly in the exwm instance
    (server-start)

    ;; this fixes issues with ido mode, if you use helm, get rid of it
    (exwm-config-ido)

    ;; a number between 1 and 9, exwm creates workspaces dynamically so I like starting out with 1
    (setq exwm-workspace-number 1)

    ;; this is a way to declare truly global/always working keybindings
    ;; this is a nifty way to go back from char mode to line mode without using the mouse
    (exwm-input-set-key (kbd "s-r") #'exwm-reset)
    (exwm-input-set-key (kbd "s-k") #'exwm-workspace-delete)
    (exwm-input-set-key (kbd "s-w") #'exwm-workspace-swap)

    ;; the next loop will bind s-<number> to switch to the corresponding workspace
    (dotimes (i 10)
      (exwm-input-set-key (kbd (format "s-%d" i))
                          `(lambda ()
                             (interactive)
                             (exwm-workspace-switch-create ,i))))

    ;; the simplest launcher, I keep it in only if dmenu eventually stopped working or something
    (exwm-input-set-key (kbd "s-&")
                        (lambda (command)
                          (interactive (list (read-shell-command "$ ")))
                          (start-process-shell-command command nil command)))

    ;; an easy way to make keybindings work *only* in line mode
    (push ?\C-q exwm-input-prefix-keys)
    (define-key exwm-mode-map [?\C-q] #'exwm-input-send-next-key)

    ;; simulation keys are keys that exwm will send to the exwm buffer upon inputting a key combination
    (exwm-input-set-simulation-keys
     '(
       ;; movement
       ([?\C-b] . left)
       ([?\M-b] . C-left)
       ([?\C-f] . right)
       ([?\M-f] . C-right)
       ([?\C-p] . up)
       ([?\C-n] . down)
       ([?\C-a] . home)
       ([?\C-e] . end)
       ([?\M-v] . prior)
       ([?\C-v] . next)
       ([?\C-d] . delete)
       ([?\C-k] . (S-end delete))
       ;; cut/paste
       ([?\C-w] . ?\C-x)
       ([?\M-w] . ?\C-c)
       ([?\C-y] . ?\C-v)
       ;; search
       ([?\C-s] . ?\C-f)))

    ;; this little bit will make sure that XF86 keys work in exwm buffers as well
    (dolist (k '(XF86AudioLowerVolume
               XF86AudioRaiseVolume
               XF86PowerOff
               XF86AudioMute
               XF86AudioPlay
               XF86AudioStop
               XF86AudioPrev
               XF86AudioNext
               XF86ScreenSaver
               XF68Back
               XF86Forward
               Scroll_Lock
               print))
    (cl-pushnew k exwm-input-prefix-keys))
    
    ;; this just enables exwm, it started automatically once everything is ready
    (exwm-enable))

;; dmenu
(use-package dmenu
  :ensure t
  :bind
  ("s-SPC" . 'dmenu))

;;Functions to start processes

(defun exwm-async-run (name)
  (interactive)
  (start-process name nil name))

(defun daedreth/launch-discord ()
  (interactive)
  (exwm-async-run "discord"))

(defun daedreth/launch-browser ()
  (interactive)
  (exwm-async-run "qutebrowser"))

(defun daedreth/lock-screen ()
  (interactive)
  (exwm-async-run "slock"))

(defun daedreth/shutdown ()
  (interactive)
  (start-process "halt" nil "sudo" "halt"))

(defun dataphobe/terminal ()
  (interactive)
  (exwm-async-run "termite"))

;; keybinings to start

(global-set-key (kbd "s-d") 'daedreth/launch-discord)
(global-set-key (kbd "<s-tab>") 'daedreth/launch-browser)
(global-set-key (kbd "s-l") 'daedreth/lock-screen)
(global-set-key (kbd "<XF86PowerOff>") 'daedreth/shutdown)
(global-set-key (kbd "<s-return>") 'dataphobe/terminal)

;;Audio controls
;;This is a set of bindings to my XF86 keys that invokes pulsemixer with the correct parameters

;;Volume modifier
;;It goes without saying that you are free to modify the modifier as you see fit, 4 is good enough for me though.

(defconst volumeModifier "4")
;;Functions to start processes
(defun audio/mute ()
  (interactive)
  (start-process "audio-mute" nil "pulsemixer" "--toggle-mute"))

(defun audio/raise-volume ()
  (interactive)
  (start-process "raise-volume" nil "pulsemixer" "--change-volume" (concat "+" volumeModifier)))

(defun audio/lower-volume ()
  (interactive)
  (start-process "lower-volume" nil "pulsemixer" "--change-volume" (concat "-" volumeModifier)))
;;Keybindings to start processes
;;You can also change those if you’d like, but I highly recommend keeping ‘em the same, chances are, they will just work.

(global-set-key (kbd "<XF86AudioMute>") 'audio/mute)
(global-set-key (kbd "<XF86AudioRaiseVolume>") 'audio/raise-volume)
(global-set-key (kbd "<XF86AudioLowerVolume>") 'audio/lower-volume)


;;Screenshotting the entire screen
(defun daedreth/take-screenshot ()
  "Takes a fullscreen screenshot of the current workspace"
  (interactive)
  (when window-system
  (loop for i downfrom 3 to 1 do
        (progn
          (message (concat (number-to-string i) "..."))
          (sit-for 1)))
  (message "Cheese!")
  (sit-for 1)
  (start-process "screenshot" nil "import" "-window" "root" 
             (concat (getenv "HOME") "/" (subseq (number-to-string (float-time)) 0 10) ".png"))
  (message "Screenshot taken!")))
(global-set-key (kbd "<print>") 'daedreth/take-screenshot)
;;Screenshotting a region
(defun daedreth/take-screenshot-region ()
  "Takes a screenshot of a region selected by the user."
  (interactive)
  (when window-system
  (call-process "import" nil nil nil ".newScreen.png")
  (call-process "convert" nil nil nil ".newScreen.png" "-shave" "1x1"
                (concat (getenv "HOME") "/" (subseq (number-to-string (float-time)) 0 10) ".png"))
  (call-process "rm" nil nil nil ".newScreen.png")))
(global-set-key (kbd "<Scroll_Lock>") 'daedreth/take-screenshot-region)

;;Default browser


(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "qutebrowser")


;;terminal
(defvar my-term-shell "/bin/bash")
(defadvice ansi-term (before force-bash)
  (interactive (list my-term-shell)))
(ad-activate 'ansi-term)

;;In loving memory of bspwm, Super + Enter opens a new terminal, old habits die hard.

;; (global-set-key (kbd "<s-return>") 'ansi-term)

;;Basic setup for mpd
;;The non XF86 keys are made to be somewhat logical to follow and easy to remember. At the bottom part of the configuration, you will notice how XF86 keys are used by default, so unless you keyboard is broken it should work out of the box. Obviously you might have to adjust server-name and server-port to fit your configuration.

(use-package emms
  :ensure t
  :config
    (require 'emms-setup)
    (require 'emms-player-mpd)
    (emms-all) ; don't change this to values you see on stackoverflow questions if you expect emms to work
    (setq emms-seek-seconds 5)
    (setq emms-player-list '(emms-player-mpd))
    (setq emms-info-functions '(emms-info-mpd))
    (setq emms-player-mpd-server-name "localhost")
    (setq emms-player-mpd-server-port "6601")
  :bind
    ("s-m p" . emms)
    ("s-m b" . emms-smart-browse)
    ("s-m r" . emms-player-mpd-update-all-reset-cache)
    ("<XF86AudioPrev>" . emms-previous)
    ("<XF86AudioNext>" . emms-next)
    ("<XF86AudioPlay>" . emms-pause)
    ("<XF86AudioStop>" . emms-stop))
;;MPC Setup
;;Setting the default port
;;We use non-default settings for the socket, to use the built in mpc functionality we need to set up a variable. Adjust according to your setup.

(setq mpc-host "localhost:6601")
;;Some more fun stuff
;;Starting the daemon from within emacs
;;If you have an absolutely massive music library, it might be a good idea to get rid of mpc-update and only invoke it manually when needed.

(defun mpd/start-music-daemon ()
  "Start MPD, connects to it and syncs the metadata cache."
  (interactive)
  (shell-command "mpd")
  (mpd/update-database)
  (emms-player-mpd-connect)
  (emms-cache-set-from-mpd-all)
  (message "MPD Started!"))
(global-set-key (kbd "s-m c") 'mpd/start-music-daemon)
;;Killing the daemon from within emacs
(defun mpd/kill-music-daemon ()
  "Stops playback and kill the music daemon."
  (interactive)
  (emms-stop)
  (call-process "killall" nil nil nil "mpd")
  (message "MPD Killed!"))
(global-set-key (kbd "s-m k") 'mpd/kill-music-daemon)
;;Updating the database easily.
(defun mpd/update-database ()
  "Updates the MPD database synchronously."
  (interactive)
  (call-process "mpc" nil nil nil "update")
  (message "MPD Database Updated!"))
(global-set-key (kbd "s-m u") 'mpd/update-database)


;; ;; pdf-tools

;; (use-package pdf-tools
;;  :pin manual ;; manually update
;;  :config
;;  ;; initialise
;;  (pdf-tools-install)
;;  ;; open pdfs scaled to fit page
;;  (setq-default pdf-view-display-size 'fit-page)
;;  ;; automatically annotate highlights
;;  (setq pdf-annot-activate-created-annotations t)
;;  ;; use normal isearch
;;  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward))

