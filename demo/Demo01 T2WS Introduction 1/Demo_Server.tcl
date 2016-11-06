##########################################################################
# T2WS - Tiny Tcl Web Server
##########################################################################
# Demo_Server.tcl - T2WS demo server, T2WS documentation example, introduction 1
# 
# Copyright (C) 2016 Andreas Drollinger
##########################################################################
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
##########################################################################


#### Responder commands ####

	# A single responder command is used for all request.

	proc MyResponder {Request} {
		# Process the request URI: Extract a command and its arguments
		regexp {^/(\w*)/(.*)$} [dict get $Request URI] {} Command Arguments
		
		# Implement the different commands (eval <TclCommand>, file <File>)
		switch -exact -- $Command {
			"eval" {
				set Data [uplevel #0 $Arguments]
				return [dict create Body $Data Content-Type "text/plain"] }
			"file" {
				return [dict create File $Arguments] }
		}
		
		# Return the status 404 (not found) if the command is unknown
		return [dict create Status "404"]
	}


#### Load the server GUI ####

	# Define the ConfigureResponder procedure. It will be used by the server GUI 
	# to configure the responder commands

	proc ConfigureResponder {Port} {
		t2ws::DefineRoute $Port ::MyResponder
	}

	# Source the server GUI that will itself load the T2WS package

	source [file join [file dirname [info script]] .. _support ServerGui.tcl]
