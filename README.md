# CoDuels

This repository is the release superproject for the CoDuels platform.

- `Docs/` contains architecture documentation, slides, and the thesis.
- `Backend/` is the `CoDuels-Backend` submodule.
- `Frontend/` is the `CoDuels-Frontend` submodule.

Develop application code through pull requests in the component repositories. To release a component, update its submodule revision in a pull request to this repository. After that root pull request is merged, its release job waits for a `production` environment approval; start deployment with **Review deployments → Approve and deploy**.

Clone with submodules:

```bash
git clone --recurse-submodules https://github.com/DIvanCode/CoDuels.git
```

For an existing clone:

```bash
git submodule update --init --recursive
```
