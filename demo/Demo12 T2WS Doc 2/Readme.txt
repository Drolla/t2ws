T2WS documentation example, introduction 3

T2WS demo that demonstrates an example provided in the T2WS documentation
that is based on the following three responder commands:

* Responder_GetApi (Tcl command evaluation): /api/<TclCommand>
   http://localhost:8080/api/glob *
   -> Demo_Server.tcl Readme.txt
* MyResponder_File (File request): /file/<FileName>
   http://localhost:8080/file/Readme.txt
   -> <content of Readme.txt>
* Responder_General (handles all other requests and returns 404):
   http://localhost:8080
   -> 404 Not Found
   http://localhost:8080/
   -> 404 Not Found
   http://localhost:8080/hello worlds
   -> 404 Not Found
   http://localhost:8080/api
   -> 404 Not Found
