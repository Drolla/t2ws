T2WS basic authentication plugin example 1

This example implements a Tcl debug server to demonstrates the basic 
authentication plugin. Some of the requests can be called without authentication, 
the other commands require an authentication.

Public requests:
  Syntax: //<Host>[:<Port>]]/<Command>
  Commands:
    * help: Shows Readme.txt
Private requests:
  Syntax: //<Host>[:<Port>]]/prv/<Command> -> The browser will ask for the credentials
      or: //<User>:<Password>@<Host>[:<Port>]]/prv/<Command>
    Remark: Once the user credentials have been defined most web browsers add 
            them automatically to the the subsequent requests.
  Commands:
    * eval <TclCommand>: Evaluate a Tcl command and returns the result
    * file/show <File>: Get file content
    * download <File>: Get file content (force download in a browser)}
Examples:
  * http://localhost:8080/Help
  * http://localhost:8080/prv/eval/info vars
  * http://localhost:8080/prv/show/Readme.txt
