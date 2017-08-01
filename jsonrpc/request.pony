use "json"

type RequestIDType is (String | I64 | None)

class val Request  
  let method : String
  let params : JsonType
  let id : RequestIDType

  new val create(method': String, params': JsonType, id': RequestIDType) =>
    method = method'
    params = params'
    id = id'

  fun is_notification() =>
    id is None 