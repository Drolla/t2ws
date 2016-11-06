T2WS documentation example, introduction 1

T2WS demo that demonstrates the first example provided in the T2WS introduction 
that is based on a single responder command 'MyResponder'. This responder 
command accepts the following requests:

* Tcl command evaluation: /eval/<TclCommand>
   http://localhost:8080/eval/glob *
   -> Demo_Server.tcl Readme.txt
* File request: /file/<FileName>
   http://localhost:8080/file/Readme.txt
   -> <content of Readme.txt>
All other requests are responded with a 404 failure status:
   http://localhost:8080/exec/cmd.exe
   -> 404 Not Found
