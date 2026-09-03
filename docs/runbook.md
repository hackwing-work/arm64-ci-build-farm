# Operations runbook

## Queue is growing

1. Confirm the runner scale set listener is connected.
2. Compare pending runner pods with available ARM64 node capacity.
3. Inspect scheduling events for architecture selectors, taints, quota, or image-pull failures.
4. Increase `maxRunners` only after confirming node capacity and budget.

## Builds are slow

1. Compare checkout, dependency, compilation, and image-export durations separately.
2. Verify BuildKit and Go cache hits.
3. Check whether an ARM64 job unexpectedly uses QEMU emulation.
4. Review CPU throttling and memory pressure on runner pods.

## Suspected runner compromise

1. Disable the affected runner scale set.
2. Revoke GitHub runner credentials and rotate accessible secrets.
3. Quarantine the runner node and preserve audit logs.
4. Rebuild the node from a trusted image; do not reuse its workspace.
5. Review workflow permission scopes and artifact provenance.

