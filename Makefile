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
			cp -r build/cometbft/docs/* _pages/$${output_path} ; \
			cp -r build/cometbft/spec/* _pages/$${output_path}/spec ; \
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

# Serve the built site from the _site folder
serve:
	@echo "---> Running documentation site at http://localhost:8088"
	@go run http_server.go
.PHONY: serve

clean:
	@echo "---> Deleting all previous build artifacts"
	@rm -rf ./build _pages _site .jekyll-cache _data/versions.yml _data/default_version.yml
.PHONY: clean
