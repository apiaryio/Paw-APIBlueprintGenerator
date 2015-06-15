assert = require('assert')
APIBlueprintGenerator = require('../APIBlueprintGenerator.coffee')


# Mock Paw Context
class Context
  constructor: (@request) ->

  getCurrentRequest: ->
    @request


# Mock Paw HTTPExchange
class HTTPExchange
  constructor: (@responseStatusCode, @responseHeaders, @responseBody) ->


# Mock Paw Request
class Request
  constructor: (@name, @method, @url, @headers, @body, @exchange) ->

  getLastExchange: ->
    @exchange


describe 'API Blueprint Generator', ->
  describe 'when importing an API Blueprint', ->
    before ->
      @generator = new APIBlueprintGenerator()

    it 'renders a GET request with a response', ->
      exchange = new HTTPExchange(200, {'Content-Type': 'plain/text'}, 'Hello World')
      request = new Request('foo', 'GET', 'https://apiary.io/path', {}, '', exchange)
      context = new Context(request)
      blueprint = @generator.generate(context)
      assert.equal(blueprint, """
# GET /path

+ Response 200 (plain/text)

        Hello World

""")

