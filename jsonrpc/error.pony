use "immutable-json"
use "collections"

primitive ErrorCodes
  fun parse(): I64 => -32700
  fun invalid_request(): I64 => -32600
  fun method_not_found(): I64 => -32601
  fun invalid_params(): I64 => -32602
  fun internal_error(): I64 => -32603
  fun server_error(): I64 => -32000 // range -32000 to -32099

class val Error
  let code: I64
  let message: String
  let data: JsonType

  new val create(code': I64, message': String, data': JsonType) =>
    code = code'
    message = message'
    data = data'

  new val method_not_found(method: ( String | None ) = None) =>
    code = ErrorCodes.method_not_found()
    message = "Method not found"
    data = method

  new val parse_error() =>
    code = ErrorCodes.parse()
    message = "Parse Error"
    data = None

  new val invalid_request() =>
    code = ErrorCodes.invalid_request()
    message = "Invalid Request"
    data = None

  new val invalid_params() =>
    code = ErrorCodes.invalid_params()
    message = "Invalid params"
    data = None

  new val internal_error() =>
    code = ErrorCodes.internal_error()
    message = "Inernal error"
    data = None

  fun to_jsonobject(): JsonObject =>
    let json_obj = recover trn Map[String, JsonType] end
    json_obj("code") = code
    json_obj("message") = message
    if data isnt None then
      json_obj("data") = data
    end
    JsonObject(consume json_obj)
