(in-package :cl-ironmq)

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

(defun make-message (body &rest options)
  ""
  (setf (getf options :body) body)
  (dbg "make-message" (apply #'st-json:jso (plist-keywords-to-strings options))))

(defun make-message-if-needed (m)
  (if (stringp m)
      (make-message m)
      m))

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
    (dbg "BODY (RAW)" body)
    (dbg "BODY (JSO)" (st-json:write-json-to-string body))
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

(defun queues (client)
  "Returns a list of queues that a client has access to."
  (mapcar (lambda (q) (st-json:getjso "name" q))
	  (request client :GET "/queues" nil)))

(defun queue-size (client queue)
  ""
  (let* ((endpoint (concatenate 'string "/queues/" queue))
	 (result (request client :GET endpoint nil)))
    (st-json:getjso "size" result)))

(defun post-messages (client queue &rest messages)
  ""
  (let* ((endpoint (concatenate 'string "/queues/" queue "/messages"))
	 (messages (mapcar #'make-message-if-needed messages))
	 (result (request client :POST endpoint
			  (st-json:jso "messages" messages))))
    (st-json:getjso "ids" result)))

(defun post-message (client queue message)
  ""
  (car (post-messages client queue message)))
