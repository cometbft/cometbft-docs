###############################################################################
###                           Documentation                                 ###
###############################################################################
# Target versions to build documentation for. Add a branch from `cometbft` to
# the list to build a site for that version
VERSIONS=main v0.34.x v0.37.x

# This builds the documentation site for cometbft (docs.cometbft.com)
build-docs:
	@for v in $(VERSIONS); do \
		echo "Clone and build docs for version $${v}"; \
		mkdir -pv build/$${v} ; \
		cd build/$${v} ; \
		git clone -b $${v} https://github.com/cometbft/cometbft.git ; \
		cd ../.. ; \
		dest="$$(echo $${v} | sed 's/.x//;')" ; \
		mkdir -p _pages/$${dest}/spec ; \
        cp -r build/$${v}/cometbft/docs/* _pages/$${dest} ; \
		cp -r build/$${v}/cometbft/spec/* _pages/$${dest}/spec ; \
	done ; \
    rm -Rf ./build ; \
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