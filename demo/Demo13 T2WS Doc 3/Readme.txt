T2WS documentation example, introduction 1

T2WS demo that demonstrates an example provided in the T2WS documentation
that is based on a single responder command 'MyResponder'. This responder 
command accepts the following requests:

* Help: /help or no specific request
   http://localhost:8080
   -> <Help text>
   http://localhost:8080/help
   -> <Help text>
* Tcl command evaluation: /eval/<TclCommand>
   http://localhost:8080/eval/glob *
   -> Demo_Server.tcl Readme.txt
* File request: /file/<FileName>
   http://localhost:8080/file/Readme.txt
   -> <content of Readme.txt>
* File download: /download/<FileName>
   http://localhost:8080/download/Readme.txt
   -> <download of Readme.txt is starting>
All other requests are responded with a 404 failure status:
   http://localhost:8080/exec/cmd.exe
   -> 404 - Unknown command: cmd.exe. Call 'help' for support.
