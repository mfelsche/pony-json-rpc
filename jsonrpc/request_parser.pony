use "json"

primitive InvalidJson
primitive InvalidRequest

type ParseError is (InvalidJson | InvalidRequest )
type ParseResult is (Request val | ParseError)

primitive RequestParser

  fun tag parse_request(json: String): ParseResult =>
    let doc: JsonDoc val =
      try
        recover
          let tmp = JsonDoc
          tmp.parse(json)?
          consume tmp
        end
      else
        return InvalidJson
      end

    let root =
      try
        doc.data as JsonObject val
      else
        return InvalidRequest
      end
    // verify "jsonrpc": "2.0"
    try
      let protocol = root.data("jsonrpc")? as String
      if protocol != Protocol.version() then
        return InvalidRequest
      end
    else
      return InvalidRequest
    end

    let method =
      try
        root.data("method")? as String
      else
        return InvalidRequest
      end

    let request_id: RequestIDType =
      if root.data.contains("id") then
        try
          match root.data("id")?
          | let i: I64 => i
          | let s: String => s
          | None => None
          else
            return InvalidRequest
          end
        else
          return InvalidRequest
        end
      else
        // assume Notification
        None
      end

    // If present, parameters for the rpc call MUST be provided as a Structured
    // value. Either by-position through an Array or by-name through an Object.
    let params =
      try
        match root.data("params")?
        | let arr: JsonArray val => arr
        | let obj: JsonObject val => obj
        else
          return InvalidRequest
        end
      end

    Request(method, params, request_id)
