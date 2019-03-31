use "ponytest"
use "collections"
use "immutable-json"

use ".."

class iso _TestResponseScalar is UnitTest
  """
  Tests that an array response properly converts into JSON
  """
  fun name(): String => "JSONRPC/parserequest/responsescalar"

  fun apply(h: TestHelper) =>
    let target =
      """{"jsonrpc":"2.0","id":1,"result":19}"""

    let resp = Response.success(where id'=I64(1), result'=I64(19))
    let resp_json = resp.to_json()
    h.assert_eq[String](target,resp_json)

  class iso _TestResponseArray is UnitTest
    """
    Tests that an array response properly converts into JSON
    """
    fun name(): String => "JSONRPC/parserequest/responsearray"

    fun apply(h: TestHelper) =>
      let target =
        """{"jsonrpc":"2.0","id":6,"result":[1,2,3]}"""
      let array = JsonArray([I64(1); I64(2); I64(3)])

      let resp = Response.success(I64(6), array)
      let resp_json = resp.to_json()
      h.assert_eq[String](target, resp_json)

class iso _TestResponseError is UnitTest
  """
  Tests that an error response properly converts into JSON
  """
  fun name(): String => "JSONRPC/parserequest/responseerror"

  fun apply(h: TestHelper) =>
    let target =
      """{"error":{"message":"Method not found","code":-32601},"jsonrpc":"2.0","id":1}"""

    let resp = Response.from_error(I64(1), Error.method_not_found())
    let resp_json = resp.to_json()
    h.assert_eq[String](target, resp_json)

class iso _TestResponseErrorNoID is UnitTest
  """
  Tests that an error response properly converts into JSON
  """
  fun name(): String => "JSONRPC/parserequest/responseerror/noid"

  fun apply(h: TestHelper) =>
    let target =
      """{"error":{"message":"Invalid Request","code":-32600},"jsonrpc":"2.0","id":null}"""

    let resp = Response.from_error(None, Error.invalid_request())
    let resp_json = resp.to_json()
    h.assert_eq[String](target, resp_json)

