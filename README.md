#IronMQ Common Lisp Client

##Installation
_TODO_

##Create a client

In order to use cl-ironmq you first need to create a client. This is done by sending your OAuth token and project id to `make-client`.

    (cl-ironmq:make-client "token" "project id")

Optional arguments that can be specified are `api-version`, `host`, and `port`.

    (cl-ironmq:make-client "token"
                           "project-id"
                           :api-version 1
                           :host cl-ironmq:*aws-host*
                           :port 443)

The result of calling `make-client` is a plist which you pass as the first argument to all other API functions.

##Query queues

###queues
To get a list of the project's available queues you may now call the `queues` function:

    (cl-ironmq:queues client) ; => ("Queue1" "Queue2")

###queue-size
Query how many messages are available in a queue by it's name:

    (cl-ironmq:queue-size client "Queue1") ; => 42

##Produce messages
_TODO_

##Consume messages
_TODO_


##Misc.

###User agent
_TODO_
