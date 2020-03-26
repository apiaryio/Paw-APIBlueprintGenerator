# in API v0.2.0 and below (Paw 2.2.2 and below), require had no return value
((root) ->
  if root.bundle?.minApiVersion('0.2.0')
    root.Mustache = require("./mustache")
  else
    require("mustache.js")
)(this)

APIBlueprintGenerator = ->
  templateAction = readFile("apiblueprint-action.mustache")
  templateGroup = readFile("apiblueprint-group.mustache")

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
        if key == 'Content-Type'
          is_json = value.search(/(json)/i) > -1
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

    description = paw_request.description
    has_description = description && description.length > 0

    if has_headers || has_body || paw_request.headers['Content-Type']
      return {
        "headers?": has_headers,
        headers: headers,
        contentType: paw_request.headers['Content-Type'],
        "body?": has_headers && has_body,
        body: body,
        "description?": has_description,
        description: description,
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

  @renderPawItems = (items, level = 1) ->
    sections = for item in items
      @renderPawItem(item, level)

    sections.join("\n")

  @renderPawItem = (item, level = 1) ->
    if item.toString().match(/^RequestGroup/)
      @renderPawGroup(item, level)
    else
      @renderPawRequest(item, level)

  @renderPawGroup = (paw_group, level = 1) ->
    sections = []

    sections.push Mustache.render(templateGroup,
      level: "#".repeat(level),
      name: paw_group.name
    )

    children = paw_group.getChildren().sort (a, b) -> a.order - b.order

    sections = sections.concat @renderPawItems(children, level + 1)

    sections.join("\n")

  @renderPawRequest = (paw_request, level = 1) ->
    url = paw_request.url
    Mustache.render(templateAction,
      level: "#".repeat(level),
      name: paw_request.name.replace(/[\[\]\(\)]/g, ''),
      method: paw_request.method,
      path: @path(url),
      request: @request(paw_request),
      response: @response(paw_request.getLastExchange()),
    )

  @generate = (context, requests, options) ->
    if context.runtimeInfo.task == 'exportAllRequests'
      @renderPawItems(context.getRootRequestTreeItems())
    else
      @renderPawItems(requests)

  return

APIBlueprintGenerator.identifier = "io.apiary.PawExtensions.APIBlueprintGenerator"
APIBlueprintGenerator.title = "API Blueprint Generator"
APIBlueprintGenerator.fileExtension = "md"

registerCodeGenerator APIBlueprintGenerator
