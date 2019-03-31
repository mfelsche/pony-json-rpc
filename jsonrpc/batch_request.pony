
class val BatchRequest
  let requests: Array[(Request val | ParseError)] val

  new val create(requests': Array[(Request val | ParseError)] val) =>
    requests = requests'

  fun box size(): USize => requests.size()
  fun box apply(i: USize): (Request val | ParseError) ? => requests(i)?
