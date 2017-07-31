use "json"

primitive RequestParser
  fun tag parse_request(json: String): Request ? =>
    let doc: JsonDoc = JsonDoc
    doc.parse(json)?

    let root = doc.data as JsonObject
    let method = root.data("method")? as String
    let request_id: RequestIDType =
      if root.data.contains("id") then
        let id = root.data("id")? as JsonType
        match id
        | let i: I64 => i 
        | let s: String => s
        else
          None
        end
      else
        None 
      end 

    let params = 
      if root.data.contains("params") then
        root.data("params")? 
      else
        None
      end 

    Request(method, params, request_id)
