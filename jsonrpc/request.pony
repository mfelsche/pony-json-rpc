use "json"

type RequestIDType is (String | I64 | None)

class val Request  
  let method : String
  let params : JsonType val
  let id : RequestIDType

  new val create(method': String, params': JsonType val, id': RequestIDType) =>
    method = method'
    params = params'
    id = id'

  fun is_notification() =>
    id is None 