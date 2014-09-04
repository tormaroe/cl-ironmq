(in-package :cl-user)

(defpackage :cl-ironmq
  (:use :common-lisp 
        :drakma
	:st-json)
        
  (:export
  
   ;;
   *user-agent*
   *aws-host*
   *rackspace-host*  ; TODO: Add other hosts (http://dev.iron.io/mq/reference/api/#base_url)

   ;;
   :make-client

   ;;
   :request
   
   ;; QUERIES

   :queues
   :queue-size
   :get-messages  ; TODO: optional delete, wait, timeout
   :get-message
   ; TODO :get-message-by-id

   :message-id     ; access id slot of message struct
   :message-body   ; access body slot of message struct

   ;; COMMANDS

   ; TODO :delete-queue
   ; TODO :clear-queue
   :post-messages
   :post-message
   ; TODO :delete-messages
   :delete-message
   ; TODO :touch-message
   ; TODO :release-message
   ))
