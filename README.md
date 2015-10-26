# jive
Jive management services and xquery utility modules for working with jives v3 APIs.

 * [Installation](#installation)
 * [Methods](#methods)
 * [Examples](#examples)
   * [Delete users by email domain](#delete-users-by-email-domain)
   * [Push user to group](#push-user-to-group)
 * [Shout Out!](#shout-out)

## Installation
Use [xqpm][0] to install this for you. 
<code>basex xq-jive</code> 

Otherwise, simply clone this repo to your local machine and reference the <code>xq-jive.xqm</code> module in your code.

## Methods
Call the following function to create a request template used by the other methods. Simply pass in your Jive username and password.
```xquery
jive:request-template($username as xs:string, $password as xs:string) as node()
```

Then, to retrieve a single item call:
```xquery
jive:get-item($request-template as node(), $uri as xs:string?) as item()?
```

If requesting a pageable list of items, use <code>get-all-items</code> to recieve the full list as an array of results. Note that this method will return all results, not just the first page worth.
```xquery
jive:get-all-items($request-template as node(), $baseURI as xs:string) as array(*)
```

The following methods are rather self explanatory. 
```xquery
jive:update-item($request-template as node(), $item as item()) as item()
```

For minor updates, includes <code>true()</code> for the <code>$minor</code> argument.
```xquery
jive:update-item($request-template as node(), $item as item(), $minor as xs:boolean) as item()
```

```xquery
jive:create-item($request-template as node(), $urlIn as xs:string, $item as item()*) as item()
```
```xquery
jive:delete-item($request-template as node(), $item as item()) as item()
```

## Examples

### Delete users by email domain
This example will query all users and then find those with a particular
domain and delete them

```xquery
import module namespace jive;

let $req := jive:request-template('myUser', 'myPass') 
let $people := jive:get-all-items($req, 'http://myService/api/core/v3/people') 
  return
    for $person in $people?*
    where matches($person?emails?*?value, 'someDomain.com') 
    return
      jive:delete-item($req, $person)
```

### Push user to group
The following example will add a user to a group.
```xquery
import module namespace jive = 'http://seu.jive.com';

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
## Shout Out!
If you like what you see here star the repo and or find me on github or linkedIn

[0]: http://www.github.com/james-jw/xqpm
