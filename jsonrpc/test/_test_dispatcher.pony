use "ponytest"
use "collections"
use "promises"
use "json"

use ".."

class iso _TestDispatchGreet is UnitTest
  """
  Tests that the dispatcher will handle the happy path to execution
  """
  fun name(): String => "JSONRPC/dispatcher/greet"

  fun apply(h: TestHelper) ? =>          
    h.long_test(30000)
    let src = 
      """
      {"jsonrpc": "2.0", "method": "greet", "params": "bob", "id": 1}
      """
    let request= RequestParser.parse_request(src)?
    let handler = _HelloWorld
    let dispatcher = Dispatcher 
    dispatcher.register_handler("greet", handler)

    let p = Promise[Response val]
    p.next[None]( {(r:Response val): None ? => 
                    h.assert_eq[String]("hello bob", r.result as String)
                    h.complete(true) } iso,
                  {(): None =>                     
                    h.complete(false) } iso)
       
    dispatcher.dispatch_request(request, p) 

actor _HelloWorld is MethodHandler
  be handle(request: Request val, p: Promise[Response val]) =>  
    let name: String = match request.params
    | let s: String => s
    else
      "world!"
    end
    let greet: String = "hello " + name 

    let r: Response val = recover val Response(request.method, greet, request.id) end
    p(r)