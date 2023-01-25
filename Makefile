###############################################################################
###                           Documentation                                 ###
###############################################################################
# Target versions to build documentation for
VERSIONS=main v0.34.x v0.37.x

# This builds a docs site for cometbft.
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
    rm -Rf ./build ;
.PHONY: build-docs

# Build and serve the local version of the docs on the current branch from
serve-docs:
	# TODO
.PHONY: serve-docs

sync-docs:
	# TODO
.PHONY: sync-docs