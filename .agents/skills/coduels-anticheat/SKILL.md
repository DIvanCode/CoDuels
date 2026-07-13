---
name: coduels-anticheat
description: Maintain the CoDuels behavior-analysis pipeline from Monaco/Frontend action capture through Duely validation, EF persistence, background scoring, Analyzer Pydantic schemas, feature extraction, scikit-learn training, inference artifacts, and suspicion scores. Use for new action types or fields, batching, data cleanup, features, datasets, model selection, metrics, Analyzer API, and anti-cheat debugging.
---

# Maintain CoDuels anti-cheat

## Load the contract

Read [references/anticheat-contract.md](references/anticheat-contract.md) before editing any action type, feature, model, or scoring workflow.

## Change end to end

1. Identify whether the change affects capture, transport, persistence, scoring orchestration, feature extraction, training, or inference.
2. For an action contract change, update Frontend TypeScript, Duely polymorphic models/validation/EF mapping, the Duely Analyzer request, and Analyzer's discriminated Pydantic union together.
3. Add an EF migration when persisted shape or discriminator mapping changes.
4. For a feature change, update extraction and `FEATURE_NAMES` in the same patch. Preserve deterministic order because model columns depend on it.
5. Retrain both baseline and production models whenever the feature schema/order, extraction semantics, training code, or dataset changes.
6. Keep the score probabilistic. Do not turn it into proof of cheating or an automatic punitive decision without an explicit product requirement.

## Preserve data invariants

- Keep `event_id` unique, `sequence_id` positive and ordered per duel/user stream, timestamps valid, and `task_key` present.
- Reject attempts to submit actions for another authenticated user.
- Score actions per `(duel, user, task_key)` using the user's rating at duel start.
- Do not score unfinished duel action streams.
- Make cleanup behavior explicit; production may remove actions after a score is stored.
- Keep queue/batch behavior robust to page hide and reconnect. Do not silently clear unsent events on a failed request without addressing the loss semantics.

## Verify

1. Run Frontend lint, FSD lint, and build for capture/type changes.
2. Run Duely tests for validation, persistence, background scoring, or gateway changes.
3. Syntax-check and exercise Analyzer extraction for representative normal, paste-heavy, and sparse streams.
4. Run `python train.py --data-dir data/train` for feature/training/data changes and review both validation metric files.
5. Start the Analyzer only after model artifacts exist; smoke-test `/health` and `/predict` with a contract-valid payload.
6. Do not commit generated model artifacts unless the user explicitly changes the artifact policy.
