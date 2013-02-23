Object.prototype.inject = (path, value) ->
	path_copy = path.slice()
	param = path_copy.pop()

	if path_copy.length > 1
		return this[param].setByArray(path_copy, value)
	else
		this[param] = value
	
	return


class PlistParser
	constructor: (sax, xml) ->
		@sax = sax
		@plist = {}
		@branches = []
		@parents = []
		@last = {}

		return @__parse(xml)

	__parse: (xml) ->
		parser = @sax.parser(true)

		parser.onopentag = (node) =>
			if node.name == 'dict'
				@branches.push(new PlistDict(@__frame({})))

			else if node.name == 'array'
				@branches.push(new PlistArray(@__frame([])))

			else
				@last.tag = node.name

		parser.ontext = (text) =>
			@last.value = text

		parser.onclosetag = (name) =>
			if name == 'dict'
				@__inject('dict')

			else if name == 'array'
				@__inject('array')

			else if name == 'key'
				@last.key = @last.value

			else
				if not @branches.length
					return
				
				last_branch_index = @branches.length-1

				if @last.key
					@branches[last_branch_index].add(@last.key, @last.tag, @last.value)
					@last.key = null
				else
					@branches[last_branch_index].add(@last.tag, @last.value)

		parser.write(xml).close()
		return @plist

	__frame: (empty) ->
		if not @last.key
			return

		@parents.push(@last.key)
		@plist.inject(@parents, empty)

		@last.key = null

		return @parents.slice()

	__inject: (type) ->
		branch = @branches.pop()
		plist = @plist

		for p, i in branch.parents
			plist = plist[p]

		@plist.inject(branch.parents, branch.contents)

		@parents.pop()

class PlistIterable
	constructor: (parents=[]) ->
		@parents = parents

	add: (name, value) ->
		if name == 'integer'
			return parseInt(value, 10)
		else if name == 'string'
			return value
		else if name == 'date'
			return value
		else if name == 'true'
			return true
		else if name == 'false'
			return false		

class PlistDict extends PlistIterable
	constructor: (parents) ->
		super parents
		@contents = {}

	add: (key, name, value) ->
		@contents[key] = super name, value

class PlistArray extends PlistIterable
	constructor: (parents) ->
		super parents
		@contents = []

	add: (name, value) ->
		@contents.push(super name, value)

window.PlistParser = PlistParser