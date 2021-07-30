#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" ${1+"$@"}
##########################################################################
# T2WS - Tiny Tcl Web Server
##########################################################################
# rtests-all.tcl - Regression test - all
# 
# This file is part of the regression test for the T2WS web server
#
# Copyright (C) 2016 Andreas Drollinger
##########################################################################
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
##########################################################################

# Search a free port
for {set HttpPort 8080} {$HttpPort<8120} {incr HttpPort} {
	if {![catch {set ServerH [socket -server ::Dummy $HttpPort]}]} {
		close $ServerH
		break
	}
}
if {$HttpPort>=8120} {
	error "Couldn't find free port" }
puts "Free HTTP port: $HttpPort"


######## T2WS Test Server ########

	set HSI [interp create]

	interp eval $HSI "set HttpPort $HttpPort"

	interp eval $HSI {
		lappend auto_path [file join [pwd] .. ..]
		package require t2ws
	
		proc Responder_RTest {Request} {
			set GetRequestString [dict get $Request URI]
	
			regexp {^/([^\s]*)\s*(.*)$} $GetRequestString {} FirstWord RemainingLine
			switch -exact -- $FirstWord {
				"help" {
					set Data "<h1>HTTP Test Server</h1>\n\
					          help: this help information<br>\n\
								 eval <TclCommand>: Evaluate a Tcl command and returns the result<br>\n\
					          return <Answer>: Return to the HTTP server the provided answer<br>\n\
					          download <File>: Download a file (from a browser)<br>\n\
					          show <File>: Show a file (in a browser)<br>\n\
					          \"\": Empty response"
					return [dict create Body $Data Content-Type text/html]
				}
				"eval" {
					if {[catch {set Data [uplevel #0 $RemainingLine]}]} {
						return [dict create Status "404" Body "404 - Incorrect Tcl command: $RemainingLine"]
					}
					return [dict create Body $Data]
				}
				"return" {
					return [dict create {*}$RemainingLine]
				}
				"download" {
					return [dict create File $RemainingLine ContentType "" Header [dict create Content-Disposition "attachment; filename=\"[file tail $RemainingLine]\""]]
				}
				"show" {
					return [dict create File $RemainingLine ContentType  "text/plain"]
				}
				"" {
					return [dict create]
				}
				"default" {
					return [dict create Status "404" Body "404 - Unknown command: $FirstWord"]
				}
			}
		}

		proc Responder_OtherRoute {args} {
			set Request [lindex $args end]
			set OtherArgs [lrange $args 0 end-1]
			set GetRequestString [dict get $Request URI]
			return [dict create Body "Request:$GetRequestString\nOtherArgs:$OtherArgs"]
		}
	
		set Server [t2ws::Start $HttpPort -responder ::Responder_RTest]
		t2ws::DefineRoute $Server ::Responder_OtherRoute -uri "/route2/*"
		t2ws::DefineRoute $Server [list ::Responder_OtherRoute "FixedArg1" "FixedArg2"] -uri "/route3/*"
	}

	
######## T2WS Client support functions ########

	proc HttpReadInputData {} {
		global HttpSocket InputData
		append InputData [read $HttpSocket]
		if {[eof $HttpSocket]} {
			close $HttpSocket }
	}

	proc HttpTransaction {OutputData} {
		global HttpPort HttpSocket InputData
		set InputData ""

		set HttpSocket [socket localhost $HttpPort]
		fileevent $HttpSocket readable HttpReadInputData

		puts -nonewline $HttpSocket $OutputData
		flush $HttpSocket

		vwait InputData
		return $InputData
	}
	
	package require tcltest
	tcltest::configure -verbose p


######## Regression test ########

	# Empty response
		tcltest::test "empty" "Empty response" \
			-match exact \
			-body {HttpTransaction [join {
				"GET / HTTP/1.1"
				"Accept: */*"
				"User-Agent: Tcl http test client"
				"Connection: close"
				""
			} \n]} \
			-result [join {
				"HTTP/1.1 200 OK"
				"Connection: close"
				"Content-Type: text/plain"
				"Content-Length: 0"
				""
				""
			} \n]

	# Default content type
		tcltest::test "default" "Default content type" \
			-match exact \
			-body {HttpTransaction [join {
				"GET /eval expr 123 HTTP/1.1"
				"Accept: */*"
				"User-Agent: Tcl http test client"
				"Connection: close"
				""
			} \n]} \
			-result [join {
				"HTTP/1.1 200 OK"
				"Connection: close"
				"Content-Type: text/plain"
				"Content-Length: 3"
				""
				"123"
			} \n]

		# HTML response
		tcltest::test "html" "HTML response" \
			-match exact \
			-body {HttpTransaction [join {
				"GET /help HTTP/1.1"
				"Accept: */*"
				"User-Agent: Tcl http test client"
				"Connection: close"
				""
			} \n]} \
			-result [join {
				"HTTP/1.1 200 OK"
				"Connection: close"
				"Content-Type: text/html"
				"Content-Length: 316"
				""
				"<h1>HTTP Test Server</h1>"
				" help: this help information<br>"
				" eval <TclCommand>: Evaluate a Tcl command and returns the result<br>"
				" return <Answer>: Return to the HTTP server the provided answer<br>"
				" download <File>: Download a file (from a browser)<br>"
				" show <File>: Show a file (in a browser)<br>"
				" \"\": Empty response"
			} \n]

	# Extra header attributes
		tcltest::test "extra_header" "Extra header attributes" \
			-match exact \
			-body {HttpTransaction [join {
				"GET /return Body \"My result\" Header {Test \"My test header\"} HTTP/1.1"
				"Accept: */*"
				"User-Agent: Tcl http test client"
				"Connection: close"
				""
			} \n]} \
			-result [join {
				"HTTP/1.1 200 OK"
				"Connection: close"
				"Test: My test header"
				"Content-Type: text/plain"
				"Content-Length: 9"
				""
				"My result"
			} \n]

	# Other Route, no additional arguments
		tcltest::test "oroute_naa" "Other route, no additional arguments" \
			-match exact \
			-body {HttpTransaction [join {
				"GET /route2/hello HTTP/1.1"
				"Accept: */*"
				"User-Agent: Tcl http test client"
				"Connection: close"
				""
			} \n]} \
			-result [join {
				"HTTP/1.1 200 OK"
				"Connection: close"
				"Content-Type: text/plain"
				"Content-Length: 32"
				""
				"Request:/route2/hello"
				"OtherArgs:"
			} \n]

	# Other Route, with additional arguments
		tcltest::test "oroute_naa" "Other route, no additional arguments" \
			-match exact \
			-body {HttpTransaction [join {
				"GET /route3/hello HTTP/1.1"
				"Accept: */*"
				"User-Agent: Tcl http test client"
				"Connection: close"
				""
			} \n]} \
			-result [join {
				"HTTP/1.1 200 OK"
				"Connection: close"
				"Content-Type: text/plain"
				"Content-Length: 51"
				""
				"Request:/route3/hello"
				"OtherArgs:FixedArg1 FixedArg2"
			} \n]


######## Done ########

	tcltest::cleanupTests
	
	interp eval $HSI {
		t2ws::Stop
	}
