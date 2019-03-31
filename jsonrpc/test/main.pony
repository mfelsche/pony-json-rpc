use "ponytest"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    ParserTests.tests(test)

    test(_TestResponseScalar)
    test(_TestResponseArray)
    test(_TestResponseError)
    test(_TestResponseErrorNoID)

    test(_TestDispatchGreet)
