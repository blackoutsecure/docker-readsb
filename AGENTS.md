# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## What this is

`docker-readsb` packages [`readsb`](https://github.com/wiedehopf/readsb), an ADS-B (1090 MHz Mode S)
decoder, as a LinuxServer.io-style container image. The build shallow-clones
`https://github.com/wiedehopf/readsb` at branch `dev` (`READSB_REPO_URL` / `READSB_REPO_BRANCH` build
args), so the image tracks upstream HEAD rather than a tagged release. The observed upstream state is
recorded in [.github/upstream/readsb-dev.json](.github/upstream/readsb-dev.json) — version `3.16.15`,
commit `0adaebb8d49988fb8e2db5dc835daf7e95aea496` — but that file is metadata only and does not feed the
build, so two builds of the same Dockerfile can contain different `readsb` code.

The base image is `ghcr.io/linuxserver/baseimage-alpine:3.22`, pinned by tag (not digest) via the
`BASE_IMAGE_REGISTRY` / `BASE_IMAGE_NAME` / `BASE_IMAGE_VARIANT` build args. Supported architectures are
`linux/amd64` and `linux/arm64`; on `x86_64` the build adds `-march=nehalem`.

At runtime the container supervises `readsb` under s6-overlay. It decodes ADS-B from a local RTL-SDR
dongle passed in at `/dev/bus/usb` or purely over the network, writes JSON aircraft state to
`/run/readsb` every second, exposes Beast / raw / SBS / JSON TCP ports, and optionally forwards Beast
data to aggregators via `--net-connector` feed profiles. Consumers pull `blackoutsecure/readsb` from
Docker Hub or deploy the [Balena block](https://hub.balena.io/blocks/2351129/readsb). The bundled
`docker-compose.yml` pairs it with `blackoutsecure/mlat-client`, sharing `/config` so both containers use
the same feeder UUID.

## Commands

```bash
# Build for the host architecture with the real build args
docker build -t blackoutsecure/readsb:dev \
  --build-arg BASE_IMAGE_VARIANT=3.22 \
  --build-arg READSB_REPO_URL=https://github.com/wiedehopf/readsb \
  --build-arg READSB_REPO_BRANCH=dev \
  .

# Multi-arch build (needs a buildx builder with QEMU)
docker buildx build --platform linux/amd64,linux/arm64 -t blackoutsecure/readsb:dev .

# Run the reference stack (readsb + mlat-client sidecar)
docker compose up -d && docker compose logs -f readsb
docker compose down

# Shell in, and inspect live output
docker exec -it readsb bash
docker exec readsb cat /run/readsb/aircraft.json | jq '.aircraft | length'
docker inspect --format='{{.State.Health.Status}}' readsb

# Lint the overlay scripts (.shellcheckrc sets shell=bash, external-sources=true)
shellcheck root/etc/s6-overlay/s6-rc.d/*/run root/usr/local/bin/*.sh
bash -n root/etc/s6-overlay/s6-rc.d/*/run root/usr/local/bin/*.sh

# Compile-check the USB helper the way the builder stage does (Linux only)
gcc -O2 -s -o /tmp/usb-reset src/usb-reset.c
```

## Validating changes

CI here is exactly one workflow,
[.github/workflows/upstream-monitor.yml](.github/workflows/upstream-monitor.yml). It does not build,
test, lint, or publish, and there is no `hadolint` step here or in any hub workflow. No
`bos-universal-security.yml` caller and no managed kicker workflow exists on `dev` — the branch
`origin/chore/seed-bos-universal-gatekeeper-kicker` has not landed. Local validation is the only gate.

Narrowest first: `bash -n` on the one script you touched, then `shellcheck` over `root/`, then a local
`docker build`, then `docker compose up -d` and read the startup log. Confirm the
`svc-readsb[info]: readsb container startup configuration` block lists the `effective_ARGS` you expect —
that rendered argument line is the best signal that env-var handling is correct.

A successful build proves only that `readsb` compiled and the overlay copied. It proves nothing about
decoding real ADS-B traffic. Without SDR hardware you can still exercise most of the container: leave
`READSB_DEVICE_TYPE` unset so `readsb` starts network-only while the whole init path (UUID generation,
geolocation, connector assembly, port waiting) runs unchanged; set `READSB_NET_BI_PORT=30004,30104` and
push Beast data in from a remote receiver, or set `FEED_UAT_INPUT=host:port` to pull from a `dump978`
sidecar, so `aircraft.json` populates and the `HEALTHCHECK` passes; or run with no input at all, where
`readsb` still writes an empty `aircraft.json` and the `HEALTHCHECK`, `svc-feed-stats` summaries, and
low-reception warning path stay observable. Nothing here replays a captured sample feed and there is no
self-test binary — decoder correctness is upstream's concern. DVB module unbinding, `rtl_biast`,
`rtl_eeprom` enumeration, and USB permission fixing cannot be validated without a real dongle on a Linux
host; say so rather than implying coverage.

## Architecture

```text
Dockerfile                                 Two-stage build: builder + runtime
docker-compose.yml                         Reference stack: readsb + mlat-client sidecar
readme-vars.yml                            LinuxServer.io-style metadata (env vars, arches)
README.md                                  Hand-maintained user documentation
src/usb-reset.c                            USBDEVFS_RESET helper compiled in the builder stage
root/                                      Container filesystem overlay, copied to /
root/etc/s6-overlay/s6-rc.d/               s6-rc service definitions
root/usr/local/bin/                        Shared bash libraries sourced by the s6 scripts
.github/workflows/upstream-monitor.yml     Only workflow: upstream drift detection
.github/upstream/readsb-dev.json           Tracked upstream version/commit metadata
.github/dependabot.yml                     Weekly github-actions and docker ecosystem updates
.dockerignore                              Build-context excludes; has hub-managed blocks
.editorconfig / .gitattributes             Contain hub-managed marker blocks
.shellcheckrc / .markdownlint.yaml         Lint config; no managed blocks
```

### Image build

Stage `builder` installs `build-base`, `git`, `librtlsdr-dev`, `ncurses-dev`, `zlib-dev`, `zstd-dev` and
friends, clones `readsb` at `${READSB_REPO_BRANCH}` with `--depth 1`, captures `BUILD_DATE` / `VERSION` /
`VCS_REF` / `VCS_URL` into `/tmp/readsb-build-metadata.env`, then deletes `.git`. It compiles twice: with
`RTLSDR=yes` producing `readsb` and `viewadsb`, and with `PRINT_UUIDS=yes TRACKS_UUID=yes` producing
`readsb-uuid` and `viewadsb-uuid`. Binaries are stripped into `${BUILD_OUTPUT_DIR}` (`/out`), `usb-reset`
is compiled from `src/usb-reset.c`, and the tar1090 aircraft database is fetched from `${TAR1090_DB_URL}`.
The runtime stage installs runtime packages only (`librtlsdr`, `rtl-sdr`, `jemalloc`, `curl`, `jq`,
`kmod`, `procps`, `psmisc`, `usbutils`, `zstd`), copies `/out/usr/local/` and `root/`, preloads jemalloc
via `LD_PRELOAD` with `MALLOC_CONF=narenas:1,tcache:false`, writes `/build_version`, chmods every s6
`run`/`finish`/`check` to `0755`, removes the base image's `svc-cron` and `init-crontab-config` links,
and declares `EXPOSE 30001 30002 30003 30004 30005 30104`, `VOLUME ["/config"]`, and a `HEALTHCHECK`
that fails unless `/run/readsb/aircraft.json` was modified within the last minute. The version pin lives
only in the `READSB_REPO_BRANCH` build arg.

### Container filesystem overlay

`root/` is copied to `/`. s6-overlay v3 `s6-rc` definitions live under `root/etc/s6-overlay/s6-rc.d/`,
with `user/contents.d/` holding one empty marker file per service to enable it in the user bundle.

- `init-readsb-config/` — `oneshot`, `up` points at its own `run`, depends on `init-services`.
- `init-readsb-config/run` — defaults `PUID`/`PGID` to `911` for `abc`, creates `/config/readsb`,
  `globe_history`, and `${READSB_RUN_DIR}`, generates or imports a per-profile UUID into
  `/config/feed-uuid-<profile>`, writes resolved values into `/run/s6/container_environment`, resolves
  receiver location (`FEED_LAT`/`FEED_LON`, else IP geolocation via `ip-api.com`), pre-unbinds DVB
  drivers, enumerates SDR dongles, and chmods matching `/dev/bus/usb` nodes to `0666`.
- `svc-readsb/` — `longrun`, depends on `init-readsb-config` and `init-services`.
- `svc-readsb/run` — the main service. Applies a restart backoff from `/run/readsb-fail-count`, assembles
  the `readsb` argument vector from environment variables (never overriding a flag already supplied via
  `READSB_EXTRA_ARGS`), does DVB unbind plus `rmmod` plus an `rtl_eeprom` re-init, optionally enables
  bias-T, kills stale `readsb` processes, waits for listening ports to free, logs a key/value startup
  dump, and `exec`s `readsb` through the awk log prefixer.
- `svc-feed-stats/` — `longrun`, depends on `svc-readsb`.
- `svc-feed-stats/run` — watches `aircraft.json` freshness, resets the crash-loop counter, logs an
  aircraft/message summary every `STATS_LOG_INTERVAL`, uploads UUID-tagged gzipped RSSI stats to
  `https://adsbexchange.com/api/receive/` when the `adsbexchange` profile is active, and emits a
  troubleshooting checklist after sustained zero reception.
- `root/usr/local/bin/log-functions.sh` — hub-managed shared logger, sourced not executed. Provides
  `log_info`/`log_warn`/`log_error`/`log_fatal`/`log_debug`, a generic `log`, `log_kv`, `log_pipe_cmd`.
- `root/usr/local/bin/feed-profiles.sh` — sourced. Maps profile names to `--net-connector` strings,
  failover endpoints, MLAT servers, status URLs, and UUID file paths.
- `root/usr/local/bin/sdr-enumerate.sh` — sourced. Detects dongles via `lsusb` on `0bda:2832`/`0bda:2838`,
  reads serials with `rtl_eeprom` or `rtl_test`, and treats a serial containing `978` or `uat` as a UAT
  dongle that `readsb` must not claim.

### Runtime configuration

Identity and logging: `TZ` (`Etc/UTC`), `PUID`/`PGID` (`911` when `READSB_USER=abc`), `READSB_USER`
(`abc`), `READSB_RUN_DIR` (`/run/readsb`), `TAR1090_DB_PATH`
(`/usr/local/share/tar1090/aircraft.csv.gz`), `LOG_LEVEL` (`info`). Decoder and networking: `READSB_NET`
(`true`), `READSB_DEVICE_TYPE` (unset, meaning network-only), `READSB_NET_BI_PORT` and
`READSB_NET_BO_PORT` (unset; Beast input and output ports), `READSB_EXTRA_ARGS` (unset, appended last).

SDR and gain: `READSB_DEVICE` (unset; index or serial), `READSB_AUTOGAIN` (`true`, maps to `--gain auto`),
`READSB_GAIN` (unset, overrides autogain), `READSB_BIASTEE` (`false`). Location: `FEED_LAT`, `FEED_LON`
(unset), `READSB_AUTO_LOCATION` (`true`). Feeding and stats: `FEED_PROFILES` (`adsbexchange`),
`FEED_UUID_<PROFILE>` (auto-generated), `FEED_UAT_INPUT` (unset), `FEED_STATS_ENABLED` (`true`),
`STATS_LOG_INTERVAL` (`120`), `ADSBX_UPLOAD_INTERVAL` (`5`).

With feed profiles active, `svc-readsb` also applies overridable defaults: `--net-beast-reduce-interval
0.5`, `--net-heartbeat 60`, `--net-ro-size 1280`, `--net-ro-interval 0.2`, `--json-location-accuracy 2`,
`--range-outline-hours 24`, `--max-range 450`, `--write-json-every 1`, and `--quiet` unless `--debug`.

### Upstream tracking

`upstream-monitor.yml` runs on a `7 */6 * * *` schedule and on `workflow_dispatch` (with a `force`
boolean). It reads `VERSION` (falling back to `version`) from
`raw.githubusercontent.com/wiedehopf/readsb/dev`, resolves the `refs/heads/dev` commit with
`git ls-remote`, builds a JSON object with `jq`, and compares it against
`.github/upstream/readsb-dev.json`. On drift it creates branch
`upstream/readsb-dev/<version>-<short-sha>`, commits `chore(ci): track readsb dev <version> (<short>)`,
and opens a labelled `upstream-bump` PR against the default branch with a reviewer checklist. It
explicitly does not publish images, cut releases, or push to `main`. It does not use
`bos-upstream-watcher`; the logic is hand-rolled, unlike the hub's `monitor-upstream-release.yml`, which
pins `blackoutsecure/bos-upstream-watcher`.

The drift comparison at line 91 is `if [ -f "${TRACK_FILE}" ] && cmp -s "${TRACK_FILE}" ...; then`.
It previously read `[ -f "${TRACK_FILE}" && cmp -s ...` — an unterminated `[` test that could never
succeed, so every run reported `DRIFT DETECTED` and leaned on the "branch already exists" and "no
staged changes" guards to avoid duplicate PRs. Keep the two tests separate. Bumping the pin means
editing `READSB_REPO_BRANCH` in the `Dockerfile` (or building from a tag or commit), not editing the
tracking JSON — that file only records what upstream currently is.

### Publishing

There is no build or publish workflow in this repository and no caller of the hub's reusable workflows on
`dev`. Publishing is driven from `blackoutsecure/bos-automation-hub`, whose `release.yml` composes three
reusable stages: `docker-build-push.yml` (multi-arch `linux/amd64` + `linux/arm64` build, per-arch digest
artifacts, a merged manifest, Docker Scout CVE scanning, and a Docker Hub description sync),
`balena-block-publish.yml`, and `github-release.yml`. Its registry input defaults to `docker.io`, where
`blackoutsecure/readsb` lives; the Balena stage publishes the block at
`hub.balena.io/blocks/2351129/readsb`. A caller added here must pass `image_name` and
`dockerhub_namespace`; the hub supplies `DOCKERHUB_USERNAME` and the matching secret. The hub's
`openwrt-readsb-wiedehopf-bump.yml` is unrelated — it opens PRs against `openwrt/packages` to bump
`utils/readsb-wiedehopf/Makefile`, and its schedule is commented out.

## Conventions

Every s6 `run` script starts with `#!/usr/bin/with-contenv bash` so the s6 container environment is in
scope, then `set -euo pipefail`, then sets `SVC_NAME` and sources the shared logger. Shared libraries
under `root/usr/local/bin/` use `#!/usr/bin/env bash`, are sourced rather than executed, and say so in
their header. Sourced files carry a `# shellcheck source=/usr/local/bin/...` directive so
`external-sources=true` resolves them. Local scratch variables are prefixed with an underscore, and
section headers use a `# ── Title ───` rule. Comments explain why a workaround exists — the long blocks
about DVB module state, `USBDEVFS_RESET` on `dwc_otg`, and port `TIME_WAIT` handling are load-bearing
history, so do not strip them.

```bash
#!/usr/bin/with-contenv bash
set -euo pipefail

SVC_NAME="svc-readsb"
# shellcheck source=/usr/local/bin/log-functions.sh
. /usr/local/bin/log-functions.sh
```

Dockerfile conventions: `# syntax=docker/dockerfile:1.7` on line one, tunables declared as `ARG` at the
top and re-declared inside each stage that needs them, `SHELL ["/bin/bash", "-o", "pipefail", "-c"]`
before any piped `RUN`, `apk add --no-cache` with one alphabetised package per line, build tooling
confined to the `builder` stage, `COPY --link` for the artifact and overlay copies, and a final
`rm -rf /tmp/* /var/tmp/* /var/cache/apk/*` in the same layer as the metadata and service-pruning work.

## Blackout Secure conventions

These apply to every repository in the `blackoutsecure` organization.

### Branch model

- `main` is the default and only long-lived branch.
- Create short-lived feature branches from `main` and land changes through pull requests.
  Preserve required checks and reviews; a permanent `dev` branch is not needed.
- Keep existing version tags and configured release automation. Do not push directly to
  `main` or move tags by hand.

### Centrally managed files - do not hand-edit here

`blackoutsecure/bos-automation-hub` distributes these through
`bos-managed-file-sync-action`. Change the source under the hub's `sync-files/`, never the
copy in this repository:

- `LICENSE`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md`
- `.github/FUNDING.yml`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/`
- any managed kicker workflow under `.github/workflows/`
- the managed-file-sync delimited blocks inside `.editorconfig`, `.markdownlint.yaml`,
  `.shellcheckrc`, `.yamllint.yml`, `.gitignore`, and `README.md`

Corrections for this repository. Of those community-health files only `LICENSE` exists, and it is a
repo-specific GPL-3.0-or-later notice for this packaging rather than a synced copy; the rest are absent,
as is any managed kicker workflow. The on-disk marker namespace is `bos-automation-hub:<service>`, not
`managed-file-sync:<service>`, and blocks exist only in `.dockerignore` (`docker`, `balena`),
`.editorconfig` (`common`), and `.gitattributes` (`lf_line_endings`). `.markdownlint.yaml`,
`.shellcheckrc`, `.gitignore`, and `README.md` carry no managed blocks, and there is no `.yamllint.yml`.
`root/usr/local/bin/log-functions.sh` is managed despite having no marker block — its header says so and
points at the hub's `logger` service.

### CI gate

Pushes and pull requests run the hub's reusable `bos-universal-security.yml`, reported as a
single required check. It runs markdownlint, yamllint, shellcheck, and actionlint;
`bos-code-scanning-kit` (secret scan, SAST, GHAS posture) and CodeQL; dependency review;
and compliance checks for the canonical README header and a conventional-commit PR title
(`feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert: subject`).

Every `uses:` reference in a workflow must be a commit SHA with a trailing version comment,
for example `actions/checkout@<sha> # v4.2.2`.

Correction for this repository: that gate is not wired up here yet. The only workflow present is the
repo-owned `upstream-monitor.yml`. It does pin its single `uses:` reference correctly
(`actions/checkout@08c6903cd8c0fde910a37f88322edcfb5dd907a8 # v5.0.0`), and any workflow added here must
do the same.

## Boundaries

### Always

- Run `bash -n` and `shellcheck` over every script you touch in `root/`, then build the image locally.
- Guard every new `readsb` flag with `has_readsb_opt` so a user-supplied `READSB_EXTRA_ARGS` value wins.
- Route script output through the shared logger with the correct `SVC_NAME`; never `echo` to stdout
  directly from an s6 `run` script.
- Update `README.md` and `readme-vars.yml` together when an environment variable, port, or default
  changes. `README.md` is hand-maintained, not generated from `readme-vars.yml`, so the two drift silently.
- Persist any value a downstream service needs to `/run/s6/container_environment/<NAME>` from
  `init-readsb-config`.
- Keep new packages minimal and keep build tooling out of the runtime stage.

### Ask first

- Bumping the upstream `readsb` pin: changing `READSB_REPO_BRANCH`, or moving from branch tracking to a
  tag or commit pin.
- Changing the base image — registry, name, or the `3.22` variant — or pinning it to a digest.
- Renaming an environment variable or changing a default. Every one is documented in `README.md` and
  `readme-vars.yml` and set in real deployments; a rename silently reverts a user's configuration.
- Changing the exposed port set, the `HEALTHCHECK`, the `/config` and `/run/readsb` volume paths, or the
  UUID file naming that `mlat-client` sidecars read.
- Adding, removing, or reordering an s6 service or its `dependencies.d` entries.
- Adding or changing a feed profile endpoint, or any new outbound network call.
- Adding a build, publish, or release workflow to this repository.

### Never

- Never hand-edit `root/usr/local/bin/log-functions.sh` or content inside a
  `bos-automation-hub:<service>` marker block; change the source under the hub's `sync-files/`.
- Never commit secrets, registry credentials, Docker Hub tokens, feeder UUIDs, API keys, or a populated
  `/config` directory.
- Never commit built images, image tarballs, captured `aircraft.json`, Beast or raw captures, or any
  other recorded flight data.
- Never use an unpinned base image or an unpinned `uses:` ref; every action reference is a 40-character
  commit SHA with a trailing version comment.
- Never push directly to `main` or move a version tag by hand.
- Never weaken a guard to make something work: do not drop `set -euo pipefail`, add a blanket
  `shellcheck disable`, remove the stale-process or port-wait checks, or widen container privileges
  beyond what `docker-compose.yml` already documents and justifies.
