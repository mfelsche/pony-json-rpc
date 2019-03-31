use "immutable-json"
use "collections"

class val Response
  let result : JsonType val
  let id : RequestIDType
  let err : (Error val | None)

  new val from_error(id': RequestIDType, err': Error val) =>
    id = id'
    result = None
    err = err'

  new val success(id': RequestIDType, result': JsonType val) =>
    id = id'
    result = result'
    err = None

  fun box to_json(): String =>
    let doc: JsonDoc = JsonDoc

    var dmap: Map[String, JsonType] trn = recover Map[String, JsonType] end
    dmap("jsonrpc") = Protocol.version()
    dmap("id") = id

    match err
    | let e: Error val => dmap("error") = e.to_jsonobject()
    else
      if result isnt None then
        dmap("result") = result
      end
    end

    let obj: JsonObject = JsonObject(consume dmap)
    doc.data = obj
    doc.string()


