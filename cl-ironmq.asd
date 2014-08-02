(in-package :asdf-user)

(asdf:defsystem :cl-ironmq
  :version "0.1.0"
  :license "MIT"
  :description "Client for IronMQ (http://www.iron.io)"
  :long-description ""
  :depends-on (:drakma)
  :serial t
  :components ((:static-file "README.md")
               (:static-file "LICENSE")
               (:module "src"
                :serial t
                :components ((:file "package")
                             (:file "client")))))