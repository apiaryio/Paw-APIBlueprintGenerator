require "mustache.js"

APIBlueprintGenerator = ->

  # Generate a response dictionary for the mustache context from a paw HTTPExchange
  #
  # @param [HTTPExchange] exchange The paw HTTP exchange for the response
  #
  # @return [Object] The template context object
  #
  @response = (exchange) ->
    if !exchange
      return null

    headers = []
    is_json = false
    for key, value of exchange.responseHeaders
      if key in ['Content-Type', 'Connection', 'Date', 'Via', 'Server', 'Content-Length']
        is_json = (key == 'Content-Type' && value.search(/(json)/i) > -1)
        continue

      headers.push({ key: key, value: value })
    has_headers = (headers.length > 0)

    body = exchange.responseBody
    has_body = body.length > 0
    if has_body
      if is_json
        body = JSON.stringify(JSON.parse(body), null, 4)
      body_indentation = '        '
      if has_headers
        body_indentation += '    '
      body = body.replace(/^/gm, body_indentation)

    return {
      statusCode: exchange.responseStatusCode,
      contentType: exchange.responseHeaders['Content-Type'],
      "headers?": has_headers,
      headers: headers
      "body?": has_headers && has_body,
      body: body,
    }

  # Generate a request dictionary for the mustache context from a paw Request
  #
  # @param [Request] exchange The paw HTTP request
  #
  # @return [Object] The template context object
  #
  @request = (paw_request) ->
    headers = []
    is_json = false
    for key, value of paw_request.headers
      if key in ['Content-Type']
        is_json = (value.search(/(json)/i) > -1)
        continue

      headers.push({ key: key, value: value })
    has_headers = (headers.length > 0)

    body = paw_request.body
    has_body = body.length > 0
    if has_body
      if is_json
        body = JSON.stringify(JSON.parse(body), null, 4)
      body_indentation = '        '
      if has_headers
        body_indentation += '    '
      body = body.replace(/^/gm, body_indentation)

    if has_headers || has_body || paw_request.headers['Content-Type']
      return {
        "headers?": has_headers,
        headers: headers,
        contentType: paw_request.headers['Content-Type'],
        "body?": has_headers && has_body,
        body: body,
      }

  # Get a path from a URL
  #
  # @param [String] url The given URL
  #
  # @return [String] The path from the URL
  @path = (url) ->
    path = url.replace(/^https?:\/\/[^\/]+/i, '')
    if !path
      path = '/'

    path

  @generate = (context) ->
    paw_request = context.getCurrentRequest()
    url = paw_request.url
    template = readFile("apiblueprint.mustache")
    Mustache.render(template,
      method: paw_request.method,
      path: @path(url),
      request: @request(paw_request),
      response: @response(paw_request.getLastExchange()),
    )

  return

APIBlueprintGenerator.identifier = "io.apiary.PawExtensions.APIBlueprintGenerator"
APIBlueprintGenerator.title = "API Blueprint Generator"
APIBlueprintGenerator.fileExtension = "md"

registerCodeGenerator APIBlueprintGenerator
