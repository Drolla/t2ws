##########################################################################
# T2WS - Tiny Tcl Web Server
##########################################################################
# Demo_Server.tcl - T2WS demo server
# 
# T2WS demo server with a single responder command
#
# Copyright (C) 2016 Andreas Drollinger
##########################################################################
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
##########################################################################


#### Responder commands ####

	# A single responder command is used for all request.

	proc Responder_General {Request} {
		regexp {^/(\w*)(?:[/ ](.*))?$} [dict get $Request URI] {} Target ReqLine
		switch -exact -- $Target {
			"" -
			"help" {
				set Data "<h1>THC HTTP Debug Server</h1>\n\
							 help: this help information<br>\n\
							 eval <TclCommand>: Evaluate a Tcl command and returns the result<br>\n\
							 file/show <File>: Get file content<br>\n\
							 download <File>: Get file content (force download in a browser)"
				return [dict create Body $Data Content-Type .html]
			}
			"eval" {
				if {[catch {set Data [uplevel #0 $ReqLine]}]} {
					return [dict create Status "405" Body "405 - Incorrect Tcl command: $ReqLine"] }
				return [dict create Body $Data]
			}
			"file" - "show" {
				return [dict create File $ReqLine Content-Type "text/plain"]
			}
			"download" {
				return [dict create File $ReqLine Content-Type "" Header [dict create Content-Disposition "attachment; filename=\"[file tail $ReqLine]\""]]
			}
			"default" {
				return [dict create Status "404" Body "404 - Unknown command: $ReqLine. Call 'help' for support."]
			}
		}
	}

#### Load the server GUI ####

	# Define the ConfigureResponder procedure. It will be used by the server GUI 
	# to configure the responder commands

	proc ConfigureResponder {Port} {
		t2ws::DefineRoute $Port ::Responder_General -method * -uri *
	}

	# Source the server GUI that will itself load the T2WS package

	source [file join [file dirname [info script]] .. _support ServerGui.tcl]
