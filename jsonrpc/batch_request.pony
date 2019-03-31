use "immutable-json"

class val BatchRequest
  let requests: Array[(Request | ParseError)] val

  new val create(requests': Array[(Request | ParseError)] val) =>
    requests = requests'

  fun box size(): USize => requests.size()
  fun box apply(i: USize): (Request | ParseError) ? => requests(i)?

  fun box to_json(): String =>
    let s = recover trn String() end

    s.append("[")
    let iter = requests.values()
    while iter.has_next() do
      let r = try iter.next()? else "\"ERROR\"" end
      s.append(
        match r
        | let req: Request => req.to_json()
        | let _: InvalidJson    => "{\"error\": \"INVALID JSON\"}"
        | let _: InvalidRequest => "{\"error\": \"INVALID REQUEST\"}"
        else
          "WEIRD!"
        end)
      if iter.has_next() then
        s.append(", ")
      end
    end
    s.append("]")

    consume s
