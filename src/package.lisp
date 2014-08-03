(in-package :cl-user)

(defpackage :cl-ironmq
  (:use :common-lisp 
        :drakma
	:st-json)
        
  (:export
  
   ;;
   *user-agent*

   ;;
   :make-client

   ;;
   :request
   
   ;;
   :queues
   :queue-size
   :get-messages
   :get-message

   ;;
   :post-messages
   :post-message
   :delete-message
   ))
