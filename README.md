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

### Running the site locally

If you want to run the site locally you can run the follow command:

```
make serve
```

This will run a local HTTP server (based on Golang):

```
Running documentation site at http://localhost:8088
```

Navigate to `http://localhost:8088` to see the website in your local browser.
