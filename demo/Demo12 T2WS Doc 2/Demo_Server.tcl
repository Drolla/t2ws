##########################################################################
# T2WS - Tiny Tcl Web Server
##########################################################################
# Demo_Server.tcl - T2WS demo server
# 
# T2WS demo server with 3 responder commands
#
# Copyright (C) 2016 Andreas Drollinger
##########################################################################
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
##########################################################################


#### Responder commands ####

	# The following responder command returns simply the HTTP status 404. It can 
	# be defined to respond to invalid requests.

	proc Responder_General {Request} {
		return [dict create Status "404"]
	}

	# The next responder command extracts from the request URI a Tcl command. 
	# This one will be executed and the result returned in the respond body.

	proc Responder_GetApi {Request} {
		set TclScript [dict get $Request URITail]
		if {[catch {set Result [uplevel #0 $TclScript]}]} {
			return [dict create Status "405" Body "405 - Incorrect Tcl command: $TclScript"] }
		return [dict create Body $Result]
	}

	# The next responder command extracts from the request URI a File name, that 
	# will be returned to the T2WS web server. The file server will return to 
	# the client the file content.

	proc Responder_GetFile {Request} {
		set File [dict get $Request URITail]
		return [dict create File $File]
	}

#### Load the server GUI ####

	# Define the ConfigureResponder procedure. It will be used by the server GUI 
	# to configure the responder commands

	proc ConfigureResponder {Port} {
		t2ws::DefineRoute $Port ::Responder_General -method * -uri *
		t2ws::DefineRoute $Port ::Responder_GetApi -method GET -uri /api/*
		t2ws::DefineRoute $Port ::Responder_GetFile -method GET -uri /file/*
	}

	# Source the server GUI that will itself load the T2WS package

	source [file join [file dirname [info script]] .. _support ServerGui.tcl]
