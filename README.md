# CoDuels

This repository is the revision-tracking superproject for the CoDuels platform.

- `Docs/` contains architecture documentation, slides, and the thesis.
- `Backend/` is the `CoDuels-Backend` submodule.
- `Frontend/` is the `CoDuels-Frontend` submodule.

Develop application code through pull requests in the component repositories. Backend and Frontend validate, build, and deploy applicable pull-request revisions from their own workflows without a GitHub Environment approval. Task storage deploys from its own repository on pushes to `master`. Updating a Backend or Frontend submodule revision here records the version tracked by the superproject and does not deploy it.

## Release images

The root repository packages the exact Backend and Frontend revisions tracked by a release commit. Change [`VERSION`](VERSION) to a new semantic version in a pull request. When that change reaches `master`, the `Release images` workflow creates a `v<version>` GitHub Release with these compressed Docker image archives and a `SHA256SUMS` file:

- `divancode74-coduels-frontend:<version>`
- `divancode74-coduels-duely:<version>`
- `divancode74-coduels-duely-migration:<version>`
- `divancode74-coduels-taski:<version>`
- `divancode74-coduels-exesh-coordinator:<version>`
- `divancode74-coduels-exesh-worker:<version>`
- `divancode74-coduels-analyzer:<version>`

Load an archive locally with:

```bash
gzip -dc divancode74-coduels-taski-1.0.0.tar.gz | docker load
```

The release workflow does not push the images to a registry or deploy them. The Frontend image uses the root repository variable `VITE_BASE_URL` when it is configured and defaults to `/api` otherwise.

Clone with submodules:

```bash
git clone --recurse-submodules https://github.com/DIvanCode/CoDuels.git
```

For an existing clone:

```bash
git submodule update --init --recursive
```
