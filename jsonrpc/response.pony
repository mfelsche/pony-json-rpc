use "json"

class Response  
  let method : String
  let params : JsonType
  let id : RequestIDType
  let err : (Error | None)

  new create(method': String, params': JsonType, id': RequestIDType, err' : (Error | None)) =>
    method = method'
    params = params'
    id = id'
    err = err'
