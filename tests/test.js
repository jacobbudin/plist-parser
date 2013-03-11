var fs = require('fs');
var assert = require('assert');
var PlistParser = require('../lib/plist-parser.js');

describe('PlistNode', function(){
	describe('array', function(){
		it('should return empty array', function(){
			var root = new PlistParser.PlistNode('array');
			assert.deepEqual([], root.convert());
		})
	})
	describe('dict', function(){
		it('should return empty dict', function(){
			var root = new PlistParser.PlistNode('dict');
			assert.deepEqual({}, root.convert());
		})
	})
	describe('true', function(){
		it('should return true', function(){
			var root = new PlistParser.PlistNode('true');
			assert.equal(true, root.convert());
		})
	})
	describe('false', function(){
		it('should return false', function(){
			var root = new PlistParser.PlistNode('false');
			assert.deepEqual(false, root.convert());
		})
	})
})

describe('PlistParser', function(){
	describe('playlist', function(){
		it('should contain 22 tracks', function(){
			var xml = fs.readFileSync(__dirname + '/xml/playlist.xml').toString();
			var root = new PlistParser.PlistParser(xml).parse();
			var track_count = 0;

			for(var track in root['Tracks']){
				if(root['Tracks'].hasOwnProperty(track)){
					track_count++;
				}
			}

			assert.equal(22, track_count);
		})
	})
	describe('playlist', function(){
		it('have a last Track ID value of 17393', function(){
			var xml = fs.readFileSync(__dirname + '/xml/playlist.xml').toString();
			var root = new PlistParser.PlistParser(xml).parse();

			assert.equal(17393, root['Playlists'][0]['Playlist Items'][21]['Track ID']);
		})
	})
})