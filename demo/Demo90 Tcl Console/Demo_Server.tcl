##########################################################################
# T2WS - Tiny Tcl Web Server
##########################################################################
# Demo_Server.tcl - T2WS demo server
# 
# Tcl console in web browser
#
# Copyright (C) 2016 Andreas Drollinger
##########################################################################
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
##########################################################################


package require json::write

#### Responder commands ####

	# A single responder command is used for all request.

	proc Responder_TclCmd {Request} {
		set TclCmd [dict get $Request Body]
		
		variable Return
		array set Return {
			Status 200
			Result ""
			Error ""
			StdOut ""
			StdErr ""
		}
		
		if {![info complete $TclCmd]} {
			set Return(Status) 406
			set Return(Result) "406 - Incomplete command"
		} else {
			interp alias {} ::puts {} ::DServer_Puts
			set Err [catch [list uplevel #0 $TclCmd] Return(Result)]
			interp alias {} ::puts {} ::DServer_PutsOrig
			if {$Err} {
				set Return(Error) $::errorInfo
				set Return(Result) ""
			}
		}
		
		set Body [json::write object \
			result [::json::write string $Return(Result)] \
			error [::json::write string $Return(Error)] \
			stdout [::json::write string $Return(StdOut)] \
			stderr [::json::write string $Return(StdErr)] \
		]
		
		return [dict create Status $Return(Status) Body $Body]
	}

	# The next responder command extracts from the request URI a File name, that 
	# will be returned to the T2WS web server. The file server will return to 
	# the client the file content.

	proc Responder_GetFile {Request} {
		set File [dict get $Request URITail]
		if {$File==""} {
			set File "TclConsole.html"}
		return [dict create File $File]
	}

	# Derived from http://wiki.tcl.tk/14701 (that is itself derived from tkcon)

	proc DServer_Puts args {
		variable Return
		set NbrArgs [llength $args]
		foreach {arg1 arg2 arg3} $args { break }
	
		switch $NbrArgs {
			1 {
				append Return(StdOut) "$arg1\n"
			}
			2 {
				switch -- $arg1 {
					-nonewline {
						append Return(StdOut) $arg2 }
					stdout {
						append Return(StdOut) "$arg2\n" }
					stderr {
						append Return(StdErr) "$arg2\n" }
					default {
						set NbrArgs 0 }
				}
			}
			3 {
				if {$arg1=="-nonewline" && $arg2=="stdout"} {
					append Return(StdOut) $arg3
				} elseif {$arg1=="-nonewline" && $arg2=="stderr"} {
					append Return(StdErr) $arg3
				} elseif {$arg3=="-nonewline" && $arg1=="stdout"} {
					append Return(StdOut) $arg2
				} elseif {$arg3=="-nonewline" && $arg1=="stderr"} {
					append Return(StdErr) $arg2
				} else {
					set NbrArgs 0
				}
			}
			default {
				set NbrArgs 0
			}
		}
		## $NbrArgs == 0 means it wasn't handled above.
		if {$NbrArgs == 0} {
			global errorCode errorInfo
			if {[catch [::DServer_PutsOrig {*}$args] msg]} {
				return -code error $msg
			}
			return $msg
		}
	}
	
	if {[info procs ::DServer_PutsOrig]=={}} {
		rename ::puts ::DServer_PutsOrig
	}
	interp alias {} ::puts {} ::DServer_PutsOrig


#### Load the server GUI ####

	# Define the ConfigureResponder procedure. It will be used by the server GUI 
	# to configure the responder commands

	proc ConfigureResponder {Port} {
		t2ws::DefineRoute $Port ::Responder_GetFile -method GET -uri /*
		t2ws::DefineRoute $Port ::Responder_TclCmd -method POST -uri /*
	}

	# Source the server GUI that will itself load the T2WS package

	source [file join [file dirname [info script]] .. _support ServerGui.tcl]
