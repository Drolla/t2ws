T2WS template example 1

T2WS template example that demonstrates how the template engine is invoked by 
calling the template processor 't2ws::template::ProcessTemplateFile' explicitly
from the responder command.

   dict create Body [t2ws::template::ProcessTemplateFile $File] Content-Type .html

The HTML template file ('Main.htmt') contains multiple Tcl sections that are 
substituted by the template engine. Section 1:

   %catch {
      <p>Host: [dict get $Request Header host]</p>
      <p>User-Agent: [dict get $Request Header user-agent]</p>
   %}

Section 2:
   
   %foreach {Title NS Variables} {
   %   "T2WS namespace" "::t2ws" {Responder Config Server}
   %   "Global namespace" "" {tcl_version auto_path auto_index tcl_platform env}
   % } {
      <h2>$Title:</h2>
      ...
      <table class="t_table"><tbody>
   %foreach n $Variables {
   %   if {[array exists ${NS}::${n}]} {
   %      foreach i [array names ${NS}::${n}] {
   %         set v [t2ws::HtmlEncode [set ${NS}::${n}($i)]]
   %         set nn [t2ws::HtmlEncode ${n}($i)]
               <tr><td>$nn</td><td>$v</td></tr>
   %      }
   %   } else {
   %      set v [set ${NS}::${n}]
   %      set nn [t2ws::HtmlEncode $n]
             <tr><td>$nn</td><td>$v</td></tr>
   %   }
   %}
      </tbody></table>
   %}

Section 3:

   T<sup>2</sup>WS Demo [clock format [clock seconds]]
