T2WS template demo - File browser

T2WS template example that demonstrates how a file browser can be implemented
using the T2WS template system. The code to parse the directory structure and 
to display the list of the local files is directly embedded into the main HTML
file 'Main.htmt'.

   <h2>Directory listing for $FullDir</h2>
   <hr></hr>
   <ul>
      <li class="li_folder"><a href="/$RelParentDir">..</a></li>
   %  foreach DirItem [glob -directory $FullDir -tails -nocomplain *] {
   %     if {[file isdirectory $FullDir/$DirItem]} {
            <li class="li_folder"><a href="$TailDir/$DirItem">$DirItem</a></li>
   %     } else {
            <li class="li_file"><a href="$TailDir/$DirItem">$DirItem</a></li>
   %     }
   %   }
   </ul>
