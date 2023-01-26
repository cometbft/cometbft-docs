# CometBFT Documentation

This repository contains the logic to build the CometBFT documentation site (docs.cometbft.com)

It uses [Jekyll](https://jekyllrb.com/) framework to the site structure and templating.

The technical content for the documentation is retrieved from the [CometBFT](https://github.com/cometbft/cometbft) repository, more specifically the `/docs` and `/spec` folders.

## Building the site

In order to build the website locally, please run the following command:

```
make build-docs
```

If everything runs correctly, a new folder will be created `_site`. This folder contains the website files built by Jekyll.

### Running the site locally

If you want to run the site locally you can run the follow command:

```
make serve-docs 
```

This will run a local http server (based on Golang):

```
Running documentation site at http://localhost:8088
```

Navigate to `http://localhost:8088` to see the website in your local browser.