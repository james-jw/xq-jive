# jive
Jive management services and xquery utility modules for working with jives v3 APIs.

### Installation
Use [xqpm][0] to install this for you. 
<code>basex xq-jive</code> 

Otherwise, simply clone this repo to your local machine and reference the <code>xq-jive.xqm</code> module in your code.

### Methods
Every methods first paramter is request template. Call the following function to create one passing in your Jive username and password.
``jive:request-template($username as xs:string, $password as xs:string) as node()``

To retrieve a single item call:
``jive:get-item($request-template as node(), $uri as xs:string?) as item()?``

If a list of items is required, use <code>get-all-items</code> to recieve an array of results. Note that the method will return all results, not just the first pages worth.
``jive:get-all-items($request-template as node(), $baseURI as xs:string) as array(*)``

The following methods are rather self explanatory. 
``jive:update-item($request-template as node(), $item as item()) as item()``
``jive:update-item($request-template as node(), $item as item(), $minor as xs:boolean) as item()``
``jive:create-item($request-template as node(), $urlIn as xs:string, $item as item()*) as item()``
``jive:delete-item($request-template as node(), $item as item()) as item()``

### Examples

```xquery
import module namespace jive = 'http://seu.jive.com' at 'https://raw.githubusercontent.com/james-jw/jive/master/jive-util.xqm';

let $req := jive:request-template('myUser', 'myPass') 
let $people := jive:get-all-items($req, 'http://myService/api/core/v3/people') 
  return
    for $person in $people?*
    where matches($person?emails?*?value, 'someDomain.com') 
    return
      jive:delete-item($req, $person)
```

```xquery
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
```

[http://www.github.com/james-jw/xqpm][0]
