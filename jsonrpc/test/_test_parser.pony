use "ponytest"
use "collections"
use "immutable-json"

use ".."

primitive ParserTests is TestList
  fun tag tests(test: PonyTest) =>
    test(_TestBadMethod)
    test(_TestParseBadJSON)
    test(_TestParseRequestNoId)
    test(_TestParseRequestNoParams)
    test(_TestParseRequestArrayParams)
    test(_TestParseRequestObjectParams)
    test(_TestParseRequestBadParams)
    test(_TestParseRequestBatch)
    test(_TestParseRequestBatchInvalidJson)
    test(_TestParseRequestBatchEmpty)
    test(_TestParseRequestBatchInvalid)
    test(_TestParseRequestBatchSomeInvalid)

class iso _TestBadMethod is UnitTest
  """
  Tests that the request parser fails properly when we don't pass
  a valid method
  """
  fun name(): String => "JSONRPC/parserequest/badmethod"

  fun apply(h: TestHelper) =>
    let src =
      """
      {"jsonrpc": "2.0", "method": 1, "params": "bar"}
      """
    h.assert_is[ParseResult](
      InvalidRequest,
      RequestParser.parse_request(src))

class iso _TestParseBadJSON is UnitTest
  """
  Tests that the request parser fails when we give it a JSON payload
  that cannot be converted into a proper request
  """
  fun name(): String => "JSONRPC/parserequest/badjson"

  fun apply(h: TestHelper) =>
    let src =
      """
      {'this won't parse:"boo"}}
      """
    h.assert_is[ParseResult](
      InvalidJson,
      RequestParser.parse_request(src))

class iso _TestParseRequestNoId is UnitTest
  """
  Test basic parsing of a JSON-RPC 2.0 request. Test assures that the parser primitive can deal with no ID (aka a 'notification')
  """
  fun name(): String => "JSONRPC/parserequest/noid"

  fun apply(h: TestHelper) ? =>
    let src =
      """
      {"jsonrpc": "2.0", "method": "foobar", "params": [42, 23]}
      """
    let request = RequestParser.parse_request(src) as Request val
    h.assert_true(request.is_notification())
    h.assert_eq[String]("foobar", request.method)
    let array = request.params as JsonArray
    h.assert_eq[USize](2, array.data.size())
    h.assert_eq[I64](42, array.data(0)? as I64)
    h.assert_eq[I64](23, array.data(1)? as I64)
    h.assert_is[RequestIDType](None, request.id)

class iso _TestParseRequestNoParams is UnitTest
  """
  Test basic parsing of a JSON-RPC 2.0 request. Test assures that the parser primitive can deal with no Params
  """
  fun name(): String => "JSONRPC/parserequest/noparams"

  fun apply(h: TestHelper) ? =>
    let src =
      """
      {"jsonrpc": "2.0", "method": "foobar"}
      """
    let request = RequestParser.parse_request(src) as Request val
    h.assert_true(request.is_notification())
    h.assert_eq[String]("foobar", request.method)
    h.assert_is[RequestParamsType](None, request.params)
    h.assert_is[RequestIDType](None, request.id)

class iso _TestParseRequestArrayParams is UnitTest
  """
  Test basic parsing of a JSON-RPC 2.0 request. Test assures that the parser primitive can deal with array parameters.
  """

  fun name(): String => "JSONRPC/parserequest/array"

  fun apply(h: TestHelper) ? =>
    let src =
      """
      {"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 1}
      """
    let request = RequestParser.parse_request(src) as Request val
    h.assert_false(request.is_notification())
    h.assert_eq[String]("subtract", request.method)
    match request.id
    | let ids: String => h.fail("Shouldn't get a string for the ID")
    | let id: I64 => h.assert_eq[I64](id, 1)
    else
      h.fail("Shouldn't get a none")
    end

    let array = request.params as JsonArray
    h.assert_eq[USize](2, array.data.size())
    h.assert_eq[I64](42, array.data(0)? as I64)
    h.assert_eq[I64](23, array.data(1)? as I64)

class iso _TestParseRequestObjectParams is UnitTest
  """
  Test basic parsing of a JSON-RPC 2.0 request. Test assures that the parser primitive can deal with object parameters.
  """

  fun name(): String => "JSONRPC/parserequest/object"

  fun apply(h: TestHelper) ? =>
    let src =
      """
      {"jsonrpc": "2.0", "method": "subtract", "params": {"subtrahend": 23, "minuend": 42}, "id": 1}
      """
    let request = RequestParser.parse_request(src) as Request val
    h.assert_false(request.is_notification())
    h.assert_eq[String]("subtract", request.method)
    match request.id
    | let ids: String => h.fail("Shouldn't get a string for the ID")
    | let id: I64 => h.assert_eq[I64](id, 1)
    else
      h.fail("Shouldn't get a none")
    end

    let params = request.params as JsonObject
    h.assert_eq[USize](2, params.data.size())
    h.assert_eq[I64](23, params.data("subtrahend")? as I64)
    h.assert_eq[I64](42, params.data("minuend")? as I64)

class iso _TestParseRequestBadParams is UnitTest
  fun name(): String => "JSONRPC/parserequest/bad-params"
  fun apply(h: TestHelper) =>
    let src = """
     {"jsonrpc":"2.0", "method": "bad-params", "params": true, "id":1}
    """
    match RequestParser.parse_request(src)
    | InvalidRequest => h.log("Bad Params identified as invalid, all good.")
    else
      h.fail("Bad Params not detected as invalid, all bad.")
    end

class iso _TestParseRequestBatch is UnitTest
  """
  Test parsing of JSON-RPC 2.0 batch requests: https://www.jsonrpc.org/specification#batch
  """
  fun name(): String => "JSONRPC/parserequest/batch"

  fun apply(h: TestHelper) ? =>
    let src = """
    [
        {"jsonrpc": "2.0", "method": "notify_sum", "params": [1,2,4]},
        {"jsonrpc": "2.0", "method": "notify_hello", "params": [7]}
    ]
    """
    match RequestParser.parse_request(src)
    | let batch: BatchRequest =>
      h.assert_eq[USize](2, batch.size())

      let req1 = batch(0)? as Request val
      h.assert_true(req1.is_notification())
      h.assert_eq[String]("notify_sum", req1.method)
      let params = req1.params as JsonArray
      h.assert_eq[USize](3, params.data.size())
      h.assert_eq[I64](1, params.data(0)? as I64)
      h.assert_eq[I64](2, params.data(1)? as I64)
      h.assert_eq[I64](4, params.data(2)? as I64)

      let req2 = batch(1)? as Request val
      h.assert_true(req2.is_notification())
      h.assert_eq[String]("notify_hello", req2.method)
      let params2 = req2.params as JsonArray
      h.assert_eq[USize](1, params2.data.size())
      h.assert_eq[I64](7, params2.data(0)? as I64)

    else
      h.fail("batch request not parsed to Array")
    end

class iso _TestParseRequestBatchInvalidJson is UnitTest
  fun name(): String => "JSONRPC/parserequest/batch-invalid-json"

  fun apply(h: TestHelper) =>
    let src = """
      [
        {"jsonrpc": "2.0", "method": "sum", "params": [1,2,4], "id": "1"},
        {"jsonrpc": "2.0", "method"
      ]
    """
    h.assert_is[ParseResult](
      InvalidJson,
      RequestParser.parse_request(src))


class iso _TestParseRequestBatchEmpty is UnitTest
  fun name(): String => "JSONRPC/parserequest/batch-empty"

  fun apply(h: TestHelper) =>
    let src = "[]"
    h.assert_is[ParseResult](
      InvalidRequest,
      RequestParser.parse_request(src))

class iso _TestParseRequestBatchInvalid is UnitTest
  fun name(): String => "JSONRPC/parserequest/batch-invalid"

  fun apply(h: TestHelper) ? =>
    let src = "[1,2,3]"
    match RequestParser.parse_request(src)
    | let br: BatchRequest =>
      h.assert_eq[USize](3, br.size())
      h.assert_is[(Request val | ParseError)](
        InvalidRequest,
        br(0)?)
      h.assert_is[(Request val | ParseError)](
        InvalidRequest,
        br(1)?)
      h.assert_is[(Request val | ParseError)](
        InvalidRequest,
        br(2)?)
    else
      h.fail("Invalid batch request not recognized as such.")
    end

class iso _TestParseRequestBatchSomeInvalid is UnitTest
  fun name(): String => "JSONRPC/parserequest/batch-some-invalid"

  fun apply(h: TestHelper) ? =>
    let src = """
    [
        {"jsonrpc": "2.0", "method": "sum", "params": [1,2,4], "id": "1"},
        {"jsonrpc": "2.0", "method": "notify_hello", "params": [7]},
        {"jsonrpc": "2.0", "method": "subtract", "params": [42,23], "id": "2"},
        {"foo": "boo"},
        {"jsonrpc": "2.0", "method": "foo.get", "params": {"name": "myself"}, "id": "5"},
        {"jsonrpc": "2.0", "method": "get_data", "id": "9"}
    ]
    """
    match RequestParser.parse_request(src)
    | let br: BatchRequest =>
      h.assert_eq[USize](6, br.size())

      let req1 = br(0)? as Request val
      h.assert_eq[String](req1.id as String, "1")
      h.assert_false(req1.is_notification())
      h.assert_eq[String](req1.method, "sum")

      let req2 = br(1)? as Request val
      h.assert_true(req2.is_notification())
      h.assert_is[None](req2.id as None, None)
      h.assert_eq[String](req2.method, "notify_hello")

      let req3 = br(2)? as Request val
      h.assert_eq[String](req3.id as String, "2")
      h.assert_false(req3.is_notification())
      h.assert_eq[String](req3.method, "subtract")

      h.assert_is[(Request val | ParseError)](
        InvalidRequest,
        br(3)?)

      let req4 = br(4)? as Request val
      h.assert_eq[String](req4.id as String, "5")
      h.assert_false(req4.is_notification())
      h.assert_eq[String](req4.method, "foo.get")

      let req5 = br(5)? as Request val
      h.assert_eq[String](req5.id as String, "9")
      h.assert_false(req5.is_notification())
      h.assert_eq[String](req5.method, "get_data")
      h.assert_is[RequestParamsType](req5.params, None)
    else
      h.fail("Batch request with some invalid entries not recognized as such")
    end

