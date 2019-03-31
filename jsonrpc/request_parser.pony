use "immutable-json"

primitive InvalidJson
primitive InvalidRequest

type ParseError is (InvalidJson | InvalidRequest )
type ParseResult is (BatchRequest | Request | ParseError)

primitive RequestParser

  fun tag _parse_batch_request(arr: JsonArray): BatchRequest =>
    let s = arr.data.size()
    let results = recover trn Array[(Request | ParseError)](s) end
    for elem in arr.data.values() do
      results.push(
        match elem
        | let obj: JsonObject => _parse_single_request(obj)
        else
          InvalidRequest
        end
      )
    end
    BatchRequest(consume results)

  fun tag _parse_single_request(obj: JsonObject): (Request | ParseError) =>
    // verify "jsonrpc": "2.0"
    try
      let protocol = obj.data("jsonrpc")? as String
      if protocol != Protocol.version() then
        return InvalidRequest
      end
    else
      return InvalidRequest
    end

    let method =
      try
        obj.data("method")? as String
      else
        return InvalidRequest
      end

    let request_id: RequestIDType =
      if obj.data.contains("id") then
        try
          match obj.data("id")?
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
        match obj.data("params")?
        | let arr: JsonArray => arr
        | let params_obj: JsonObject => params_obj
        else
          return InvalidRequest
        end
      end

    Request(method, params, request_id)

  fun tag parse_request(json: String): ParseResult =>
    let doc: JsonDoc = JsonDoc
    try
      doc.parse(json)?
    else
      return InvalidJson
    end

    match doc.data
    | let obj: JsonObject =>
      _parse_single_request(obj)
    | let arr: JsonArray if arr.data.size() > 0 =>
      _parse_batch_request(arr)
    else
      InvalidRequest
    end
