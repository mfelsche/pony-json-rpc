use "json"

primitive JSONRPCRequestParser
  fun tag parse_request(json: String): JSONRPCRequest ? =>
    let doc: JsonDoc = JsonDoc
    doc.parse(json)?

    let root = doc.data as JsonObject
    let method = root.data("method")? as String
    let id = root.data("id")? as JsonType
    let request_id: RequestIDType = match id
    | let i: I64 => i 
    | let s: String => s
    else
      None
    end 

    let params = root.data("params")? 

    JSONRPCRequest(method, params, request_id)
