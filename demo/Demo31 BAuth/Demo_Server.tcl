##########################################################################
# T2WS - Tiny Tcl Web Server
##########################################################################
# Demo_Server.tcl - T2WS demo server, basic authentication plugin
#
# Copyright (C) 2016 Andreas Drollinger
##########################################################################
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
##########################################################################


set fRMe [open [file join [file dirname [info script]] Readme.txt] r]
set HelpTxt [read $fRMe]
close $fRMe

#### Responder commands ####

	# A single responder command is used for all request.

	proc Responder_Private {Request} {
		set Target ""
		regexp {^(\w*)(?:[/ ](.*))?$} [dict get $Request URITail] {} Target ReqLine
		switch -exact -- $Target {
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

	proc Responder_Public {Request} {
		set Target ""
		regexp {^(\w*)(?:[/ ](.*))?$} [dict get $Request URITail] {} Target ReqLine
		switch -exact -- $Target {
			"" -
			"help" {
				return [dict create Body $::HelpTxt Content-Type text/plain]
			}
		}
	}

#### Load the server GUI ####

	# Define the ConfigureResponder procedure. It will be used by the server GUI 
	# to configure the responder commands

	proc ConfigureResponder {Port} {
		t2ws::DefineRoute $Port ::Responder_Public -method * -uri *
		t2ws::DefineRoute $Port ::Responder_Private -method * -uri /prv/*

		package require t2ws::bauth
		t2ws::EnablePlugin $Port t2ws::bauth -method * -uri /prv/*
	}

	# Source the server GUI that will itself load the T2WS package

	source [file join [file dirname [info script]] .. _support ServerGui.tcl]

#### Setup the BAuth plugin ####

	# Dictionary of user passwords
	set t2ws::bauth::LoginCredentials [dict create \
		Admin Password \
		User1 Password1 \
	]

