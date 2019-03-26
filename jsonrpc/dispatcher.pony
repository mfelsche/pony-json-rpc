use "collections"
use "promises"

actor Dispatcher
  let _methods: Map[String, MethodHandler tag]

  new create() =>
    _methods = Map[String, MethodHandler tag]

  be register_handler(method: String, handler: MethodHandler tag) =>
    _methods(method) = handler

  be dispatch_request(request: Request val, p: Promise[Response val]) =>
    try
      _methods(request.method)?.handle(request, p)
    else
      p.reject()
    end
