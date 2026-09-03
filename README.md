# ARM64 CI Build Farm

[![CI](https://github.com/REPLACE_ME/arm64-ci-build-farm/actions/workflows/ci.yml/badge.svg)](https://github.com/REPLACE_ME/arm64-ci-build-farm/actions/workflows/ci.yml)

A portfolio-grade reference platform for building, testing, securing, and releasing software for both AMD64 and ARM64. It combines multi-architecture GitHub Actions pipelines with autoscaled Kubernetes runners, artifact attestations, an SBOM, security scanning, caching, and operational alerts.

The included `build-info` service makes architecture visible at runtime through `/info`, proving that the same release runs on both architectures.

## What this demonstrates

- Cross-compilation for `linux/amd64` and `linux/arm64`
- Multi-platform OCI images with Docker Buildx and QEMU
- Autoscaled native ARM64 GitHub runners on Kubernetes
- GitHub Actions cache reuse and concurrency control
- Least-privilege workflow permissions
- Trivy scanning, BuildKit SBOMs, and GitHub provenance attestations
- Kubernetes health probes and restricted container privileges
- Prometheus alerts and an incident runbook

## Pipeline

```mermaid
flowchart LR
    Commit --> Test[Test and vet]
    Test --> Matrix[amd64 and arm64 builds]
    Matrix --> Scan[Trivy scan]
    Scan --> Image[Multi-arch OCI image]
    Image --> SBOM[SBOM and provenance]
    SBOM --> GHCR[GitHub Container Registry]
```

See [the architecture notes](docs/architecture.md) for the runner control plane and trade-offs.

## Quick start

Prerequisites: Git, Go 1.23+, and Docker with Buildx.

```powershell
powershell -ExecutionPolicy Bypass -File ./scripts/preflight.ps1
go test ./...
powershell -ExecutionPolicy Bypass -File ./scripts/build-all.ps1 -Version 0.1.0
docker buildx build --platform linux/amd64,linux/arm64 -t build-info:dev .
```

Run the native container and inspect it:

```powershell
docker build -t build-info:dev .
docker run --rm -p 8080:8080 build-info:dev
Invoke-RestMethod http://localhost:8080/info
```

## Repository map

| Path | Purpose |
|---|---|
| `.github/workflows/ci.yml` | PR validation, binary matrix, OCI build, and security scan |
| `.github/workflows/release.yml` | Signed multi-architecture releases to GHCR |
| `cmd/build-info` | Small Go workload used to prove the pipeline |
| `infra/runner-scale-set` | ARM64 Actions Runner Controller scale-set values |
| `deploy/helm` | Hardened Kubernetes deployment of the workload |
| `monitoring` | Example runner SLO alerts |
| `docs` | Architecture decisions and operational response |

## Deploy ARM64 runners

The values file targets the official Actions Runner Controller scale-set chart. Replace `REPLACE_ME`, create the `github-runner-secret` by an approved secret-management process, and install the chart into a Kubernetes cluster containing ARM64 nodes.

```bash
helm install arm64-builders \
  --namespace arc-runners --create-namespace \
  -f infra/runner-scale-set/values.yaml \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
```

Never expose self-hosted runners to arbitrary forked pull requests. See [SECURITY.md](SECURITY.md) before connecting a runner to a real organization.

## Release

Push a semantic-version tag such as `v0.1.0`. The release workflow publishes an AMD64/ARM64 manifest to GHCR and attaches an SBOM and build-provenance attestation. Replace all `REPLACE_ME` placeholders before publishing.

## Interview discussion points

- Why native ARM64 execution catches issues that cross-compilation alone cannot
- When QEMU is appropriate and when it distorts performance measurements
- How ephemeral runners reduce persistence and credential-exposure risks
- The cost/latency trade-off of scaling runners to zero
- How SBOMs, immutable digests, and provenance protect the software supply chain
- How cache keys and isolated node pools affect speed, cost, and security

## Roadmap

- Terraform modules for an ARM64 Kubernetes node pool
- Grafana dashboard backed by the Actions Runner Controller metrics
- Queue-to-start SLO measurement and benchmark report
- Failure injection for runner eviction and registry outages
