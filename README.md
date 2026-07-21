# CoDuels

This repository is the revision-tracking superproject for the CoDuels platform.

- `Docs/` contains architecture documentation, slides, and the thesis.
- `Backend/` is the `CoDuels-Backend` submodule.
- `Frontend/` is the `CoDuels-Frontend` submodule.

Develop application code through pull requests in the component repositories. Backend and Frontend validate, build, and deploy applicable pull-request revisions from their own workflows without a GitHub Environment approval. Task storage deploys from its own repository on pushes to `master`. This root repository has no GitHub Actions workflows; updating a Backend or Frontend submodule revision here only records the version tracked by the superproject and does not deploy it.

Clone with submodules:

```bash
git clone --recurse-submodules https://github.com/DIvanCode/CoDuels.git
```

For an existing clone:

```bash
git submodule update --init --recursive
```
