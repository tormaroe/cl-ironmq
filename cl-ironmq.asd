

(asdf:defsystem :cl-ironmq
  :version "0.1.0"
  :license "MIT"
  :description ""
  :long-description ""
  :depends-on ()
  :serial t
  :components ((:static-file "README.md")
               (:static-file "LICENSE")
               (:module "src"
                :serial t
                :components ((:file "package")
                             (:file "client")))))