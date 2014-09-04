(in-package :cl-ironmq)

;; TODO: SPlit into 1 file for public API functions, 1 file for core stuff

;; TO BE REMOVED !!!!
(defvar test-project-id "53d804f2da916e00090000a5")
(defvar test-token "_1ifGppESVpqirvupNodCI0deDQ")
(setf drakma:*header-stream* *standard-output*)
(defun dbg (label value)
  (format t "[DBG] ~A: ~A~%" label value)
  value)

(defvar *user-agent* 
  (format nil "cl-ironmq (~A)"
          (asdf::component-version (asdf::find-system 'cl-ironmq))))

(defvar *aws-host* "mq-aws-us-east-1.iron.io")
(defvar *rackspace-host* "mq-rackspace-dfw.iron.io")

(defun make-client (token project-id &key (api-version 1)
                                          (scheme "https")
                                          (host *aws-host*)
                                          (port 443)
                                          (max-retries 5))
  "Creates an IronMQ client from the passed token, project-id and options.

token - can be obtained from hud.iron.io/tokens
project-id - can be obtained from hud.iron.io

Options can be:
:api-version - the version of the API to use, as an int. Defaults to 1.
:scheme - the HTTP scheme to use when communicating with the server. Defaults to https.
:host - the API's host. Defaults to aws-host, the IronMQ AWS cloud. Can be a string
      or rackspace-host, which holds the host for the IronMQ Rackspace cloud.
:port - the port, as an int, that the server is listening on. Defaults to 443.
:max-retries - maximum number of retries on HTTP error 503."
  
  ;; A "client" will just be a plist containing the connection specifics 
  (list :token token
        :project-id project-id
        :api-version api-version
	:scheme scheme
        :host host
        :port port
        :max-retries max-retries))

(defun plist-keywords-to-strings (pl)
  (loop for (key val) :on pl :by #'cddr
       :collect (string key)
       :collect val))

(defun make-out-message (body &rest options)
  (setf (getf options :body) body)
  (apply #'st-json:jso (plist-keywords-to-strings options)))

(defun make-out-message-if-needed (m)
  (if (stringp m)
      (make-out-message m)
      m))

(defstruct message 
  id 
  body)

(defun jso->message (jso)
  (make-message :id (st-json:getjso "id" jso)
		:body (st-json:getjso "body" jso)))

(defun request (client method endpoint body)
  (let* ((path (format nil "/~A/projects/~A~A"
		       (getf client :api-version)
		       (getf client :project-id)
		       endpoint))
	 (url (format nil "~A://~A:~A~A" 
		      (getf client :scheme)
		      (getf client :host)
		      (getf client :port)
		      path))
	 (request-headers `((:Authorization . ,(format nil "OAuth ~A" 
						       (getf client :token))))))
    (multiple-value-bind (result code headers)
	(drakma:http-request url
			     :method method
			     :content-type "application/json"
			     :content (unless (null body)
					(st-json:write-json-to-string body))
			     :user-agent *user-agent*
			     :additional-headers request-headers
			     :want-stream t)
      (cond
	((eq code 200) (st-json:read-json result))
	(t "SOMETHING BAD HAPPENED")))))

(defun resource (&key queue (messages nil) message n)
  "Helper function to construct resource paths"
  (concatenate 'string
	       "/queues" 
	       (if queue (format nil "/~A" queue))
	       (if (or messages message) "/messages")
	       (if message (format nil "/~A" message))
	       (if n (format nil "?n=~A" n))))

(defun queues (client)
  "Returns a list of queues that a client has access to."
  (mapcar (lambda (q) (st-json:getjso "name" q))
	  (request client :GET (resource) nil)))

(defun queue-size (client queue)
  (let* ((endpoint (resource :queue queue))
	 (result (request client :GET endpoint nil)))
    (st-json:getjso "size" result)))

(defun post-messages (client queue &rest messages)
  (let ((result (request client 
			 :POST (resource :queue queue 
					 :messages t)
			 (st-json:jso "messages" 
				      (mapcar #'make-out-message-if-needed 
					      messages)))))
    (st-json:getjso "ids" result)))

(defun post-message (client queue message)
  (car (post-messages client queue message)))

(defun get-messages (client queue n)
  (let ((result (request client 
			 :GET (resource :queue queue 
					:messages t 
					:n n) 
			 nil)))
    (mapcar #'jso->message 
	    (st-json:getjso "messages" result))))

(defun get-message (client queue)
  (car (get-messages client queue 1)))

(defun delete-message (client queue message)
  (let ((endpoint (resource :queue queue 
			    :message (message-id message))))
    (request client :DELETE endpoint nil)))
