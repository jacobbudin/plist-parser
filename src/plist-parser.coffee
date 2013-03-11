root = exports ? this

class PlistNode
	constructor: (type, processors) ->
		@type = type
		@processors = processors

		@key = null
		@value = null
		@parent = null
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
			if @processors? and @processors[@type]?
				return @processors[@type](@value)

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
				return @value
			else if @type == 'dict'
				return {}
			else if @type == 'array'
				return []
			else
				return @value
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
	constructor: (xml, opts=null) ->
		if exports? and not exports.sax?
			try
				sax = require('sax')
			catch e
				
		if not sax? and not root.sax?
			return new Error('Missing required dependency: sax-js (https://github.com/isaacs/sax-js)')

		@sax = sax ? root.sax
		@xml = xml
		@traverser = null
		@last = {
			'parent': null,
			'node': null,
			'key': null,
			'tag': null,
			'value': null
		}
		@error = null
		@opts = {
			'processors': {
				'integer': opts?.processors?.integer ? null,
				'string': opts?.processors?.string ? null,
				'date': opts?.processors?.date ? null,
				'true': opts?.processors?.true ? null,
				'false': opts?.processors?.false ? null,
				'real': opts?.processors?.real ? null,
				'data': opts?.processors?.data ? null,
				'dict': opts?.processors?.dict ? null,
				'array': opts?.processors?.array ? null
			}
		}

		return @

	validate: ->
		parser = @sax.parser(true)

		parser.onopentag = (node) ->
			if not @first
				@first = true
				if node.name != 'plist'
					@error = new Error('Invalid Property List contents (<plist> missing)')

		parser.ondoctype = (doctype) =>
			if doctype != ' plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"'
				@error = new Error('Invalid Property List DOCTYPE')

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
				return

			else if (node.name == 'key')
				@last.key = null
				return

			if not @traverser
				@traverser = @last.node = new PlistNode(node.name, @opts.processors)
				return
			
			@last.node = @traverser.addChild(new PlistNode(node.name, @opts.processors))

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
			else if @last.node
				if @last.value
					@last.node.value = @last.value.valueOf()

				@last.node = null

		parser.write(@xml).close()
		return @traverser.convert()

root.PlistParser = PlistParser
root.PlistNode = PlistNode