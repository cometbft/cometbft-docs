###############################################################################
###                           Documentation                                 ###
###############################################################################

# Clone repository branches and copy docs and spec folders into our _pages
# collection.
fetch: clean versions-data
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
			mkdir -pv _pages/$${output_path}/references/spec ; \
			mkdir -pv _pages/$${output_path}/references/rpc ; \
			cp -r build/cometbft/docs/* _pages/$${output_path} ; \
			cp -r build/cometbft/spec/* _pages/$${output_path}/references/spec ; \
			cp -r build/cometbft/rpc/openapi/* _pages/$${output_path}/references/rpc ; \
			find _pages/$${output_path} -type f -iname README.md | xargs -I % sh -c 'mv -v % $$(dirname %)/index.md' ; \
			rm -rf _pages/$${output_path}/architecture _pages/$${output_path}/rfc ; \
			echo "" ; \
		done < VERSIONS
	@if [ "${LOCAL_DOCS_REPO}" ]; then \
		echo "Executing a local build from: $${LOCAL_DOCS_REPO}"; \
		mkdir -pv _pages/dev/references/spec ; \
		mkdir -pv _pages/dev/references/rpc ; \
		cp -r $${LOCAL_DOCS_REPO}/docs/* _pages/dev ; \
		cp -r $${LOCAL_DOCS_REPO}/spec/* _pages/dev/references/spec ; \
		cp -r $${LOCAL_DOCS_REPO}/rpc/openapi/* _pages/dev/references/rpc ; \
		find _pages/dev -type f -iname README.md | xargs -I % sh -c 'mv -v % $$(dirname %)/index.md' ; \
		rm -rf _pages/dev/architecture _pages/dev/rfc ; \
		echo ""; \
	fi
.PHONY: fetch

# This builds the documentation site for cometbft (docs.cometbft.com)
build:
	@if [ ! -d "_pages" ]; then echo "Directory _pages does not exist. Please run \"make fetch\" before running this command"; exit 1; fi
	@echo "---> Building documentation"
	@rm -rf _site
	@docker run -it --rm --volume ${PWD}:/srv/jekyll jekyll/builder:stable \
		/bin/bash -c 'cd /srv/jekyll/ && bundle install && bundle exec jekyll build --future -V '
	@rm -rf _site/build
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
	@if [ "${LOCAL_DOCS_REPO}" ]; then \
		echo "Adding \"dev\" version"; \
		echo "- branch: dev" >> _data/versions.yml; \
		echo "  output_path: dev" >> _data/versions.yml; \
		echo "  visible: true" >> _data/versions.yml; \
		echo "output_path: dev" > _data/default_version.yml ; \
	fi
.PHONY: versions-data

check-broken-links:
	@rm -f broken_links_*.txt
	@echo "---> Checking for broken link on the pages..."
	@echo "---> Installing \"muffet\" tool to check links if not already installed"
	@go install github.com/raviqqe/muffet/v2@latest
	@while read -r branch output_path visible ; do \
    		echo "------> Checking broken links for release $${output_path}" ; \
    		muffet --skip-tls-verification -e https://github.com -e https://fonts* http://0.0.0.0:8088/$${output_path} >> broken_links_$${output_path}.txt ; \
    		echo "------> Saved broken links for release $${output_path} in broken_links_$${output_path}.txt" ; \
	done < VERSIONS
	@if [ "${LOCAL_DOCS_REPO}" ]; then \
  	echo "------> Checking broken links for release dev" ; \
		muffet --skip-tls-verification -e https://github.com -e https://fonts* http://0.0.0.0:8088/$${output_path} >> broken_links_dev.txt ; \
		echo "------> Saved broken links for release dev in broken_links_dev.txt" ; \
  fi
.PHONY: check-broken-links

# This builds the documentation site for cometbft (docs.cometbft.com)
serve:
	@if [ ! -d "_site" ]; then echo "Directory _site does not exist. Please run \"make build\" before running this command"; exit 1; fi
	@echo "---> Preparing to host documentation site locally"
	@echo "---> This might take a few seconds..."
	@docker run -it --rm -p 8088:8088 --volume ${PWD}:/srv/jekyll jekyll/builder:stable \
	/bin/bash -c 'cd /srv/jekyll/ && jekyll serve --skip-initial-build true --incremental --port 8088'
.PHONY: build

clean:
	@echo "---> Deleting all previous build artifacts"
	@rm -rf ./build _pages _site .jekyll-cache _data/versions.yml _data/default_version.yml
.PHONY: clean
