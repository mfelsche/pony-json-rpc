use "ponytest"
use "collections"
use "json"

use ".."

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
    try 
      let request = RequestParser.parse_request(src)?
      h.fail("Request parser should have failed but didn't")
    end

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
    try
      let request = RequestParser.parse_request(src)?
      h.fail("Request parser should have failed but didn't")
    end

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
    let request = RequestParser.parse_request(src)?
    h.assert_eq[String]("foobar", request.method)   
    let array = request.params as JsonArray 
    h.assert_eq[USize](2, array.data.size())
    h.assert_eq[I64](42, array.data(0)? as I64)
    h.assert_eq[I64](23, array.data(1)? as I64)
 
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
    let request = RequestParser.parse_request(src)?
    h.assert_eq[String]("foobar", request.method)    

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
    let request = RequestParser.parse_request(src)?
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
    let request = RequestParser.parse_request(src)?
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