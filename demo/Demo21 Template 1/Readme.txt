T2WS template example 1

T2WS template example that demonstrates how the template engine is invoked by 
setting the 'IsTemplate' header response field to 1:

   dict create File $File IsTemplate 1 Content-Type .html

The HTML template file ('Main.htmt') contains multiple Tcl sections that are 
substituted by the template engine. First section:

   %catch {
      <p>Host: [dict get $Request Header host]</p>
      <p>User-Agent: [dict get $Request Header user-agent]</p>
   %}

Second section:
	
   <table><tbody>
   %foreach {Name Value} [array get tcl_platform] {
      <tr><td>$Name</td><td>$Value</td></tr>
   %}
   </tbody></table>

Third section:

   <div id="footer">T<sup>2</sup>WS Demo [clock format [clock seconds]]</div>
