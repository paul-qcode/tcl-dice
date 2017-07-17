# Proc to display simple tcl function thats not listed in init.tcl

ns_register_proc GET /test.html test

proc test {} {
   ns_return 200 text/html "This is a test"
}
