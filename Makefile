all: clean build-docs
.PHONE: all

###############################################################################
###                           Documentation                                 ###
###############################################################################
# Target versions to build documentation for. Add a branch from `cometbft` to
# the list to build a site for that version
VERSIONS=main v0.34.x v0.37.x

# This builds the documentation site for cometbft (docs.cometbft.com)
build-docs:
	# clone repository branches and copy docs and spec folders
	@for v in $(VERSIONS); do \
		echo "Clone and build docs for version $${v}"; \
		mkdir -pv build/$${v} ; \
		cd build/$${v} ; \
		git clone -b $${v} https://github.com/cometbft/cometbft.git ; \
		cd ../.. ; \
		dest="$$(echo $${v} | sed 's/.x//;')" ; \
		mkdir -p _pages/$${dest}/spec ; \
		# copy only the docs and spec folders to _pages since they are the documentation content \
        cp -r build/$${v}/cometbft/docs/* _pages/$${dest} ; \
		cp -r build/$${v}/cometbft/spec/* _pages/$${dest}/spec ; \
	done ; \
	rm -Rf ./build ; \

	# rename readme markdown to index
	find ./_pages -type f -iname 'README.md' | sed -e "p;s/readme/index/i" |  xargs -n2 mv ;

	# build the Jekyll site in a Docker container \
    docker run --volume ${PWD}:/srv/jekyll jekyll/builder:stable \
		/bin/bash -c 'cd /srv/jekyll && bundle install && bundle exec jekyll build --future'
.PHONY: build-docs

# Build and serve the built site (_site folder)
serve-docs:
	@echo "Running documentation site at http://localhost:8088"
	@go run http_server.go
.PHONY: serve-docs

sync-docs:
	# TODO
.PHONY: sync-docs

clean:
	rm -Rf ./build _pages _site .jekyll-cache ;
.PHONY: clean