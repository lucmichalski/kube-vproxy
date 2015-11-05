SRC_DIRECTORY=src
DIST_DIRECTORY=dist


all: css js html images fonts

clean:
	rm -rf $(DIST_DIRECTORY)

css: .dist
	node_modules/.bin/node-sass --source-map --output-style compressed \
		--include-path node_modules/bootstrap-sass/assets/stylesheets \
		--include-path node_modules/font-awesome/scss \
		$(SRC_DIRECTORY)/stylesheets/application.scss $(DIST_DIRECTORY)/application.css

js: .dist
	node_modules/.bin/browserify --debug -t [ reactify ] $(SRC_DIRECTORY)/javascripts/application.jsx -o $(DIST_DIRECTORY)/application.js

html: .dist
	node_modules/.bin/html-minifier --config-file config/html-minifier.json $(SRC_DIRECTORY)/index.html > $(DIST_DIRECTORY)/index.html

images: .dist
	cp -r $(SRC_DIRECTORY)/images/* $(DIST_DIRECTORY)

fonts: .dist
	cp -r node_modules/font-awesome/fonts $(DIST_DIRECTORY)

server: all
	node support/server.js --port 8000

.dist:
	mkdir -p $(DIST_DIRECTORY)
