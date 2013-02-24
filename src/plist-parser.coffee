class PlistNode
	constructor: (type, parent=null) ->
		@type = type
		@key = null
		@value = null

		@parent = parent
		@children = []

		return @

	addChild: (node) ->
		node.parent = @
		@children.push(node)
		return node

	getParent: () ->
		if @parent
			return @parent

		return @

	convert: () ->
		if not @children.length
			if @type == 'integer'
				return parseInt(@value, 10)
			else if @type == 'string'
				return @value
			else if @type == 'date'
				try
					return new Date(@value)
				catch e
					return null
			else if @type == 'true'
				return true
			else if @type == 'false'
				return false
			else if @type == 'real'
				return parseFloat(@value)
			else if @type == 'data'
				return decodeURIComponent(escape(window.atob(@value)))
			else if @type == 'dict'
				return {}
			else if @type == 'array'
				return []
		else
			if @type == 'dict'
				iterable = {}
				for child in @children
					if child.key
						iterable[child.key] = child.convert()
			else if @type == 'array'
				iterable = []
				for child in @children
					iterable.push(child.convert())

		return iterable

class PlistParser
	constructor: (sax, xml) ->
		@sax = sax
		@xml = xml
		@traverser = null
		@last = {
			'parent': null,
			'node': null,
			'key': null,
			'tag': null,
			'value': null
		}
		@error = false

		if not @validate()
			return @error

		return @parse()


	validate: ->
		parser = @sax.parser(true)

		parser.ondoctype = (doctype) =>
			if doctype != ' plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"'
				@error = new Error('Invalid DOCTYPE')

		parser.onerror = (error) =>
			@error = error

		parser.write(@xml).close()

		if @error
			return false

		return true

	parse: ->
		parser = @sax.parser(true)

		parser.onopentag = (node) =>
			if (node.name == 'plist')
				@validates = true
				return

			else if (node.name == 'key')
				@last.key = null
				return

			if not @traverser
				@traverser = new PlistNode(node.name)
				return
			
			@last.node = @traverser.addChild(new PlistNode(node.name))

			if @last.key
				@last.node.key = @last.key.valueOf()
				@last.key = null

			if (node.name == 'dict') or (node.name == 'array')
				@traverser = @last.node

		parser.ontext = (text) =>
			@last.value = text

		parser.onclosetag = (name) =>
			if (name == 'dict') or (name == 'array')
				@traverser = @traverser.getParent()
			else if name == 'key'
				if @last.value
					@last.key = @last.value.valueOf()
					@last.value = null
			else
				if @last.value
					@last.node.value = @last.value.valueOf()

		parser.write(@xml).close()
		return @traverser.convert()

window.PlistParser = PlistParser