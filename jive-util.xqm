module namespace jive = 'http://seu.jive.com';

declare function jive:request-template($username as xs:string, $password as xs:string) as node() {
  <http:request username="{$username}" password="{$password}" send-authorization="true" override-media-type="text/plain" method="get" />
};

declare function jive:to-map($input as node(), $unescape as xs:string*) as item() {
  map:merge(
    for $prop in $input/*/name() 
    let $value :=
     if($prop = $unescape) then jive:unescape($input/*[name() = $prop]/text())
     else $input/*[name() = $prop]/text()
    return
      map { $prop: $value }
  )
};

declare function jive:unescape($input as xs:string) as xs:string {
  (fn:replace($input, '\&lt;', '<')) => fn:replace('\&gt;', '>')
};

declare function jive:prep($request-template as node(), $item as item(), $baseUri as xs:string) as item() {
  let $self := $item?resources?self?ref return
  map:merge((
    for $key in map:keys($item)
    where not($key = ('resources')) return
      map { $key : $item($key)},
    let $resources := $item?resources      
    for $key in map:keys($resources) return
      let $value := $resources($key)?ref return
      if(starts-with($value, $self) and not($key = 'self')) then (
        let $relItems := jive:get-item($request-template, $baseUri || $value) return
          map { $key : array { 
              $relItems?list?*?resources?self?ref
          }}
      ) else (
        map { $key : $item?resources($key)?ref }
      )
  ))
};

declare function jive:modify-request-template($request-template as node(), $method as xs:string, $bodies as item()*) as node() {
   if($request-template/@method = $method) then ($request-template)
   else (
       copy $request-template-copy := $request-template
       modify (replace value of node $request-template-copy/@method with $method,
       insert nodes $bodies into $request-template-copy)
       return $request-template-copy)
};

declare function jive:modify-request-template($request-template as node(), $method as xs:string) as node() {
  jive:modify-request-template($request-template, $method, <http:body media-type="text/plain"></http:body>)
};

declare function jive:process-response($responseBody as xs:string?) as item()? {
  try {
    parse-json(fn:replace($responseBody, "throw.*;\s*", ""))
  } catch * {
    $responseBody
  }
};

declare function jive:get-item($request-template as node(), $uri as xs:string?) as item()? {
  if($uri) then 
    let $request := jive:modify-request-template($request-template, 'GET') return
    let $response := http:send-request($request, $uri)[2]
    return
      jive:process-response($response)

  else ()
};

declare function jive:update-item($request-template as node(), $item as item()) as item() {
  jive:update-item($request-template, $item, false())
};

declare function jive:update-item($request-template as node(), $item as item(), $minor as xs:boolean) as item() { 
  let $uri := ($item?resources?self?ref, $item?self)[1] || (if($minor) then '?minor=true' else '')
  let $body :=
   <http:body media-type="application/json" method="text">
      {json:serialize($item)}
  </http:body>
    return
    (jive:modify-request-template($request-template, 'PUT', $body) 
      => http:send-request($uri))[2] 
      => jive:process-response()
};

declare function jive:delete-item($request-template as node(), $item as item()) as item() {
  let $uri := ($item?resources?self?ref, $item?self)[1] return
   http:send-request(
       copy $req := $request-template
       modify (delete node $req/body, replace value of node $req/@method with 'DELETE')
       return $req, $uri
   )[1]     
};

declare function jive:get-all-items($request-template as node(), $baseURI as xs:string) {
  let $response := 
    jive:process-response(
      http:send-request(
        jive:modify-request-template($request-template, 'GET'), $baseURI)[2])
  return array:join(($response?list, if($response?links?next) then (jive:get-all-items($request-template, $response?links?next)) else ()))    
};

declare function jive:create-item($request-template as node(), $urlIn as xs:string, $item as item()*) as item()* {
  jive:process-response(
    http:send-request(
      jive:modify-request-template($request-template, 'POST',
    ($item !
      (if(. instance of element() and ./local-name() = 'body') then . else 
        <http:body media-type="application/json" method="text">{json:serialize(.)}</http:body>
      ))
  ), $urlIn)[2])
};

declare function jive:invite-to-group($request-template as node(), $emailsIn as xs:string*, $groupIn as node()) as node() {
  let $invite := 
    <json objects="json" arrays="invitees">
      <body>Please come join the group</body>
      <invitees>
        {for $email in $emailsIn return <value>{$email}</value>}
      </invitees>
    </json>
  return jive:create-item($request-template, $groupIn/resources/invites/ref,  <http:body media-type="application/json">{json:serialize($invite)}</http:body>)
};
