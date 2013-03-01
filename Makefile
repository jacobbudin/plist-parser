test:
	./node_modules/.bin/mocha \
		--reporter spec \
		./tests/test.js

.PHONY: test