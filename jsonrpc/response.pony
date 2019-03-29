use "json"
use "collections"

class Response
  let result : JsonType
  let id : RequestIDType
  let err : (Error val | None)

  new error(id': RequestIdType. err': Error val) =>
    id = id'
    result = None
    err = err'

  new success(id': RequestIDType, result': JsonType val) =>
    id = id'
    result = result'
    err = None

  fun ref to_json(): String =>
    let doc:JsonDoc = JsonDoc

    var dmap: Map[String, JsonType] = Map[String, JsonType]
    dmap("jsonrpc") = Protocol.version()
    dmap("id") = id

    match err
    | let e: Error val => dmap("error") = e.to_jsonobject()
    else
      if result isnt None then
        dmap("result") = result
      end
    end

    let obj: JsonObject = JsonObject.from_map(dmap)
    doc.data = obj
    doc.string()


