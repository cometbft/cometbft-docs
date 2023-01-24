###############################################################################
###                           Documentation                                 ###
###############################################################################

# This builds a docs site for cometbft.
build-docs:
	mkdir -p _pages ; \
    rm -Rf ./cometbft ; \
    git clone https://github.com/cometbft/cometbft.git ; \
    cp -r ./cometbft/docs ./_pages ; \
    cp -r ./cometbft/spec ./_pages ;
.PHONY: build-docs

# Build and serve the local version of the docs on the current branch from
serve-docs:
	# TODO
.PHONY: serve-docs

sync-docs:
	# TODO
.PHONY: sync-docs