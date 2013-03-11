# PlistParser [![Build Status](https://travis-ci.org/jacobbudin/plist-parser.png)](https://travis-ci.org/jacobbudin/plist-parser)

PlistParser is an XML Property List (.plist) parser in JavaScript. It may be used both as client-side JavaScript and derivative programming languages that implement [CommonJS](http://www.commonjs.org) such as [node.js](http://nodejs.org).

## Dependencies

PlistParser requires [sax-js](https://github.com/isaacs/sax-js).

## Installation

PlistParser has been published to [npm](https://npmjs.org), and the [PlistParser npm package](https://npmjs.org/package/plist-parser) can be installed like so:

	$ npm install plist-parser

In most other cases, you should be able to use your package manager to install it directly from its master archive `https://github.com/jacobbudin/plist-parser/archive/master.tar.gz`.

To use PlistParser client-side, simply include the `<script>` tags as shown below.

## Usage

Include `plist-parser.js` and create a new instance of `PlistParser`.

`PlistParser` has three methods: a constructor, `validate`, and `parse`. `PlistNode` is a helper class. If the the XML file fails validation or parsing, an [`Error` instance](https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Error) will be stored as an `error` property of your `PlistParser` instance.

```html
<html>
<head>
	<title>Hello world</title>
	<script type="text/javascript" src="sax.js"></script>
	<script type="text/javascript" src="plist-parser.js"></script>
	<script type="text/javascript">
		var xml, plist, result;

		// Example input (replace this with the contents of valid XML Property List file)
		xml = '<?xml version="1.0" encoding="UTF-8"?>...';

		// Create a new instance of the parser with your input
		plist = new PlistParser(xml);

		// Validate the input
		if(plist.validate()){
			// Parse the input, returning a JS object
			result = plist.parse();
		}
	</script>
</head>
<body>
	
</body>
</html>
```

## Processors

PlistParser parser includes processor functions to convert values into their appropriate JavaScript types. For example, you may need to replace the parsing of `data` nodes to better suit your project's needs because of [various issues](https://developer.mozilla.org/en-US/docs/DOM/window.btoa).

`PlistParser` accepts an options object as its second argument to override the default processors. You can override as many or as few as you choose. If a processor is not provided, PlistParser will use the appropriate default processor.

For example, if we wanted all `string` node values converted into integers:

```js
plist = new PlistParser(xml, {
	'processors': {
		'string': function(value){ return parseInt(value, 10); }
	});
```

## License

The MIT License (MIT)

Copyright (c) 2013 Jacob Budin  
Some rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.