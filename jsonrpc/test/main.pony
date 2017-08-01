use "ponytest"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestParseRequestArrayParams)
    test(_TestParseRequestObjectParams)
    test(_TestParseRequestNoId)
    test(_TestParseRequestNoParams)
    test(_TestParseBadJSON)
    test(_TestBadMethod)

    test(_TestResponseScalar)
    test(_TestResponseArray)
