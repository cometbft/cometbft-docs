# CometBFT Documentation

This repository contains the logic to build the CometBFT documentation site
(<https://docs.cometbft.com>)

It uses [Jekyll](https://jekyllrb.com/) framework to the site structure and
templating.

The technical content for the documentation is retrieved from the
[CometBFT](https://github.com/cometbft/cometbft) repository, more specifically
the `/docs` and `/spec` folders.

## Configuring versions

The [`VERSIONS`](./VERSIONS) file controls which versions of the documentation
are built, their output paths/URLs, and whether or not they are visible in the
dropdown selector in the documentation.

The format of the `VERSIONS` file is as follows:

```
branch    output_path    visible_in_menu
```

The number of spaces between each column does not matter, as long as there are
spaces. Comments within the file itself are **not** supported. The
`visible_in_menu` field is a YAML boolean value, meaning that it can be either
`true`, `false`, `yes` or `no`. There must be **no** newline at the end of the
`VERSIONS` file.

For example, the following `VERSIONS` file:

```
main      main    false
v0.37.x   v0.37   true
v0.34.x   v0.34   true
```

will result in the following:

- The `main` branch's docs will be built to `https://docs.cometbft.com/main`,
  but will **not** be visible in the version selector dropdown menu.
- The `v0.37.x` branch's docs will be built to
  `https://docs.cometbft.com/v0.37`, and the `v0.37` version **will** be visible
  in the version selector dropdown menu.
- The `v0.34.x` branch's docs will be built to
  `https://docs.cometbft.com/v0.34`, and the `v0.34` version **will** be visible
  in the version selector dropdown menu.

The **last** entry in the `VERSIONS` file will be configured as the default
landing page when users navigate to the root of the documentation site at
`https://docs.cometbft.com/`.

## Building the site

In order to build the website locally, please run the following command:

```bash
# Fetch the different branches' documentation into the local "build/" directory.
make fetch

# Build the documentation in a Docker container using the latest stable Jekyll
# release.
make build
```

If everything runs correctly, a new folder will be created `_site`. This folder
contains the website files built by Jekyll.

## Running the site locally

If you want to run the site locally you can run the follow command:

```
make serve
```

This will run a docker container with Jekyll to host the website locally. 

```
---> Preparing to host documentation site locally
---> This might take a few seconds...
---> If the site was not built with 'make build', this will take a bit longer...
...
 Auto-regeneration: enabled for '/srv/jekyll'
    Server address: http://0.0.0.0:8088/
  Server running... press ctrl-c to stop.

```

Running it with Jekyll offers hot-reloading and any modifications to local files 
(e.g. '.md' documents will automatically rebuild the website and changes will show in the browser)

Navigate to `http://0.0.0.0:8088` to see the website in your local browser.

> **Note**: the `make build` and `make serve` assumes you have [Docker](https://www.docker.com/) properly installed in your machine.

## Checking for broken links

If you want to check for any broken links locally on the documentation site, 
you can run the `make check-broken-links` command. This will go through all 
the pages a look for links that return a `404` error.

This command leverages a tool called [muffet](https://github.com/raviqqe/muffet). 
This tool will be installed if you don't have it yet 
(this assumes you have `Golang` properly installed in your machine)

> **NOTE**: Before you run the command to check for broken links, 
> open a terminal window and run `make serve` first. 
> This will run the website locally as per instructions above

Open another terminal window and run:
```
make check-broken-links
```

This will go through each release and check the links, for example:
```
---> Checking for broken link on the pages...
---> Installing "muffet" tool to check links if not already installed...
------> Checking broken links for release main
------> Saved broken links for release main in broken_links_main.txt
------> Checking broken links for release v0.37-rc2
------> Saved broken links for release v0.37-rc2 in broken_links_v0.37-rc2.txt
------> Checking broken links for release v0.34
------> Saved broken links for release v0.34 in broken_links_v0.34.txt
```

Once the command finishes, you can see the broken links information for each release 
will be stored in the `broken_links_[version].txt` generated files.

> **NOTE**: Every time you run this command, the files `broken_links_[version].txt` 
> will be removed before the command runs

## Troubleshooting

### Unauthorized error in Docker
If you run the `make build` or `make serve` command and get a message like the one below:

```
Error response from daemon: Head "https://registry-1.docker.io/v2/jekyll/builder/manifests/latest": 
unauthorized: please use personal access token to login
```

Please ensure you [login in Docker using your Personal Access Token](https://docs.docker.com/docker-hub/access-tokens/)