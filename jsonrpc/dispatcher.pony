use "collections"
use "promises"

actor Dispatcher
  let _methods: Map[String, MethodHandler tag]

  new create() =>
    _methods = Map[String, MethodHandler tag]

  be register_handler(method: String, handler: MethodHandler tag) =>
    _methods(method) = handler

  fun tag apply(request: Request val): Promise[Response val] =>
    let promise = Promise[Response val]
    dispatch_request(request, promise)
    promise

  be dispatch_request(request: Request val, p: Promise[Response val]) =>
    try
      _methods(request.method)?.handle(request, p)
    else
      p.reject()
    end
