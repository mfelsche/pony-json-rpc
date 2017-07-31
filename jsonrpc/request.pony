use "json"

type RequestIDType is (String | I64 | None)

class JSONRPCRequest
  let jsonrpc : String = "2.0"
  let method : String
  let params : JsonType
  let id : RequestIDType

  new create(method': String, params': JsonType, id': RequestIDType) =>
    method = method'
    params = params'
    id = id'

  fun is_notification() =>
    id is None 