# JSON-RPC 2.0 (Pony)

This is a Pony implementation of a JSON-RPC 2.0 server. When looking at how this library is organized, it is worth keeping in mind that [JSON-RPC 2.0](http://www.jsonrpc.org/specification) is a _transport agnostic_ protocol. As such, the dispatching mechanism in this library is designed to work without regard for how the JSON payloads are received or emitted. Not only does this conform to the JSON-RPC 2.0 protocol, but it makes for far more testable code.

## NOT COMPLETE
This is a work in progress. Please don't try and use this yet.