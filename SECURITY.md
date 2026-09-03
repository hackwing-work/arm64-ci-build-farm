# Security policy

Report vulnerabilities privately through GitHub Security Advisories. Do not open a public issue containing credentials, exploit details, or runner registration tokens.

The release workflow uses GitHub OIDC for keyless provenance attestations, generates an SBOM through BuildKit, scans the source tree with Trivy, and grants each workflow only the permissions it requires. Runner credentials must be supplied as a Kubernetes Secret and must never be committed.

Self-hosted runners execute untrusted code. In production, use ephemeral runners, isolate runner nodes from internal networks, restrict pull requests from forks, enforce egress controls, and rebuild the runner environment after every job.

