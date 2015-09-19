{CompositeDisposable} = require 'atom'
http = require 'http'

module.exports = AtomElixirPlayground =
  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-elixir-playground:upload_selection': () => @upload_selection()
      'atom-elixir-playground:upload_file': () => @upload_file()

  get_selection_text: ->
    editor = atom.workspace.getActivePane().getActiveEditor()
    selected_text = editor.getSelectedText()

    return selected_text

  get_file_text: ->
    editor = atom.workspace.getActivePane().getActiveEditor()
    text = editor.getText()

    return text

  upload_selection: ->
    text = @get_selection_text()
    query = "code=#{encodeURIComponent text}"
    @api_request(query)

  upload_file: ->
    text = @get_file_text()
    query = "code=#{encodeURIComponent text}"
    @api_request(query)

  api_request: (query) ->
    options =
      host: "play.elixirbyexample.com",
      path: "/share/",
      method: "POST",
      headers:
        'Content-type': 'application/x-www-form-urlencoded'

    response = ""
    request = http.request options, (res) =>
      res.setEncoding "utf8"

      res.on "data", (chunk) -> response += chunk

      res.on "end", =>
        if response.toLowerCase().indexOf("Bad API request.") >= 0
          atom.notifications.addWarning("ERROR: " + response)
        else
          atom.clipboard.write "http://play.elixirbyexample.com/s/#{response}"
          atom.notifications.addSuccess("An Elixir Playground url has been copied to your clipboard.")

    request.write query
    request.end()
