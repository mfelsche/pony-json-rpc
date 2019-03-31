use "immutable-json"
use "collections"

type RequestIDType is (String | I64 | None)
type RequestParamsType is ( JsonArray | JsonObject | None)

class val Request
  let method : String
  let params : RequestParamsType
  let id : RequestIDType

  new val create(method': String, params': RequestParamsType, id': RequestIDType) =>
    method = method'
    params = params'
    id = id'

  fun is_notification(): Bool =>
    id is None

  fun box to_json(): String =>
    let doc: JsonDoc = JsonDoc

    var dmap: Map[String, JsonType] trn = recover Map[String, JsonType] end
    dmap("jsonrpc") = Protocol.version()

    // id SHOULD NOT be Null
    if id isnt None then
      dmap("id") = id
    end
    dmap("method") = method
    dmap("params") = params

    let obj: JsonObject = JsonObject(consume dmap)
    doc.data = obj
    doc.string()

