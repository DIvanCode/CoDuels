---
name: coduels-delivery
description: Review or change CoDuels GitHub Actions, Docker image builds, Ansible build/deploy playbooks, inventories, vault usage, Nginx/Alloy delivery, task storage deployment, and CI verification. Use for .github workflows, CI failures, deployment configuration, image tagging, GitHub secrets/variables, production rollout design, or documenting the current Ansible pipelines.
---

# Maintain CoDuels delivery

## Read the delivery map

Read [references/pipeline-map.md](references/pipeline-map.md) before changing any workflow, playbook, inventory, Docker image, or deployment variable.

## Separate review from mutation

- Inspect workflows, Dockerfiles, playbooks, and encrypted-variable headers freely.
- Do not decrypt vault files, expose secrets, log credentials, push images, connect to inventory hosts, or run deploy playbooks unless the user explicitly authorizes that external action.
- A push to an open same-repository Backend or Frontend pull request can start an automatic production deployment. Do not push such a branch unless the user authorized the push and its deployment effect.
- Treat a request to review or explain CI as read-only. Do not fix or rerun CI unless requested.

## Change a pipeline coherently

1. Identify the workflow owner. `Backend` owns component pull-request validation and deployment, `Frontend` owns its pull-request validation and deployment, and `Backend/Taski/tasks` owns its push-to-`master` deployment. Root `CoDuels` and `Backend/filestorage` have no production workflows.
2. Trace trigger/path filters -> test/build job -> Docker tag -> Ansible variables -> container environment and ports.
3. Keep the immutable image tag based on `github.sha` unless the release strategy is explicitly changed.
4. Update workflow secret/variable references and playbook variables together. Never place secret values in YAML.
5. Preserve vault encryption for backend service credentials and `no_log` on rendered secret-bearing templates.
6. Keep validation, build, and deploy dependencies explicit. A deploy must not run when validation or the image build failed.
7. Add least-privilege `permissions`, environments, concurrency, or approvals deliberately; explain rollout effects.

## Keep cross-service e2e gates coherent

- Give each e2e scenario one local entry point and one owning pull-request workflow so a multi-service change does not start duplicate copies.
- Include every participating service, the scenario directory, the workflow itself, and related config/infrastructure paths in the workflow filters.
- Initialize required submodules recursively, use least-privilege permissions and a bounded timeout, and invoke the same command developers run locally.
- When adding a scenario, update `Backend/e2e/README.md`, the scenario README, agent verification guidance, and the delivery map together.

## Verify safely

- Parse changed YAML and run `ansible-playbook --syntax-check` where it does not require unavailable vault material.
- Use `--check` only for playbooks/modules that support it and only against a non-production or explicitly approved inventory.
- Validate Docker builds only when dependencies/network and time budget allow; do not push.
- Match CI commands locally: .NET tests, Go tests, Frontend build/lint, Analyzer training/checks.
- Review logs for accidental secret expansion and ensure temporary key/password files are removed under `if: always()`.

## Report

Summarize triggers, jobs, images, target component, required secrets/variables, and validation gaps. Call out operational risks as findings, but do not silently redesign delivery during an unrelated feature task.
