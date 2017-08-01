use "json"
use "collections"

class Response  
  let method : String
  let result : JsonType
  let id : RequestIDType
  let err : (Error | None)

  new create(method': String, result': JsonType, id': RequestIDType, err' : (Error | None)) =>
    method = method'
    result = result'
    id = id'
    err = err'

  fun ref to_json(): String =>
    let doc:JsonDoc = JsonDoc
    
    var dmap: Map[String, JsonType] = Map[String, JsonType]
    dmap("jsonrpc") = "2.0"
    
    match err
    | let e: Error => dmap("error") = e.to_jsonobject()
    else    
      if id isnt None then
        dmap("id") = id
      end
      if result isnt None then        
        dmap("result") = result
      end 
    end 
    
    let obj:JsonObject = JsonObject.from_map(dmap)
    doc.data = obj
    doc.string("", false)


