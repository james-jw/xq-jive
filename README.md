# jive
Jive management services and xquery utility modules for working with jives v3 APIs.

# jive-util.xqm
Namespace: module namespace jive = 'http://seu.jive.com';

<h3>methods</h3>
<table>
  <thead>
    <tr><td>Name</td><td>Description</td></tr>
  </thead>
  <tbody>
      <tr><td>request-template</td><td>function jive:request-template($username as xs:string, $password as xs:string) as node()</td></tr>
      <tr><td>get-item</td><td>jive:get-item($request-template as node(), $uri as xs:string?) as item()?</td></tr>
      <tr><td>get-all-items</td><td>jive:get-all-items($request-template as node(), $baseURI as xs:string) as array(*)</td></tr>
      <tr><td>delete-item</td><td>jive:delete-item($request-template as node(), $item as item()) as item()</td></tr>
      <tr><td>update-item</td><td>
      jive:update-item($request-template as node(), $item as item()) as item()<br />
      jive:update-item($request-template as node(), $item as item(), $minor as xs:boolean) as item()
      </td></tr>
      <tr><td>create-item</td><td>jive:create-item($request-template as node(), $urlIn as xs:string, $item as item()*) as item()*</td></tr>
  </tbody>
</table>

<h3>Examples</h3>

<pre>
import module namespace jive = 'http://seu.jive.com' at 'https://raw.githubusercontent.com/james-jw/jive/master/jive-util.xqm';

let $req := jive:request-template('myUser', 'myPass') 
let $people := jive:get-all-items($req, 'http://myService/api/core/v3/people') 
  return
    for $person in $people?*
    where matches($person?emails?values, 'someDomain.com') 
    return
      jive:delete-item($req, $person)
</pre>

<pre>
import module namespace jive = 'http://seu.jive.com' at 'https://raw.githubusercontent.com/james-jw/jive/master/jive-util.xqm';

let $req := jive:request-template('myUser', 'myPass') 
let $member := map {
  'person': 'http://myService/api/core/v3/people/2',
  'state': 'member'
  }
  
let $groups := jive:get-all-items($req, 'http://myService/api/core/v3/place?filter=tag(someTag)')
return
  for $group in $groups?*
  let $membership:= jive:create-item($req, $group?resources?members?ref, $member) 
  return
    $membership
</pre>
