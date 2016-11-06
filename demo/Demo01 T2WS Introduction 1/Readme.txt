T2WS documentation example, introduction 1

T2WS demo that demonstrates the second example provided in the T2WS introduction 
that is based on the following two responder commands:

* MyResponder_Eval (Tcl command evaluation): /eval/<TclCommand>
   http://localhost:8080/eval/glob *
   -> Demo_Server.tcl Readme.txt
* MyResponder_File (File request): /file/<FileName>
   http://localhost:8080/file/Readme.txt
   -> <content of Readme.txt>
All other requests are responded with a default 404 failure status:
   http://localhost:8080/exec/cmd.exe
   -> 404 Not Found
