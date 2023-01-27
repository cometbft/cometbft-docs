###############################################################################
###                           Documentation                                 ###
###############################################################################

# Clone repository branches and copy docs and spec folders
fetch-docs: clean
	@echo "Fetching documentation from CometBFT repository"
	@while read -r v dest; do \
		echo "Clone docs for version $${v}"; \
		mkdir -pv build/$${v} ; \
		cd build/$${v} ; \
		git clone -b $${v} https://github.com/cometbft/cometbft.git ; \
		cd ../.. ; \
		mkdir -p _pages/$${dest}/spec ; \
		cp -r build/$${v}/cometbft/docs/* _pages/$${dest} ; \
		cp -r build/$${v}/cometbft/spec/* _pages/$${dest}/spec ; \
		echo "Setting README.md from $${v} as the root landing page" ; \
		cp _pages/$${dest}/README.md _pages/README.md ; \
		echo "" ; \
	done < VERSIONS ; \
	find _pages -type f -iname README.md | xargs -I % sh -c 'mv -v % $$(dirname %)/index.md'
.PHONY: fetch-docs

# This builds the documentation site for cometbft (docs.cometbft.com)
build-docs:
	@echo "Building documentation"
	@docker run --volume ${PWD}:/srv/jekyll jekyll/builder:stable \
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
	@echo "Deleting all intermediate build artifacts"
	@rm -Rf ./build _pages _site .jekyll-cache ;
.PHONY: clean
