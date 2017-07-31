use "ponytest"
use "collections"
use "json"

use ".."

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestParseRequestArrayParams)
    test(_TestParseRequestObjectParams)
    test(_TestParseRequestNoId)
    test(_TestParseRequestNoParams)

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


