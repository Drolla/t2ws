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

	# Two separate responder commands to handle respectively Tcl commands and 
	# file requests.

	proc MyResponder_Eval {Request} {
		set Data [uplevel #0 [dict get $Request URITail]]
		return [dict create Body $Data Content-Type "text/plain"]
	}

	proc MyResponder_File {Request} {
		return [dict create File [dict get $Request URITail]]
	}


#### Load the server GUI ####

	# Define the ConfigureResponder procedure. It will be used by the server GUI 
	# to configure the responder commands

	proc ConfigureResponder {Port} {
		t2ws::DefineRoute $Port ::MyResponder_Eval -method GET -uri "/eval/*"
		t2ws::DefineRoute $Port ::MyResponder_File -method GET -uri "/file/*"
	}

	# Source the server GUI that will itself load the T2WS package

	source [file join [file dirname [info script]] .. _support ServerGui.tcl]

	
#### Tests ####

if 0 {
   > http://localhost:8085/eval/glob *.tcl
   > -> pkgIndex.tcl t2ws.tcl t2ws_session.tcl t2ws_template.tcl
   > http://localhost:8085/file/pkgIndex.tcl
   > -> if {![package vsatisfies [package provide Tcl] 8.5]} {return}
   > -> package ifneeded t2ws 0.4 [list source [file join $dir t2ws.tcl]]
   > -> package ifneeded t2ws_template 0.2 [list source [file join $dir t2ws_template.tcl]]
   > http://localhost:8085/exec/cmd.exe
   > -> 404 Not Found
}
