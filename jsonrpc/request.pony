use "json"
use "collections"

type RequestIDType is (String | I64 | None)
type RequestParamsType is ( JsonArray val | JsonObject val | None)

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
    let doc:JsonDoc = JsonDoc

    var dmap: Map[String, JsonType] = Map[String, JsonType]
    dmap("jsonrpc") = Protocol.version()
    // id SHOULD NOT be Null
    if id isnt None then
      dmap("id") = id
    end
    dmap("method") = method
    match params
    | let arr: JsonArray val =>
      dmap("params") = JsonCopy(arr)
    | let obj: JsonObject val =>
      dmap("params") = JsonCopy(obj)
    end

    let obj: JsonObject = JsonObject.from_map(dmap)
    doc.data = obj
    doc.string()

primitive JsonCopy

  fun apply(imm: JsonType val): JsonType =>
    match imm
    | let arr: JsonArray val => _arr(arr)
    | let obj: JsonObject val => _obj(obj)
    | let f: F64 => f
    | let i: I64 => i
    | let b: Bool => b
    | let s: String => s
    | None => None
    end

  fun tag _arr(imm: JsonArray val): JsonArray =>
    let tmp = JsonArray(imm.data.size())
    for imm_elem in imm.data.values() do
      tmp.data.push(
        match imm_elem
        | let arr_elem: JsonArray val  => _arr(arr_elem)
        | let obj_elem: JsonObject val => _obj(obj_elem)
        | let f: F64 => f
        | let i: I64 => i
        | let b: Bool => b
        | let s: String => s
        | None => None
        end)
    end
    tmp

  fun tag _obj(imm: JsonObject val): JsonObject =>
    let tmp = JsonObject(imm.data.size())
    for kv in imm.data.pairs() do
      tmp.data(kv._1) =
        match kv._2
        | let arr_value: JsonArray val  => _arr(arr_value)
        | let obj_value: JsonObject val => _obj(obj_value)
        | let f: F64 => f
        | let i: I64 => i
        | let b: Bool => b
        | let s: String => s
        | None => None
        end
    end
    tmp
