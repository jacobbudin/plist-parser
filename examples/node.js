var fs = require('fs');
var PlistParser = require('../lib/plist-parser.js');

var xml = fs.readFileSync(__dirname + '/xml/playlist.xml').toString();

// Create a new instance of the parser with your input
var plist = new PlistParser.PlistParser(xml);

// Validate the input
if(plist.validate()){
	// Parse the input, returning a JS object
	var result = plist.parse();
}