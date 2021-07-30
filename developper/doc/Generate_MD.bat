::::::::::::::::::::::::::::::::::
:: Generate MarkDown Documentation
::::::::::::::::::::::::::::::::::
::
:: Specify the destination directory and documentation file definitions inside
:: the file _nd2md.settings:
::
::   set nd2md_DestDir <MD_DestinationDirectory>
::   array set nd2md_nd2md {
::     <TclFile1> <MdFile1>
::     <TclFile2> <MdFile2>
::     ... ...
::   }
::
:: Example:
::
::   set nd2md_DestDir "../../../thc.wiki"
::   array set nd2md_nd2md {
::     ../../bin/thc.tcl {THC-Core-functions.md}
::   }
::
::::::::::::::::::::::::::::::::::

:: General documentation
tclsh nd2md\nd2md.tcl -config deflist_mapping=list ^
   "Introduction.txt"
copy ..\..\..\t2ws.wiki\Introduction.md ..\..\README.md

:: Core function documentation
tclsh nd2md\nd2md.tcl ^
   ../../t2ws.tcl ^
   ../../t2ws_template.tcl ^
   ../../t2ws_bauth.tcl
::   ../../t2ws_session.tcl

:: Generate the index file
tclsh nd2md\nd2md.tcl -x

:: Copy the used images to the destination
::copy thc_Web.gif ..\..\..\thc.wiki