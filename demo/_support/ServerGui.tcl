##########################################################################
# T2WS - Tiny Tcl Web Server
##########################################################################
# Server.tcl - T2WS demo server, common demo GUI
# 
# This file provides the framework used by all the provided T2WS demo examples.
#
# Copyright (C) 2016 Andreas Drollinger
##########################################################################
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
##########################################################################


# Load T2WS, patch the WriteLog command to write into the message widget

	set auto_path [concat [list [file join [file dirname [info script]] .. ..]] $auto_path]
	package require t2ws
	package require Tk

	t2ws::Configure -log_level 3

	proc t2ws::WriteLog {Message Tag} {
		$::LogW insert end "$Message\n" $Tag
		$::LogW see end
	}

# Server demo configuration

	# Default configuration
	array set Config {
		port ""
		protocol " "
		content-type " "
		zip_threshold 100
	}

	# HTTP server (re-) configuration. If necessary the server is stopped and 
	# restarted.
	
	proc Configure {Attribute Value {Force 0}} {
		set Value [string trim $Value]
		switch $Attribute {
			"port" {
				if {![string is integer -strict $Value] ||
				    (!$Force && [dict exists $t2ws::Server $Value])} {
					return 0}
				t2ws::Stop
				t2ws::Start $Value
				ConfigureResponder $Value
			}
			"protocol" {
				t2ws::Configure -protocol "HTTP/$Value"
			}
			"content-type" {
				t2ws::Configure -default_Content-Type $Value
			}
			"zip_threshold" {
				t2ws::Configure -zip_threshold $Value
			}
		}
		return 1
	}

# Procedure to open the web browser with the defined port. Derived from 
# http://wiki.tcl.tk/557

	proc OpenBrowser {} {
		set Url "http://localhost:$::Config(port)"
	
		set Command [auto_execok xdg-open]
		if {$Command==""} {
			set Command [auto_execok open] }
		if {$Command==""} {
			set Command [list {*}[auto_execok start] {}] }

		if {[string length $Command] == 0} {
			error "Couldn't find any browser!" }
		if {[catch {exec {*}$Command $Url &} Err]} {
			error "Couldn't execute '$Command': $Err" }
	}

# Print the readme file into the demo text widget.
	
	proc PrintReadme {} {
		global DemoW
		$DemoW tag configure ReadmeCode -foreground blue

		if {[file exists Readme.txt]} {
			set f [open Readme.txt r]
			while {[gets $f Line]>=0} {
				if {[regexp {^\s} $Line]} {
					$DemoW insert end "$Line\n" ReadmeCode
				} else {
					$DemoW insert end "$Line\n"
				}
			}
			close $f
		}
	}

# Print the responder command definition into the demo text widget. Each
# identified responder command will be shown as link that can be selected.

	proc PrintResponderPluginDefinitions {} {
		global DemoW

		set DefineRoutes {}
		set DefineOthers {}
		foreach Line [split [info body ::ConfigureResponder] "\n"] {
			set Line [string trim $Line]
			if {$Line==""} {
			} elseif {[lindex $Line 0]=="t2ws::DefineRoute"} {
				lappend DefineRoutes $Line
			} else {
				lappend DefineOthers $Line
			}
		}

		set Step 0
		$DemoW insert end "\nResponder commands (click for details):\n"
		foreach Line $DefineRoutes {
			incr Step
			$DemoW insert end "  $Line\n" step$Step
			$DemoW tag configure step$Step -background "pale green" -relief flat
        	$DemoW tag bind step$Step <Any-Enter> "$DemoW tag configure step$Step -background {dark green} -relief raised -borderwidth 1"
        	$DemoW tag bind step$Step <Any-Leave> "$DemoW tag configure step$Step -background {pale green} -relief flat"
        	$DemoW tag bind step$Step <1> "ShowResponderCommand [lindex $Line 2]"
		}
		
		if {$DefineOthers=={}} return

		$DemoW insert end "\nPlugin and other definitions:\n"
		$DemoW tag configure others -background "light yellow" -relief flat
		foreach Line $DefineOthers {
			$DemoW insert end "  $Line\n" others
		}
	}

# Show the selected responder command in a separate window (procedure 
# declaration and body).

	proc ShowResponderCommand {ResponderCommand} {
		global RCmdW
		if {![winfo exists .rcmd]} {
			toplevel .rcmd
			set RCmdW [ScrollText .rcmd.e -width 80 -height 24]
			pack .rcmd.e -expand yes -fill both

			menu .rcmd.menu
				.rcmd.menu add command -label "Close" -command {destroy .rcmd}
			.rcmd configure -menu .rcmd.menu
		}
		
		set Body [info body $ResponderCommand]
		set Body [string trim $Body "\n"]
		set Body [regsub -all "\t" $Body "   "]
		regexp {^(\s*)} $Body {} FirstLineIntention
		set Body [regsub -all -line "^$FirstLineIntention" $Body "   "]

		$RCmdW delete 0.0 end
		$RCmdW insert end "proc $ResponderCommand {} \{\n"
		$RCmdW insert end $Body
		$RCmdW insert end "\}"

		raise .rcmd
	}

# Implementation of a scrollable text (mega) widget. The path of the used text 
# widget is returned.

	proc ScrollText {W args} {
		frame $W
		grid [text $W.text -wrap none -yscrollcommand "$W.yscrollbar set" -xscrollcommand "$W.xscrollbar set" {*}$args] -column 0 -row 0 -pady 2 -sticky news
		grid [scrollbar $W.yscrollbar -command "$W.text yview"] -column 1 -row 0 -pady 2 -sticky ns
		grid [scrollbar $W.xscrollbar -command "$W.text xview" -orient horizontal] -column 0 -row 1 -sticky ew
		grid columnconfigure $W 0 -weight 1
		grid rowconfigure $W 0 -weight 1
		return $W.text
	}

# Procedure to open a Tcl console attached to this demo GUI. Various consoles 
# are tried to be used (TCon, Windows console).

	proc OpenConsole {} {
	   if {[catch {set ::tkcon::PRIV(root)}]} {
	      # Set PRIV(root) to an existing window to avoid a console creation
	      namespace eval ::tkcon {
	         set PRIV(root) .tkcon
	         set OPT(exec) ""
	         set OPT(slaveexit) "close"
	      }
	      # Search inside the *n.x environment for TkCon ('tkcon' and 'tkcon.tcl') ...
	      set TkConPath ""
	      catch {set TkConPath [exec which tkcon]}
	      if {$TkConPath==""} {catch {set TkConPath [exec which tkcon.tcl]}}
			
	      # Search inside the Windows environment for TkCon ...
	      catch {
	         package require registry
	         set TkConPath [registry get {HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\tclsh.exe} Path]/tkcon.tcl
	         regsub -all {\\} $TkConPath {/} TkConPat
	      }
	      if {$TkConPath!=""} {
	         # hide the standard console (only windows)
	         catch {console hide}
	
	         # Source tkcon. "Usually" this should also start the tkcon window.
	         set ::argv ""
	         uplevel #0 "source \{$TkConPath\}"
	
	         # TkCon versions have been observed that doesn't open the tkcon window during sourcing of tkcon. Initialize tkcon explicitly:
	         if {[lsearch [winfo children .] ".tkcon"]<0 && [lsearch [namespace children ::] "::tkcon"]} {
	            ::tkcon::Init
	         }
	         tkcon show
	      } else {
	         if {$::tcl_platform(platform)=={windows}} {
	            console show
	         } else {
	            tk_messageBox -title "TkCon not found" -message "Cannot find tkcon.tcl." -type ok
	         }
	      }
	   } else {
	      if {[catch {wm deiconify $::tkcon::PRIV(root)}]} {
	         if {$::tcl_platform(platform)=={windows}} {
	            console show
	         } else {
	            tk_messageBox -title "Tk not available" -message "Cannot deiconify tkcon!" -type ok
	         }
	      }
	   }
	}
	
# Gui and default configuration
	package require Tk

	wm title . "HTTP server"

	grid columnconfigure . 1 -weight 1

# Main left/right pane
	panedwindow .main -sashpad 2 -sashwidth 4 -handlesize 8 -showhandle 1 -sashrelief sunken
		pack .main -side top -expand yes -fill both -pady 2 -padx 2m
	frame .main.left
	frame .main.right
	.main add .main.left .main.right
	
	grid columnconfigure .main.left 1 -weight 1
	grid rowconfigure .main.left 1 -weight 1

# Configuration
	grid [labelframe .main.left.cfg -text "Configurations"] -row 0 -column 0 -sticky ew

	# Port
	set Row -1
	grid [label .main.left.cfg.port_l -text "Port number"] -row [incr Row] -column 0 -sticky w
	grid [entry .main.left.cfg.port_e -validate focusout -textvariable Config(port)] -row $Row -column 1 -sticky ew
		.main.left.cfg.port_e configure -vcmd {Configure "port" %P} 

	# Response protocol
	grid [label .main.left.cfg.protocol_l -text "Default protocol"] -row [incr Row] -column 0 -sticky w
	grid [frame .main.left.cfg.protocol_e] -row $Row -column 1 -sticky w
		pack [radiobutton .main.left.cfg.protocol_e.default -text "As client requests" -value " " -variable Config(protocol)] -side left
		pack [radiobutton .main.left.cfg.protocol_e.h10 -text "HTTP 1.0" -value "1.0" -variable Config(protocol) -command {Configure "protocol" 1.0}] -side left
		pack [radiobutton .main.left.cfg.protocol_e.h11 -text "HTTP 1.1" -value "1.1" -variable Config(protocol) -command {Configure "protocol" 1.1}] -side left

	# Content-Type
	grid [label .main.left.cfg.contenttype_l -text "Default Content-Type"] -row [incr Row] -column 0 -sticky w
	grid [frame .main.left.cfg.contenttype_e] -row $Row -column 1 -sticky w
		pack [radiobutton .main.left.cfg.contenttype_e.none -text "None" -value " " -variable Config(content-type) -command {Configure "content-type" ""}] -side left
		pack [radiobutton .main.left.cfg.contenttype_e.text -text "Text" -value "text/plain" -variable Config(content-type) -command {Configure "content-type" "text/plain"}] -side left
		pack [radiobutton .main.left.cfg.contenttype_e.html -text "HTML" -value "text/html" -variable Config(content-type) -command {Configure "content-type" "text/html"}] -side left
		pack [entry .main.left.cfg.contenttype_e.value -textvariable Config(content-type) -vcmd {Configure "content-type" %P; expr 1} -validate focusout] -side left
		pack [label .main.left.cfg.contenttype_e.txt -text "Custom"] -side left

	# Zip threshold
	grid [label .main.left.cfg.zip_l -text "Zip threshold (# chars)"] -row [incr Row] -column 0 -sticky w
	grid [frame .main.left.cfg.zip_e] -row $Row -column 1 -sticky w
		pack [radiobutton .main.left.cfg.zip_e.never -text "Never zip" -value "0" -variable Config(zip_threshold) -command {Configure "zip_threshold" 0}] -side left
		pack [radiobutton .main.left.cfg.zip_e.o100 -text "100" -value "100" -variable Config(zip_threshold) -command {Configure "zip_threshold" 100}] -side left
		pack [radiobutton .main.left.cfg.zip_e.o1000 -text "1000" -value "1000" -variable Config(zip_threshold) -command {Configure "zip_threshold" 1000}] -side left
		pack [radiobutton .main.left.cfg.zip_e.always -text "Always" -value "1" -variable Config(zip_threshold) -command {Configure "zip_threshold" 1}] -side left

# Log/error window pane
	panedwindow .main.left.logerr -orient vertical -sashpad 2 -sashwidth 4 -handlesize 8 -showhandle 1 -sashrelief sunken
		grid .main.left.logerr -row 1 -column 0 -columnspan 2 -sticky news -padx 2 -pady 2m
	frame .main.left.logerr.log
	frame .main.left.logerr.err
	.main.left.logerr add .main.left.logerr.log .main.left.logerr.err
		.main.left.logerr paneconfigure .main.left.logerr.log -stretch always

# Log
	pack [label .main.left.logerr.log.l -text "Log"]
	set LogW [ScrollText .main.left.logerr.log.e -width 50 -height 20]
		pack .main.left.logerr.log.e -expand yes -fill both
	$LogW tag configure info -foreground black
	$LogW tag configure input -foreground blue -lmargin1 10
	$LogW tag configure output -foreground green3 -lmargin1 10

# Error info
	pack [label .main.left.logerr.err.l -text "Error info"]
	set ErrorW [ScrollText .main.left.logerr.err.e -width 50 -height 8]
		pack .main.left.logerr.err.e -expand yes -fill both
	
	proc DisplayError {args} {
		.main.left.logerr.err.e.text delete 0.0 end
		.main.left.logerr.err.e.text insert end $::errorInfo
	}
	
# Custom window
	pack [label .main.right.l -text "User and session information"]
	set DemoW [ScrollText .main.right.e -width 40]
		pack .main.right.e -expand yes -fill both
	PrintReadme
	PrintResponderPluginDefinitions

# Menu
	menu .menu
		.menu add cascade -label File -menu .menu.file
			menu .menu.file -tearoff 0
				.menu.file add command -label "Exit" -command exit
	. configure -menu .menu

	.menu add command -label "Open console" \
		-command OpenConsole
	.menu add command -label "Clear log" \
		-command "$::LogW delete 0.0 end; .main.left.logerr.err.e.text delete 0.0 end"
	.menu add command -label "Open web browser" \
		-command OpenBrowser

# Start the server using a free port
	for {set Port 8080} {$Port<8100} {incr Port} {
		if {![catch {Configure "port" $Port 1}]} {
			set Config(port) $Port
			break
		}
	}

# Display errors
	trace add variable ::errorInfo write DisplayError
