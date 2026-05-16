# Security Policy

## Supported Versions

This image follows [semantic versioning](https://semver.org/). Security fixes are issued against the **latest released image only**. Older tags are kept for reproducibility but receive no patches.

| Tag | Supported |
| --- | --- |
| `latest` | ✅ |
| Most recent `vX.Y.Z` release | ✅ |
| Older versioned tags | ❌ |

The upstream [`wiedehopf/readsb`](https://github.com/wiedehopf/readsb) project maintains its own security posture for the decoder itself; this repository is responsible for the **container packaging**, **s6 init**, **shell scripts**, and **CI workflows**.

## Reporting a Vulnerability

Please **do not** open a public issue for security vulnerabilities.

Report privately via **[GitHub Security Advisories](https://github.com/blackoutsecure/docker-readsb/security/advisories/new)** ("Report a vulnerability"). This delivers the report to maintainers only and provides a coordinated disclosure workflow.

Include:

- Affected image tag(s) and architecture.
- A minimal reproduction (env vars, compose snippet, command sequence).
- Observed vs. expected behaviour.
- Impact assessment and any proposed mitigation.

We aim to:

- Acknowledge within **3 business days**.
- Provide a remediation plan or disposition within **14 days**.
- Publish a patched image and advisory on resolution.

If your report concerns a vulnerability in the upstream `wiedehopf/readsb` decoder rather than this container's packaging, please **also** notify the upstream project.

## Supply-Chain Hardening

- Builds run via reusable workflows in [`blackoutsecure/bos-automation-hub`](https://github.com/blackoutsecure/bos-automation-hub), which pin upstream actions and run Docker Scout CVE scans (SARIF uploaded to GitHub code scanning) on every build.
- Base image: `ghcr.io/linuxserver/baseimage-alpine` (pinned by tag in [`Dockerfile`](Dockerfile)).
- Multi-arch images are signed via [Docker Hub content tags](https://hub.docker.com/r/blackoutsecure/readsb/tags) and verified by `docker manifest inspect`.

## Contact

For non-security questions use [GitHub Issues](https://github.com/blackoutsecure/docker-readsb/issues) or [Blackout Secure](https://blackoutsecure.app).
