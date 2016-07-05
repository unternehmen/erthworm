# What is erthworm?
erthworm is a Guile 2.0 library for creating and running single-threaded,
dynamic Gopher servers.  It is modeled after the HTTP web server that
is included in the Guile standard library, but it shares no code with it.

erthworm is written in the Wisp syntax (SRFI-119), but because Wisp is
homoiconic with S-Expressions it can be compiled into regular Scheme code.
To convert it, you can use any Wisp preprocessor.

## Creating a Server
In Wisp:

    use-modules : erthworm

    define : selector-handler selector
      sopher->string
        `
          info "This is an informative line."
          info ,(string-append "Your selector was \"" selector "\".")
          html "This is an HTML link." "/test.html" "server.edu" 70

    run-server selector-handler '(#:port 7088)

## Running a Server
Guile doesn't search .w files for modules automatically, so you will
need to either rename erthworm.w to "erthworm" or make a symlink called
"erthworm" that points to erthworm.w.  On my system, I do this:

    $ ln -s erthworm.w erthworm

Guile must have access to both Wisp (if you are using the Wisp code
directly) and erthworm.  To that end, you may need to execute your
server in this way or something similar:

    $ export WISPDIR=/home/user/Downloads/wisp-0.8.6  # Depending on where you have Wisp installed/downloaded.
    $ export ERTHWORMDIR=.                            # Depending on where you have erthworm installed/downloaded.
    $ guile-2.0 -L $WISPDIR --language=wisp -L $ERTHWORMDIR -s server.w

If you following these steps, the server should start up fine.

## Problems
Persistant state is currently not passed by argument to the selector
handler, which means that maintaining any kind of server state currently
means mutating global variables.

Additionally, I have not tested whether a single client can hang the
server by, e.g., not reading data when they're supposed to.  I need to
thoroughly explore the reads and writes to make sure a client cannot
simply stall all traffic in that way.

There is also currently no cap on how many clients can be sitting
in the select list, which means that file descriptors could run out if a
bunch of people connect at once.  A better solution would be to smartly
wait until there is room for more clients to connect before accepting
a new one.

## License
erthworm is licensed under the CC0 1.0 Universal license, a copy
of which should have come with this package. To the extent possible
under law, I waive all copyright and related or neighboring rights to
erthworm. I make no warranty about the work and disclaim liability
for all uses of the work, to the extent possible under law.
