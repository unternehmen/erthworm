; -*- wisp -*-

define-module
  erthworm
  . #:use-module : srfi srfi-9
  . #:use-module : ice-9 match
  . #:export : sopher->string run-server

define : tabulate . fields
  string-join fields "\t"

define link-types
  '
    html      . "h"
    directory . "1"
    text      . "0"
    binary    . "9"
    gif       . "g"
    image     . "I"
    query     . "7"

define : link-type-sym? obj
  pair? : assoc obj link-types

define : link-type-sym->string sym
  assoc-ref link-types sym

define : sopher->string sopher
  string-join
    append
      map
        lambda : line-def
          match line-def
            : 'info str
              tabulate (string-append "i" str) "fake" "(NULL)" "0"
            : 'error str
              tabulate (string-append "3" str) "fake" "(NULL)" "0"
            : (? link-type-sym? sym) str selector host (? number? port)
              tabulate
                string-append (link-type-sym->string sym) str
                . selector
                . host
                number->string port
            : (? string? str)
              str
        . sopher
      . '(".")
    . "\r\n"

define-record-type <client>
  make-client socket addr
  . client?
  socket client-socket
  addr client-addr

define* : gopher-open #:key (port 70)
  let : : server-socket : socket PF_INET SOCK_STREAM 0
    begin
      display
        string-append
          . "Opening server on port "
          . (number->string port)
          . "... "
      setsockopt server-socket SOL_SOCKET SO_REUSEADDR 1
      bind server-socket AF_INET INADDR_ANY port
      listen server-socket 5
      display "okay."
      newline
      . server-socket

define : gopher-accept server-socket
  let : : client-connection : accept server-socket
    let
      :
        client-addr   : cdr client-connection
        client-socket : car client-connection
      begin
        display
          string-append
            . "Connection from "
            inet-ntop
              . AF_INET
              sockaddr:addr client-addr
            . "."
        newline
        make-client client-socket client-addr

define : gopher-read client-socket
  let loop : (selector "") (prev #\space)
    let : : next : read-char client-socket
      cond
        (eof-object? next)
          if : string-null? selector
            . #f
            . selector
        {(char=? prev #\return) and (char=? next #\newline)}
          string-drop-right
            string-append selector : string next
            . 2
        else
          loop
            string-append selector : string next
            . next

define : gopher-write client-socket response
  display response client-socket

define : run-server selector-handler open-args
  let : : server-socket : apply gopher-open open-args
    let loop : : clients '()
      let*
        :
          client-sockets : map client-socket clients
          all-sockets : cons server-socket client-sockets
          active : caar : select all-sockets '() '()
        if : equal? active server-socket
          loop : cons (gopher-accept server-socket) clients
          let : : selector : gopher-read active
            begin
              if : string? selector
                gopher-write
                  . active
                  selector-handler selector
              close active
              loop
                filter
                  lambda : c
                    not : equal? (client-socket c) active
                  . clients
