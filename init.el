;; 设置光标为细条形状
(setq-default cursor-type 'bar)

;; 设置默认的tab宽度
(setq-default tab-width 4)

;; 对于使用空格作为缩进的模式，确保不使用制表符进行缩进
(setq-default indent-tabs-mode nil)

;; 设置字体
(defun increase-font-size ()
  (interactive)
  (set-face-attribute 'default nil :height (min 1400 (+ (face-attribute 'default :height) 10))))
(defun decrease-font-size ()
  (interactive)
  (set-face-attribute 'default nil :height (max 100 (- (face-attribute 'default :height) 10))))

(global-set-key (kbd "C-+") 'increase-font-size)
(global-set-key (kbd "C--") 'decrease-font-size)

;; 增强型命令和文件搜索工具
(use-package ivy
  :ensure t
  :config
  (ivy-mode 1))

;; 项目管理工具
(use-package projectile
  :ensure t
  :config
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

;; 代码补全工具
(use-package company
  :ensure t
  :config
  (add-hook 'after-init-hook 'global-company-mode))

;; 代码检查工具
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;; 代码折叠工具
(use-package which-key
  :ensure t
  :config
  (which-key-mode))

;; 初始化包管理器
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

;; 如果没有安装use-package，则自动安装
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;; 自动更新包
(use-package auto-package-update
  :ensure t
  :config
  (setq auto-package-update-delete-old-versions t
        auto-package-update-interval 7)
  (auto-package-update-maybe))

;; 界面设置
;; (tool-bar-mode -1) ;; 关闭工具栏
;; (menu-bar-mode -1) ;; 关闭菜单栏
;; (scroll-bar-mode -1) ;; 关闭滚动条
(setq inhibit-startup-screen t) ;; 关闭启动画面

;; 安装主题
(unless (package-installed-p 'monokai-theme)
  (package-refresh-contents)
  (package-install 'monokai-theme))

;; 设置主题
;; (load-theme 'monokai t)

;; 更多个性化设置...
;; 例如，设置缩进、启用语法高亮等
;; 结尾处不需要添加任何特定的关闭标记
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(lsp-ui company-lsp lsp-mode smartparens parinfer pyenv-mode elpy flycheck-irony company-irony irony company-tern tern js2-mode auto-package-update)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(global-set-key (kbd "C-c t") (lambda ()
                                (interactive)
                                (eshell)))

(defun close-eshell-and-return ()
  "关闭当前的eshell窗口并返回到先前的缓冲区。"
  (interactive)
  (if (equal major-mode 'eshell-mode)
      (progn
        (kill-buffer (current-buffer))  ;; 关闭当前的eshell缓冲区
        (delete-window))  ;; 如果eshell在自己的窗口中打开，则关闭这个窗口
    (message "不在eshell模式下。")))

;; 将这个函数绑定到一个快捷键上，例如C-c e。
(global-set-key (kbd "C-c e") 'close-eshell-and-return)

;; JavaScript 支持
(use-package js2-mode
  :ensure t
  :mode "\\.js\\'"
  :config
  (add-hook 'js2-mode-hook (lambda () (tern-mode t)))
  (add-hook 'js2-mode-hook #'js2-refactor-mode))

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (js-mode . lsp-deferred)
  :config
  (setq lsp-enable-snippet nil))  ; 如果不想使用snippet补全，可以设置为nil

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook
  ((js-mode . lsp-deferred)  ; 或其他适用于你项目的模式，比如js2-mode、typescript-mode等
   (lsp-mode . lsp-enable-which-key-integration))
  :init
  (setq lsp-enable-snippet nil)  ; 根据你的偏好启用或禁用snippets
  (setq lsp-keymap-prefix "C-c l")  ; 定义LSP的快捷键前缀，可按需调整
)

(use-package company
  :ensure t
  :hook (after-init . global-company-mode)
  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.0))  ; 调整补全菜单弹出的延迟和触发补全的最小前缀长度

;; 可选，为LSP模式启用更丰富的前端显示，例如图标、颜色等
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-sideline-enable nil  ; 根据个人喜好启用或禁用侧边提示
        lsp-ui-doc-enable false))  ; 同上，针对悬浮文档

;; 如果你使用的是js2-mode或其他JavaScript模式，确保也加载了相应的包
(use-package js2-mode
  :ensure t
  :mode "\\.js\\'")

;; C/C++ 支持
(use-package irony
  :ensure t
  :config
  (add-hook 'c++-mode-hook 'irony-mode)
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options))

(use-package company-irony
  :ensure t
  :config
  (add-to-list 'company-backends 'company-irony))

(use-package flycheck-irony
  :ensure t
  :config
  (add-hook 'flycheck-mode-hook #'flycheck-irony-setup))

;; Python 支持
(use-package elpy
  :ensure t
  :init
  (elpy-enable))

(use-package pyenv-mode
  :ensure t)

;; Emacs Lisp 支持

(use-package smartparens
  :ensure t
  :config
  (smartparens-global-mode t))
