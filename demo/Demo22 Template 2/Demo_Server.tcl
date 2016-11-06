##########################################################################
# T2WS - Tiny Tcl Web Server
##########################################################################
# Demo_Server.tcl - T2WS demo server, T2WS template example 1
#
# Copyright (C) 2016 Andreas Drollinger
##########################################################################
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
##########################################################################


#### Responder commands ####

	# File responder command: Returns the requested file. If no file name is 
	# provided, Main.htmt is returned. For files that have the extension .htmt 
	# the template template engine is called (ProcessTemplateFile).

	proc Responder_GetFile {Request} {
		set File [dict get $Request URITail]
		if {$File==""} {
			set File "Main.htmt" }
		switch [file extension $File] {
			.html - htm - .css {
				return [dict create File $File]}
			.htmt {
				return [dict create Body [t2ws::template::ProcessTemplateFile $File] Content-Type .html]}
			default {
				return [dict create Status "403"]}
		}
	}

	
#### Load the server GUI ####

	# Define the ConfigureResponder procedure. It will be used by the server GUI 
	# to configure the responder commands

	proc ConfigureResponder {Port} {
		t2ws::DefineRoute $Port ::Responder_GetFile -method GET -uri /*
		
		# The plugin t2ws::template has not to be enabled, since the template 
		# processor is called explicitly by the responder command (ProcessTemplateFile).
	}

	# Source the server GUI that will itself load the T2WS package

	source [file join [file dirname [info script]] .. _support ServerGui.tcl]
	package require t2ws::template
