# CoDuels

This repository is the revision-tracking superproject for the CoDuels platform.

- `Docs/` contains architecture documentation, slides, and the thesis.
- `Backend/` is the `CoDuels-Backend` submodule.
- `Frontend/` is the `CoDuels-Frontend` submodule.

Develop application code through pull requests in the component repositories. Backend and Frontend validate, build, and deploy applicable pull-request revisions from their own workflows without a GitHub Environment approval. Task storage deploys from its own repository on pushes to `master`. Updating a Backend or Frontend submodule revision here records the version tracked by the superproject and does not deploy it.

## Release images

The root repository releases the exact Backend and Frontend revisions tracked by `master`. Run the `Release images` workflow manually from the `master` branch and enter a semantic version such as `1.0.0`. The workflow passes that version to the existing Ansible build playbooks, pushes these images to Docker Hub, then creates the corresponding `v<version>` tag and GitHub Release:

- `divancode74/coduels-frontend:<version>`
- `divancode74/coduels-duely:<version>`
- `divancode74/coduels-duely-migration:<version>`
- `divancode74/coduels-taski:<version>`
- `divancode74/coduels-exesh:<version>`
- `divancode74/coduels-exesh-dashboard:<version>`
- `divancode74/coduels-analyzer:<version>`

The workflow requires the root repository secret `DOCKER_PASSWORD`. It publishes images and release metadata but does not deploy any service. Frontend receives `VITE_BASE_URL` when its container starts, so the value is not embedded during the image build.

Clone with submodules:

```bash
git clone --recurse-submodules https://github.com/DIvanCode/CoDuels.git
```

For an existing clone:

```bash
git submodule update --init --recursive
```
