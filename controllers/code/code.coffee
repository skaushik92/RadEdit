fs.cache = {} unless fs.cache

app.on 'get', '/code', (request, response) ->
	send response, 'code/editor',
		tree: fs.treeString.replace(/([\\'])/g, '\\$1')

readFile = (rel, callback) ->
	path = documentRoot + '/' + rel
	fs.readFile path, (err, content) ->
		code = ('' + content).replace /\r/g, ''
		file =
			version: 0
			rel: rel
			code: code
			savedCode: code
			clients: {}
		fs.cache[rel] = file
		callback file

writeFile = (rel) ->
	file = fs.cache[rel]
	file.savedCode = file.code
	path = documentRoot + '/' + rel
	fs.writeFile path, file.code

io.on 'connection', (socket) ->

	closeCurrentFile = ->
		rel = socket.currentRel
		file = fs.cache[rel]
		if file
			delete file.clients[socket.id]

	sendFile = (file) ->
		file.clients[socket.id] = socket
		socket.currentRel = file.rel
		socket.emit 'code:got',
			rel: file.rel
			code: file.code
			canSave: (file.code isnt file.savedCode) 
	
	socket.on 'disconnect', ->
		closeCurrentFile()

	socket.on 'code:get', (json) ->
		rel = json.rel
		if socket.currentRel isnt rel
			closeCurrentFile()

		file = fs.cache[rel]
		if file
			sendFile file
		else
			readFile rel, sendFile

	socket.on 'code:change', (json) ->
		rel = json.rel
		change = json.change
		file = fs.cache[rel]
		if file
			code = file.code
			from = change[0]
			to = from + change[1]
			text = change[2]
			file.code = code.substr(0, from) + text + code.substr(to)
			for id, client of file.clients
				if id isnt socket.id
					client.emit 'code:changed', json

	socket.on 'code:save', (json) ->
		writeFile json.rel
