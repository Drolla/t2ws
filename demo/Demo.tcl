##########################################################################
# T2WS - Tiny Tcl Web Server
##########################################################################
# Demo.tcl
# 
# Utility to launch the T2WS demo examples
#
# Copyright (C) 2016 Andreas Drollinger
##########################################################################
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
##########################################################################

# Ensure the current directory is set to the one of this script

	set Wd [file normalize [file dirname [info script]]]
	cd $Wd

# RunDemo will launch as independent process a selected demo example. The same
# executable as used by this demo selection utility is used.

	proc RunDemo {DemoDir} {
		cd $DemoDir
		catch {exec -- [info nameofexecutable] Demo_Server.tcl &}
		cd $::Wd
	}

# GUI

	package require Tk

	pack [label .l0 -text "Select a demo:"] -expand yes -fill x

	foreach DemoDir [lsort [glob -types d "Demo*"]] {
		if {[file exists $DemoDir/Demo_Server.tcl]} {
			pack [button .b$DemoDir -text [regsub {^Demo\w*\s*} $DemoDir {}] -command [list RunDemo $DemoDir]] -expand yes -fill x
			bind .b$DemoDir <Enter> [list ShowDemoReadme $DemoDir]
			bind .b$DemoDir <Leave> HideDemoReadme
		}
	}

	pack [label .l1] -expand yes -fill x
	pack [button .bExit -text Exit -command exit] -expand yes -fill x

	wm geometry . +0+0

# Readme toplevel window

	# Implementation of a scrollable text (mega) widget. The path of the used text 
	# widget is returned.

	update
	toplevel .readme -bd 2
	wm withdraw .readme
	wm overrideredirect .readme 1
	wm geometry .readme +[expr [winfo rootx .]+[winfo reqwidth .]+5]+[winfo rooty .]
	set ReadmeW [text .readme.text -wrap none -width 90 -height 20]
	pack $ReadmeW


# Balloon window providing demo details

	proc ShowDemoReadme {DemoDir} {
		if {[catch {
			set f [open $DemoDir/Readme.txt r]
			$::ReadmeW delete 0.0 end
			$::ReadmeW insert end [string trimright [read $f] " \t\n"]
			close $f

			set NbrLines [expr int([$::ReadmeW index end])-1]
			$::ReadmeW configure -height [expr {$NbrLines<10 ? 10 : $NbrLines}]

			wm deiconify .readme
		}]} {
			wm withdraw .readme
		}
	}

	proc HideDemoReadme {} {
		wm withdraw .readme 
	}
