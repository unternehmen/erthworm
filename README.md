# What is `erthworm`?
`erthworm` is a Guile 2.0 library for creating and running single-threaded
Gopher servers.  It is modeled after the HTTP web server that is included
in the Guile standard library, but it shares no code with it.

`erthworm` is written in the Wisp syntax (SRFI-119), but because Wisp is
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

## License
`erthworm` is licensed under the CC0 1.0 Universal license, a copy
of which should have come with this package. To the extent possible
under law, I waive all copyright and related or neighboring rights to
`erthworm`. I make no warranty about the work and disclaim liability
for all uses of the work, to the extent possible under law.
