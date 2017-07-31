use "json"

primitive ErrorCodes
  fun parse(): I64 => -32700
  fun invalid_request(): I64 => -32600
  fun method_not_found(): I64 => -32601
  fun invalid_params(): I64 => -32602
  fun internal_error(): I64 => -32603
  fun server_error(): I64 => -32000 // range -32000 to -32099

class Error
  let code: I64 
  let message: String
  let data: JsonType 

  new create(code': I64, message': String, data': JsonType) =>
    code = code'
    message = message'
    data = data'


class JSONRPCResponse  
  let method : String
  let params : JsonType
  let id : RequestIDType
  let err : (Error | None)

  new create(method': String, params': JsonType, id': RequestIDType, err' : (Error | None)) =>
    method = method'
    params = params'
    id = id'
    err = err'

  