###############################################################################
###                           Documentation                                 ###
###############################################################################

# Clone repository branches and copy docs and spec folders into our _pages
# collection.
fetch: clean
	@echo "---> Fetching documentation from CometBFT repository"
	@mkdir -p build ; \
		cd build ; \
		git clone https://github.com/cometbft/cometbft.git ; \
		cd .. ; \
		while read -r branch output_path visible; do \
			echo "-----> Checking out $${branch}" ; \
			cd build/cometbft ; \
			git checkout $${branch} ; \
			cd ../.. ; \
			mkdir -pv _pages/$${output_path}/spec ; \
			mkdir -pv _pages/$${output_path}/rpc ; \
			cp -r build/cometbft/docs/* _pages/$${output_path} ; \
			cp -r build/cometbft/spec/* _pages/$${output_path}/spec ; \
			cp -r build/cometbft/rpc/openapi/* _pages/$${output_path}/rpc ; \
			find _pages/$${output_path} -type f -iname README.md | xargs -I % sh -c 'mv -v % $$(dirname %)/index.md' ; \
			echo "" ; \
		done < VERSIONS
.PHONY: fetch

# This builds the documentation site for cometbft (docs.cometbft.com)
build: versions-data
	@echo "---> Building documentation"
	@rm -rf _site
	@docker run -it --rm --volume ${PWD}:/srv/jekyll jekyll/builder:stable \
		/bin/bash -c 'cd /srv/jekyll/ && bundle install && bundle exec jekyll build --future -V'
.PHONY: build

# Creates _data/versions.yml, which is built from the VERSIONS file, in order
# to provide information about versions to Jekyll during the site build
# process. This assists in constructing the dropdown version selector menu.
#
# Also creates _data/default_version.yml, which simply contains the output path
# of the last version listed in the VERSIONS file.
versions-data:
	@mkdir -p _data
	@rm -f _data/versions.yml _data/default_version.yml
	@while read -r branch output_path visible ; do \
		echo "- branch: $${branch}" >> _data/versions.yml; \
		echo "  output_path: $${output_path}" >> _data/versions.yml; \
		echo "  visible: $${visible}" >> _data/versions.yml; \
		echo "output_path: $${output_path}" > _data/default_version.yml ; \
	done < VERSIONS
.PHONY: versions-data

# This command checks for broken links (error 404) on pages. In order to run
# this command locally, please run `make serve` in a terminal window, then
# open another terminal window and run this command `make check-broken`.
check-broken-links:
	@rm -f broken_links.txt
	@echo "---> Checking for broken link on the pages..."
	@echo "---> Installing muffet to check links..."
	@go install github.com/raviqqe/muffet/v2@latest
	@while read -r branch output_path visible ; do \
    		echo "------> Checking broken links for release $${output_path}" ; \
    		muffet --skip-tls-verification -e https://fonts* http://0.0.0.0:8088/$${output_path} >> broken_links.txt ; \
    		echo "------> Saved broken links for release $${output_path} in broken_links.txt" ; \
	done < VERSIONS
.PHONY: check-broken-links

# This builds the documentation site for cometbft (docs.cometbft.com)
serve: versions-data
	@echo "---> Preparing to host documentation site locally"
	@echo "---> This might take a few seconds..."
	@echo "---> If the site was not built with 'make build', this will take a bit longer..."
	@docker run -it --rm -p 8088:8088 --volume ${PWD}:/srv/jekyll jekyll/builder:stable \
	/bin/bash -c 'cd /srv/jekyll/ && jekyll serve --incremental --port 8088'
.PHONY: build

clean:
	@echo "---> Deleting all previous build artifacts"
	@rm -rf ./build _pages _site .jekyll-cache _data/versions.yml _data/default_version.yml
.PHONY: clean
