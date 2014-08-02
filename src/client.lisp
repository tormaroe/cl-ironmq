(in-package :cl-ironmq)

;; TO BE REMOVED !!!!
(defvar test-project-id "53d804f2da916e00090000a5")
(defvar test-token "_1ifGppESVpqirvupNodCI0deDQ")

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

(defun make-message (body &rest options)
  ""
  (setf (getf options :body) body)
  options)

(defun request (client method endpoint body)
  ""
  nil)

(defun queues (client)
  "Returns a list of queues that a client has access to."
  (mapcar (lambda (q) (getf q "name"))
	  (request client "GET" "/queues" nil)))

(defun queue-size (client queue)
  ""
  nil)

(defun post-messages (client queue &rest messages)
  ""
  messages)