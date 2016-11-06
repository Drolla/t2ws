##########################################################################
# T2WS - Tiny Tcl Web Server
##########################################################################
# Demo_Server.tcl - T2WS demo server, T2WS template, file browser
#
# Copyright (C) 2016 Andreas Drollinger
##########################################################################
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
##########################################################################


#### Responder command ####

	set ::RootDir ~

	# Responder command to return the main HTML page template file (Main.htmt),
	# the contents of the files stored in this demo directory, and file download
	# instructions for other files.
	
	proc Responder_GetFile {Request} {
		set File [dict get $Request URITail]
		set FullFilePath [file join $::RootDir $File]
		
		# Return the main HTML template file if no file is requested
		if {$File=="" || [file isdirectory $FullFilePath]} {
			return [dict create File "Main.htmt" IsTemplate 1 Content-Type .html]
		
		# Return the contents of the file stored in this demo directory (e.g. css
		# and PNG images used by the HTML page)
		} elseif {[file isfile $File] && [file dirname $File]=="."} {
			return [dict create File $File]

		# Return download instructions for the files stored in other directories
		} elseif {[file isfile $FullFilePath]} {
			return [dict create File $FullFilePath Content-Type "" Header [dict create Content-Disposition "attachment; filename=\"$File\""]]

		# If the requested file doesn't exist return a 404 status
		} else {
			return [dict create Status "404"]
		}
	}


#### Load the server GUI ####

	# Define the ConfigureResponder procedure. It will be used by the server GUI 
	# to configure the responder commands

	proc ConfigureResponder {Port} {
		t2ws::DefineRoute $Port ::Responder_GetFile -method GET -uri /*

		package require t2ws::template
		t2ws::EnablePlugin $Port t2ws::template
	}

	# Source the server GUI that will itself load the T2WS package

	source [file join [file dirname [info script]] .. _support ServerGui.tcl]
