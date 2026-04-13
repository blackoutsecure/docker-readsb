<p align="center">
  <img src="https://raw.githubusercontent.com/blackoutsecure/docker-readsb/main/logo.png" alt="readsb logo" width="200">
</p>

# blackoutsecure/readsb

[![GitHub Stars](https://img.shields.io/github/stars/blackoutsecure/docker-readsb?style=flat-square&color=E7931D&logo=github)](https://github.com/blackoutsecure/docker-readsb/stargazers)
[![Docker Pulls](https://img.shields.io/docker/pulls/blackoutsecure/readsb?style=flat-square&color=E7931D&logo=docker&logoColor=FFFFFF)](https://hub.docker.com/r/blackoutsecure/readsb)
[![GitHub Release](https://img.shields.io/github/release/blackoutsecure/docker-readsb.svg?style=flat-square&color=E7931D&logo=github&logoColor=FFFFFF)](https://github.com/blackoutsecure/docker-readsb/releases)
[![Release CI](https://img.shields.io/github/actions/workflow/status/blackoutsecure/docker-readsb/release.yml?style=flat-square&label=release%20ci&color=E7931D)](https://github.com/blackoutsecure/docker-readsb/actions/workflows/release.yml)
[![Publish CI](https://img.shields.io/github/actions/workflow/status/blackoutsecure/docker-readsb/publish.yml?style=flat-square&label=publish%20ci&color=E7931D)](https://github.com/blackoutsecure/docker-readsb/actions/workflows/publish.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg?style=flat-square)](https://www.gnu.org/licenses/gpl-3.0)

Unofficial community image for [readsb](https://github.com/wiedehopf/readsb), built with [LinuxServer.io](https://linuxserver.io/) style container patterns (s6, hardened defaults, practical runtime options) for RTL-SDR ADS-B workloads.

Sponsored and maintained by [Blackout Secure](https://blackoutsecure.app).

> [!IMPORTANT]
> This repository is not an official LinuxServer.io image release.
> Want to help make it an officially supported LinuxServer.io Community image?
> Add your support in [linuxserver/discussions/108](https://github.com/orgs/linuxserver/discussions/108).

## Overview

This project packages upstream [wiedehopf/readsb](https://github.com/wiedehopf/readsb) into an easy-to-run, LinuxServer.io-style container image with practical defaults for ADS-B receivers, JSON/network outputs, and RTL-SDR hardware access.

Quick links:

- Docker Hub listing: [blackoutsecure/readsb](https://hub.docker.com/r/blackoutsecure/readsb)
- Balena block listing: [readsb block on Balena Hub](https://hub.balena.io/blocks/2351129/readsb)
- GitHub repository: [blackoutsecure/docker-readsb](https://github.com/blackoutsecure/docker-readsb)
- Upstream application: [wiedehopf/readsb](https://github.com/wiedehopf/readsb)

[![balena deploy button](https://www.balena.io/deploy.svg)](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/blackoutsecure/docker-readsb&configUrl=https://raw.githubusercontent.com/blackoutsecure/docker-readsb/main/balena.yml)

---

## Table of Contents

- [Quick Start](#quick-start)
- [Image Availability](#image-availability)
- [About The readsb Application](#about-the-readsb-application)
- [Supported Architectures](#supported-architectures)
- [Usage](#usage)
  - [Docker Compose](#docker-compose-recommended-click-here-for-more-info)
  - [Docker Compose (Network-only)](#docker-compose-with-rtl-sdr-over-network-eg-from-a-remote-receiver)
  - [Docker Compose (dump978 Sidecar)](#docker-compose-with-dump978-sidecar-dual-1090978-mhz-us-only)
  - [Docker CLI](#docker-cli-click-here-for-more-info)
  - [Balena Deployment](#balena-deployment)
- [Parameters](#parameters)
- [Configuration](#configuration)
- [Application Setup](#application-setup)
- [SDR Device Selection](#sdr-device-selection)
- [Feed Profiles](#feed-profiles)
- [Automatic Gain Optimization](#automatic-gain-optimization)
- [Bias-T Power for Active Antennas](#bias-t-power-for-active-antennas)
- [Advanced Tuning](#advanced-tuning)
- [Troubleshooting](#troubleshooting)
- [Health Monitoring](#health-monitoring)
- [Release & Versioning](#release--versioning)
- [Support & Getting Help](#support--getting-help)
- [References](#references)

---

## Quick Start

**5-minute RTL-SDR receiver setup:**

```bash
docker run -d \
  --name=readsb \
  --restart unless-stopped \
  -e TZ=Etc/UTC \
  -e READSB_ARGS="--net --device-type rtlsdr" \
  -e READSB_AUTOGAIN=true \
  -p 30001:30001 \
  -p 30002:30002 \
  -p 30003:30003 \
  -p 30004:30004 \
  -p 30005:30005 \
  -p 30104:30104 \
  -v readsb-config:/config \
  -v readsb-json:/run/readsb \
  --device=/dev/bus/usb:/dev/bus/usb \
  --security-opt no-new-privileges:true \
  blackoutsecure/readsb:latest
```

Access live JSON output: `docker exec readsb cat /run/readsb/aircraft.json | jq .`

For compose files, balena, network-only mode, and more examples, see [Usage](#usage) below.

---

## Image Availability

**Docker Hub (Recommended):**

- All images published to [Docker Hub](https://hub.docker.com/r/blackoutsecure/readsb)
- Simple pull command: `docker pull blackoutsecure/readsb:latest`
- Multi-arch support: amd64, arm64
- No registry prefix needed (defaults to Docker Hub)

```bash
# Pull latest
docker pull blackoutsecure/readsb

# Pull specific version
docker pull blackoutsecure/readsb:1.2.3

# Pull architecture-specific (rarely needed)
docker pull blackoutsecure/readsb:latest@amd64
```

---

## About The readsb Application

[readsb](https://github.com/wiedehopf/readsb) is an ADS-B decoder often described upstream as an "ADS-B decoder swiss knife".

It is a detached fork lineage used by many ADS-B receivers and related tooling, with network outputs, JSON/API features, and broad SDR support used for local receivers and large-scale feed/aggregation workflows.

Author and maintenance credits (upstream):

- Primary upstream maintainer: [wiedehopf](https://github.com/wiedehopf) (Matthias Wirth)
- Upstream credits/history lineage: antirez (original dump1090), Malcom Robb, mutability (dump1090-mutability / dump1090-fa), Mictronics (readsb fork), and wiedehopf (current fork)
- Upstream repository and documentation: [wiedehopf/readsb](https://github.com/wiedehopf/readsb)

---

## Supported Architectures

This image is published as a multi-arch manifest. Pulling `blackoutsecure/readsb:latest` retrieves the correct image for your host architecture.

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |
| arm64 | arm64v8-latest |

---

## Usage

### docker-compose (recommended, [click here for more info](https://docs.linuxserver.io/general/docker-compose))

```yaml
---
services:
  readsb:
    image: blackoutsecure/readsb:latest
    container_name: readsb
    environment:
      - TZ=Etc/UTC
      - READSB_ARGS=--net --device-type rtlsdr
      - READSB_AUTOGAIN=true          # automatic gain optimization (recommended)
      # - READSB_BIASTEE=true          # enable for powered LNAs (e.g. SAWbird+)
      - LOG_LEVEL=info                 # debug | info | warn | error | fatal
    volumes:
      - /path/to/readsb/config:/config
      - /path/to/readsb/json:/run/readsb
    ports:
      - 30001:30001  # Raw protocol (TCP)
      - 30002:30002  # Raw protocol input (TCP)
      - 30003:30003  # SBS protocol (TCP)
      - 30004:30004  # Beast protocol (TCP)
      - 30005:30005  # Beast input (TCP)
      - 30104:30104  # JSON protocol (TCP)
    devices:
      - /dev/bus/usb:/dev/bus/usb
    security_opt:
      - no-new-privileges:true
    tmpfs:
      - /tmp
      - /run:exec
    restart: unless-stopped
```

### docker-compose with RTL-SDR over network (e.g., from a remote receiver)

```yaml
---
services:
  readsb:
    image: blackoutsecure/readsb:latest
    container_name: readsb
    environment:
      - TZ=Etc/UTC
      - READSB_ARGS=--net --lon <longitude> --lat <latitude>
    volumes:
      - /path/to/readsb/config:/config
      - /path/to/readsb/json:/run/readsb
    ports:
      - 30001:30001
      - 30002:30002
      - 30003:30003
      - 30004:30004
      - 30005:30005
      - 30104:30104
    security_opt:
      - no-new-privileges:true
    tmpfs:
      - /tmp
      - /run:exec
    restart: unless-stopped
```

### docker-compose with dump978 sidecar (dual 1090/978 MHz, US only)

```yaml
---
services:
  readsb:
    image: blackoutsecure/readsb:latest
    container_name: readsb
    environment:
      - TZ=Etc/UTC
      - READSB_ARGS=--net --device-type rtlsdr
      - READSB_AUTOGAIN=true
      # - READSB_BIASTEE=true          # enable for powered LNAs (e.g. SAWbird+)
      - FEED_UAT_INPUT=dump978:30978
      # - READSB_DEVICE=00001090  # pin 1090 dongle by serial
    volumes:
      - readsb-config:/config
      - readsb-json:/run/readsb
    devices:
      - /dev/bus/usb:/dev/bus/usb
    ports:
      - 30001:30001
      - 30002:30002
      - 30003:30003
      - 30004:30004
      - 30005:30005
      - 30104:30104
    security_opt:
      - no-new-privileges:true
    tmpfs:
      - /tmp
      - /run:exec
    restart: unless-stopped
    depends_on:
      - dump978

  dump978:
    image: blackoutsecure/dump978:latest
    container_name: dump978
    environment:
      - TZ=Etc/UTC
      - DUMP978_SDR=driver=rtlsdr,serial=00000978
      - DUMP978_PROFILE=adsbexchange
    volumes:
      - dump978-config:/config
      - dump978-run:/run/dump978-fa
    ports:
      - 8978:8978
      - 30978:30978
      - 30979:30979
    devices:
      - /dev/bus/usb:/dev/bus/usb
    security_opt:
      - no-new-privileges:true
    tmpfs:
      - /tmp
      - /run:exec
    restart: unless-stopped

volumes:
  readsb-config:
  readsb-json:
  dump978-config:
  dump978-run:
```

> **Note:** UAT 978 MHz is US-only (below 18,000 ft). Tag your dongles with `rtl_eeprom -d 0 -s 00001090` and `rtl_eeprom -d 1 -s 00000978`.
> See [blackoutsecure/docker-dump978](https://github.com/blackoutsecure/docker-dump978) for full dump978 documentation.

### docker-cli ([click here for more info](https://docs.docker.com/engine/reference/commandline/cli/))

```bash
docker run -d \
  --name=readsb \
  -e TZ=Etc/UTC \
  -e READSB_ARGS="--net --device-type rtlsdr" \
  -e READSB_AUTOGAIN=true \
  -p 30001:30001 \
  -p 30002:30002 \
  -p 30003:30003 \
  -p 30004:30004 \
  -p 30005:30005 \
  -p 30104:30104 \
  -v /path/to/readsb/config:/config \
  -v /path/to/readsb/json:/run/readsb \
  --device=/dev/bus/usb:/dev/bus/usb \
  --security-opt no-new-privileges:true \
  --restart unless-stopped \
  blackoutsecure/readsb:latest
```

### Balena Deployment

This image can be deployed to Balena-powered IoT devices using the included `docker-compose.yml` file (which contains the required Balena labels):

- Balena block listing: [https://hub.balena.io/blocks/2351129/readsb](https://hub.balena.io/blocks/2351129/readsb)

```bash
balena push <your-app-slug>
```

For deployment via the web interface, use the deploy button in this repository. See [Balena documentation](https://docs.balena.io/) for details.

## Parameters

### Ports

| Parameter | Function |
| :----: | --- |
| `-p 30001:30001` | Raw protocol output (TCP) |
| `-p 30002:30002` | Raw protocol input (TCP) |
| `-p 30003:30003` | SBS protocol compatible output (TCP) |
| `-p 30004:30004` | Beast protocol output (TCP) |
| `-p 30005:30005` | Beast protocol input (TCP) |
| `-p 30104:30104` | JSON protocol output (TCP) |

### Environment Variables

| Parameter | Function | Required |
| :----: | --- | :---: |
| `-e TZ=Etc/UTC` | Timezone ([TZ database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List)) | Optional |
| `-e READSB_ARGS=` | Additional arguments for readsb | Optional |
| `-e READSB_USER=abc` | Runtime user (default: `abc`). USB permissions are fixed automatically during init. | Optional |
| `-e PUID=1000` | User ID for file ownership (LinuxServer.io base image standard) | Optional |
| `-e PGID=1000` | Group ID for file ownership (LinuxServer.io base image standard) | Optional |
| `-e READSB_DEVICE=` | RTL-SDR device index or serial for 1090 MHz (overrides auto-detection) | Optional |
| `-e FEED_PROFILES=` | Comma-separated feed exchanges (e.g. `adsbexchange,adsb-fi`). Defaults to `adsbexchange` if unset. | Optional |
| `-e FEED_UUID_ADSBEXCHANGE=` | Per-profile UUID override. Use uppercase profile name with hyphens as underscores (e.g. `FEED_UUID_ADSB_FI`, `FEED_UUID_AIRPLANESLIVE`). Stored in `/config/feed-uuid-<profile>`. | Optional |
| `-e FEED_STATS_ENABLED=true` | Enable periodic console stats logging and ADSBx RSSI/stats upload. Console stats log aircraft count, positions, and message totals. ADSBx upload activates automatically when `adsbexchange` is in `FEED_PROFILES`, using the same UUID as the beast feed. | Optional |
| `-e STATS_LOG_INTERVAL=120` | Console stats logging interval in seconds (default: `120` = every 2 minutes) | Optional |
| `-e FEED_UAT_INPUT=` | UAT 978 MHz source as `host:port` (e.g. `dump978:30978`). Requires [docker-dump978](https://github.com/blackoutsecure/docker-dump978) sidecar. US only. | Optional |
| `-e FEED_LAT=` | Receiver latitude (e.g. `47.6062`). Fallback if `--lat` not in `READSB_ARGS`. | Optional |
| `-e FEED_LON=` | Receiver longitude (e.g. `-122.3321`). Fallback if `--lon` not in `READSB_ARGS`. | Optional |
| `-e READSB_AUTO_LOCATION=true` | Auto-detect latitude/longitude via IP geolocation when `FEED_LAT`/`FEED_LON` not set. | Optional |
| `-e READSB_AUTOGAIN=true` | Enable automatic gain optimization (default: `true`). Analyzes strong signal percentage hourly and adjusts gain for optimal range. Persists to `/config/autogain-gain`. Set to `false` for hardware AGC (`--gain auto`). | Optional |
| `-e READSB_AUTOGAIN_INTERVAL=3600` | How often (seconds) the autogain service checks and adjusts gain. Default `3600` (1 hour). | Optional |
| `-e READSB_AUTOGAIN_LOW=0.5` | Autogain low threshold (%). If strong signals fall below this, gain is increased. | Optional |
| `-e READSB_AUTOGAIN_HIGH=7.0` | Autogain high threshold (%). If strong signals exceed this, gain is decreased. | Optional |
| `-e READSB_BIASTEE=false` | Enable bias-T DC voltage on the RTL-SDR coax to power active antennas/LNAs (default: `false`). Only enable if your antenna requires DC power. | Optional |
| `-e LOG_LEVEL=info` | Minimum log verbosity: `debug`, `info` (default), `warn`, `error`, `fatal`. Set to `debug` for verbose operational detail, or `warn` to suppress routine informational messages. | Optional |

### Storage Mounts

| Parameter | Function | Required |
| :----: | --- | :---: |
| `-v /config` | Configuration and persistent data | Recommended |
| `-v /run/readsb` | JSON output directory | Recommended |

### Devices

| Parameter | Function | Required |
| :----: | --- | :---: |
| `--device=/dev/bus/usb:/dev/bus/usb` | RTL-SDR USB device access | Required (for RTL-SDR local RX) |

---

## Volume Details

The container uses two volumes for data persistence and output:

### `/config` — Configuration & Persistence

- **Required**: No (container runs without it, but state is lost on restart)
- **Purpose**: Stores persistent data including aircraft database cache and application state
- **Contents**:
  - `aircraft.csv.gz` (aircraft identification database)
  - Temporary caches and application state
  - Any custom configuration files
- **Example**: `-v /path/to/readsb/config:/config` or `-v readsb-config:/config`

### `/run/readsb` — JSON Output

- **Required**: No (but needed to access real-time ADS-B data)
- **Purpose**: Real-time JSON protocol output consumed by other applications and visualization tools
- **Contents**:
  - `aircraft.json` (current aircraft with positions and altitudes)
  - `receiver.json` (receiver stats and information)
  - Other protocol outputs
- **Update frequency**: Multiple times per second
- **Example**: `-v /path/to/readsb/json:/run/readsb` or `-v readsb-json:/run/readsb`

### Best Practices

- **For persistence**: Always use named volumes or host paths for `/config` to preserve aircraft database between container restarts
- **For JSON access**: Mount `/run/readsb` to a host path to query data from other containers or host processes
- **Alternative (tmpfs)**: Can use `tmpfs` mounts for temp directories, but JSON output will be lost when container stops

### Volume Mount Examples

**Named volumes (recommended for single-host deployments):**

```yaml
volumes:
  - config:/config
  - json:/run/readsb
```

**Host paths (for direct file access):**

```yaml
volumes:
  - /var/lib/readsb/config:/config
  - /var/lib/readsb/json:/run/readsb
```

**Accessing JSON data from host:**

```bash
docker exec readsb cat /run/readsb/aircraft.json | jq '.aircraft | length'
```

---

## Configuration

Environment variables are set using `-e` flags in `docker run` or the `environment:` section in docker-compose.

---

## User / Group Identifiers

By default, this container runs as the LSIO `abc` user (non-root) for better security isolation. The `abc` user is created by the [LinuxServer.io base image](https://docs.linuxserver.io/general/understanding-puid-and-pgid/) with UID/GID 911 and remapped at container start via `PUID`/`PGID`.

**Non-root mode (default, recommended):**

- readsb runs as the `abc` user by default
- RTL-SDR USB device permissions are automatically fixed during container init — no manual configuration needed
- Set `PUID` and `PGID` only if you need file ownership to match a specific host user

**Root mode (fallback):**

- Set `READSB_USER=root` if needed for other reasons
- USB permissions are handled automatically regardless of user

---

## Application Setup

The container runs readsb with network support and automatic RTL-SDR device detection by default.

### Key Features

- **JSON Output**: ADS-B data is output as JSON to `/run/readsb/` and updated frequently
- **RTL-SDR Support**: USB devices are auto-detected when passed to the container; permissions are fixed automatically
- **Aircraft Database**: Includes [tar1090 aircraft database](https://github.com/wiedehopf/tar1090-db) for accurate identification
- **Automatic Gain Optimization**: Enabled by default — analyzes strong signal percentage and adjusts gain hourly for optimal range (see [Automatic Gain Optimization](#automatic-gain-optimization))
- **Bias-T Power**: Optional DC voltage on coax for active antennas with built-in LNAs (see [Bias-T Power for Active Antennas](#bias-t-power-for-active-antennas))
- **Docker HEALTHCHECK**: Built-in health monitoring — marks container unhealthy if `aircraft.json` stops updating
- **Periodic Stats**: Logs aircraft count, positions, and message totals every 2 minutes (configurable via `STATS_LOG_INTERVAL`). When `adsbexchange` is in `FEED_PROFILES`, also uploads RSSI/stats data to ADSBx every 5 seconds using the same UUID as the beast feed. Per-upload confirmations are `debug`-level.
- **Log Verbosity**: Set `LOG_LEVEL` to control log output: `debug`, `info` (default), `warn`, `error`, `fatal`
- **Feed Status URLs**: Init logs include verification URLs for each active feed profile
- **RTL-SDR Tools**: `rtl_test`, `rtl_eeprom`, and `rtl_biast` available inside the container for diagnostics, dongle tagging, and bias-T control

### Customizing READSB_ARGS

The `READSB_ARGS` environment variable allows you to customize readsb behavior. By default, automatic gain optimization manages gain via `svc-autogain`. Specifying `--gain` in `READSB_ARGS` overrides autogain entirely.

**Common examples:**

```bash
# RTL-SDR with default autogain (recommended)
-e READSB_ARGS="--net --device-type rtlsdr"

# Network-only mode (no local RTL-SDR)
-e READSB_ARGS="--net --lat 51.5 --lon -0.1"

# Force a specific fixed gain (bypasses autogain)
-e READSB_ARGS="--net --device-type rtlsdr --gain 35"

# Frequency correction and location
-e READSB_ARGS="--net --device-type rtlsdr --freq-correction 10 --lat 51.5 --lon -0.1 --max-range 350"
```

For all available options, see the [readsb documentation](https://github.com/wiedehopf/readsb).

### JSON Output Files

- `aircraft.json` - Current aircraft data with positions, callsigns, and altitudes
- `receiver.json` - Statistics and receiver information

### Supported Modes

- **Read-only filesystem**: Supported when JSON and temp directories are mounted to volumes or tmpfs
- **Non-root user**: Supported by default — RTL-SDR USB permissions are fixed automatically during init

### SDR Device Selection

The container auto-detects RTL-SDR dongles at startup and assigns the 1090 MHz device automatically using the community serial-number convention.

**Auto-detection (default):**

- Single dongle: assumed to be 1090 MHz
- Multiple dongles: serial containing `978` or `uat` is identified as UAT (informational); first non-UAT dongle is assigned as 1090

**Manual override:**

Set `READSB_DEVICE` to a device index or serial number:

```yaml
environment:
  - READSB_DEVICE=0          # by device index
  - READSB_DEVICE=00001090   # by serial number
```

**UAT 978 MHz (US only):**

readsb only decodes 1090 MHz. For 978 MHz UAT, run [blackoutsecure/docker-dump978](https://github.com/blackoutsecure/docker-dump978) as a sidecar container and set `FEED_UAT_INPUT=dump978:30978` to merge UAT aircraft into readsb's unified output. See the [dump978 sidecar compose example](#docker-compose-with-dump978-sidecar-dual-1090978-mhz-us-only) above.

**Tagging dongle serials:**

```bash
rtl_eeprom -d 0 -s 00001090   # tag first dongle as 1090
rtl_eeprom -d 1 -s 00000978   # tag second dongle as UAT
```

---

## Feed Profiles

`FEED_PROFILES` controls data forwarding to ADS-B data aggregators directly from the readsb container. It defaults to `adsbexchange` if unset. No separate feed container is needed — readsb forwards data using `--net-connector` arguments appended automatically per profile. Set `FEED_PROFILES` to an empty string to disable all feeding. MLAT positioning requires a separate `mlat-client` container per exchange (see MLAT table below).

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `FEED_PROFILES` | `adsbexchange` | Comma-separated list of exchanges to feed. Options: `adsbexchange`, `adsb-fi`, `airplaneslive`, `planewatch`, `opensky`, `flyitalyadsb`, `adsbhub`, `radarplane`. Defaults to `adsbexchange` if unset. Set to empty string to disable feeding. |
| `FEED_UUID_<PROFILE>` | (auto-generated) | Per-profile UUID. Use uppercase profile name with hyphens as underscores (e.g. `FEED_UUID_ADSBEXCHANGE`, `FEED_UUID_ADSB_FI`, `FEED_UUID_AIRPLANESLIVE`). Auto-generated on first run and stored in `/config/feed-uuid-<profile>`. |
| `FEED_STATS_ENABLED` | `true` | Enable periodic console stats logging and ADSBx RSSI/stats upload. ADSBx upload activates automatically when `adsbexchange` is in `FEED_PROFILES`, using the same UUID as the beast feed. |
| `STATS_LOG_INTERVAL` | `120` | Console stats logging interval in seconds. Default is `120` (every 2 minutes). Set to e.g. `60` for 1 min or `300` for 5 min. |
| `FEED_UAT_INPUT` | (empty) | UAT 978 MHz data source as `host:port` (e.g. `dump978:30978`). Only applies in the US. |
| `FEED_LAT` | (empty) | Receiver latitude in decimal degrees. Used as fallback if `--lat` is not in `READSB_ARGS`. |
| `FEED_LON` | (empty) | Receiver longitude in decimal degrees. Used as fallback if `--lon` is not in `READSB_ARGS`. |
| `READSB_AUTO_LOCATION` | `true` | Auto-detect latitude/longitude via IP geolocation when `FEED_LAT`/`FEED_LON` are not set. Set to `false` to disable. |
| `READSB_AUTOGAIN` | `true` | Automatic gain optimization. Analyzes strong signal percentage hourly and adjusts gain. See [Automatic Gain Optimization](#automatic-gain-optimization). |
| `READSB_BIASTEE` | `false` | Bias-T DC power for active antennas. See [Bias-T Power for Active Antennas](#bias-t-power-for-active-antennas). |
| `LOG_LEVEL` | `info` | Minimum log verbosity: `debug`, `info`, `warn`, `error`, `fatal`. Set to `debug` for verbose operational detail. |

### Supported Profiles — Feed Connectors

| Profile name | `--net-connector` value |
|---|---|
| `adsbexchange` | `feed1.adsbexchange.com,30004,beast_reduce_out,feed2.adsbexchange.com,64004` |
| `adsb-fi` | `feed.adsb.fi,30004,beast_reduce_out` |
| `airplaneslive` | `feed.airplanes.live,30004,beast_reduce_out` |
| `planewatch` | `atc.plane.watch,30004,beast_reduce_out` |
| `opensky` | `feed.opensky-network.org,30005,beast_reduce_out` |
| `flyitalyadsb` | `dati.flyitalyadsb.com,4905,beast_reduce_out` |
| `adsbhub` | `data.adsbhub.org,5002,beast_reduce_out` |
| `radarplane` | `feed.radarplane.com,30001,beast_reduce_out` |

### Supported Profiles — MLAT Servers

MLAT (multilateration) is **optional** — your ADS-B feed and stats work without it. MLAT uses timing data from multiple receivers to locate aircraft that don't broadcast GPS positions. If you want to enable it, run a separate `mlat-client` container per exchange.

#### mlat-client Environment Variables

| Variable | Default | Description |
|---|---|---|
| `MLAT_CLIENT_INPUT_CONNECT` | `readsb:30005` | Beast data source (`host:port`) |
| `MLAT_CLIENT_SERVER` | `feed.adsbexchange.com:31090` | Multilateration server (`host:port`) — see table below |
| `MLAT_CLIENT_LAT` | (auto-detected) | Receiver latitude in decimal degrees. Auto-detected via IP geolocation if empty and `MLAT_CLIENT_AUTO_LOCATION=true`. |
| `MLAT_CLIENT_LON` | (auto-detected) | Receiver longitude in decimal degrees. Auto-detected via IP geolocation if empty and `MLAT_CLIENT_AUTO_LOCATION=true`. |
| `MLAT_CLIENT_ALT` | (auto-detected) | Receiver altitude with unit (`m` or `ft`). Auto-detected from terrain elevation when lat/lon are auto-detected. |
| `MLAT_CLIENT_USER_ID` | *(required)* | User identifier / feeder name for the MLAT server |
| `MLAT_CLIENT_RESULTS` | (none) | Results output destination(s), e.g. `beast,connect,readsb:30104` |
| `MLAT_CLIENT_AUTO_LOCATION` | `true` | Auto-detect lat/lon via [ip-api.com](http://ip-api.com/) and altitude via [Open-Meteo Elevation API](https://open-meteo.com/en/docs/elevation-api) when `MLAT_CLIENT_LAT`/`MLAT_CLIENT_LON` are not set. Set to `false` to disable. |
| `MLAT_CLIENT_PRIVACY` | `false` | Hide receiver on coverage maps |
| `MLAT_CLIENT_UUID` | (none) | UUID sent to the server |
| `MLAT_CLIENT_UUID_FILE` | (none) | Path to UUID file for persistent identity |
| `MLAT_CLIENT_NO_UDP` | `false` | Disable UDP transport |
| `MLAT_CLIENT_ARGS` | (none) | Raw arguments (overrides individual env vars) |

> **Auto-location:** When `MLAT_CLIENT_AUTO_LOCATION` is `true` (the default) and `MLAT_CLIENT_LAT`/`MLAT_CLIENT_LON` are not set, the mlat-client container automatically detects your approximate location via IP geolocation. Altitude is resolved from terrain elevation at the detected coordinates. Explicit values always take priority. IP-based geolocation is approximate (city-level) — for best MLAT results, set your exact coordinates manually.

| Profile name | MLAT server endpoint |
|---|---|
| `adsbexchange` | `feed.adsbexchange.com:31090` |
| `adsb-fi` | `feed.adsb.fi:31090` |
| `airplaneslive` | `feed.airplanes.live:31090` |
| `planewatch` | `mlat.plane.watch:31090` |
| `flyitalyadsb` | `dati.flyitalyadsb.com:30100` |
| `radarplane` | `mlat.radarplane.com:40900` |

> **Feeder name**: Most aggregators (e.g. ADSBExchange) derive your display name from the `--user` / `MLAT_CLIENT_USER_ID` value sent by your mlat-client container. If no mlat-client is connected, the exchange typically auto-generates a random name. To set a custom name, configure `MLAT_CLIENT_USER_ID` in your mlat-client sidecar (see examples below).

### Quick Start — Single Exchange

```yaml
services:
  readsb:
    image: blackoutsecure/readsb:latest
    container_name: readsb
    environment:
      - TZ=Etc/UTC
      - READSB_ARGS=--net --device-type rtlsdr
      - READSB_AUTOGAIN=true
      # - READSB_BIASTEE=true          # enable for powered LNAs (e.g. SAWbird+)
      - FEED_PROFILES=adsbexchange
      - FEED_LAT=51.5074
      - FEED_LON=-0.1278
    volumes:
      - readsb-config:/config
      - readsb-run:/run/readsb
    devices:
      - /dev/bus/usb:/dev/bus/usb
    restart: unless-stopped

  mlat-client:
    image: blackoutsecure/mlat-client:latest
    container_name: mlat-adsbx
    environment:
      - MLAT_CLIENT_INPUT_CONNECT=readsb:30005
      - MLAT_CLIENT_SERVER=feed.adsbexchange.com:31090
      - MLAT_CLIENT_LAT=51.5074               # omit to auto-detect via IP geolocation
      - MLAT_CLIENT_LON=-0.1278               # omit to auto-detect via IP geolocation
      - MLAT_CLIENT_ALT=50m                   # omit to auto-detect from terrain elevation
      # - MLAT_CLIENT_AUTO_LOCATION=true      # default — auto-detects lat/lon/alt when not set
      - MLAT_CLIENT_USER_ID=myfeeder-london
      - MLAT_CLIENT_RESULTS=beast,connect,readsb:30104
    depends_on: [readsb]
    restart: unless-stopped

volumes:
  readsb-config:
  readsb-run:
```

### Quick Start — Single Exchange (Auto-Location)

Minimal setup — lat/lon/alt are auto-detected from your IP address:

```yaml
services:
  readsb:
    image: blackoutsecure/readsb:latest
    container_name: readsb
    environment:
      - TZ=Etc/UTC
      - READSB_ARGS=--net --device-type rtlsdr
      - READSB_AUTOGAIN=true
      - FEED_PROFILES=adsbexchange
    volumes:
      - readsb-config:/config
      - readsb-run:/run/readsb
    devices:
      - /dev/bus/usb:/dev/bus/usb
    restart: unless-stopped

  mlat-client:
    image: blackoutsecure/mlat-client:latest
    container_name: mlat-adsbx
    environment:
      - MLAT_CLIENT_INPUT_CONNECT=readsb:30005
      - MLAT_CLIENT_SERVER=feed.adsbexchange.com:31090
      - MLAT_CLIENT_USER_ID=myfeeder-london
      - MLAT_CLIENT_RESULTS=beast,connect,readsb:30104
      # MLAT_CLIENT_LAT, MLAT_CLIENT_LON, MLAT_CLIENT_ALT auto-detected
    depends_on: [readsb]
    restart: unless-stopped

volumes:
  readsb-config:
  readsb-run:
```

### Quick Start — Multi-Exchange

```yaml
services:
  readsb:
    image: blackoutsecure/readsb:latest
    container_name: readsb
    environment:
      - TZ=Etc/UTC
      - READSB_ARGS=--net --device-type rtlsdr
      - READSB_AUTOGAIN=true
      # - READSB_BIASTEE=true          # enable for powered LNAs (e.g. SAWbird+)
      - FEED_PROFILES=adsbexchange,adsb-fi,airplaneslive
      - FEED_LAT=51.5074
      - FEED_LON=-0.1278
    volumes:
      - readsb-config:/config
      - readsb-run:/run/readsb
    devices:
      - /dev/bus/usb:/dev/bus/usb
    restart: unless-stopped

  mlat-adsbx:
    image: blackoutsecure/mlat-client:latest
    container_name: mlat-adsbx
    environment:
      - MLAT_CLIENT_INPUT_CONNECT=readsb:30005
      - MLAT_CLIENT_SERVER=feed.adsbexchange.com:31090
      - MLAT_CLIENT_LAT=51.5074               # omit to auto-detect via IP geolocation
      - MLAT_CLIENT_LON=-0.1278               # omit to auto-detect via IP geolocation
      - MLAT_CLIENT_ALT=50m                   # omit to auto-detect from terrain elevation
      - MLAT_CLIENT_USER_ID=myfeeder-london
      - MLAT_CLIENT_RESULTS=beast,connect,readsb:30104
    depends_on: [readsb]
    restart: unless-stopped

  mlat-adsb-fi:
    image: blackoutsecure/mlat-client:latest
    container_name: mlat-adsb-fi
    environment:
      - MLAT_CLIENT_INPUT_CONNECT=readsb:30005
      - MLAT_CLIENT_SERVER=feed.adsb.fi:31090
      - MLAT_CLIENT_LAT=51.5074               # omit to auto-detect
      - MLAT_CLIENT_LON=-0.1278               # omit to auto-detect
      - MLAT_CLIENT_ALT=50m                   # omit to auto-detect
      - MLAT_CLIENT_USER_ID=myfeeder-london
      - MLAT_CLIENT_RESULTS=beast,connect,readsb:30104
    depends_on: [readsb]
    restart: unless-stopped

  mlat-airplaneslive:
    image: blackoutsecure/mlat-client:latest
    container_name: mlat-airplaneslive
    environment:
      - MLAT_CLIENT_INPUT_CONNECT=readsb:30005
      - MLAT_CLIENT_SERVER=feed.airplanes.live:31090
      - MLAT_CLIENT_LAT=51.5074               # omit to auto-detect
      - MLAT_CLIENT_LON=-0.1278               # omit to auto-detect
      - MLAT_CLIENT_ALT=50m                   # omit to auto-detect
      - MLAT_CLIENT_USER_ID=myfeeder-london
      - MLAT_CLIENT_RESULTS=beast,connect,readsb:30104
    depends_on: [readsb]
    restart: unless-stopped

volumes:
  readsb-config:
  readsb-run:
```

### Services Requiring Separate Containers

> [!NOTE]
> **TO DO** — Sidecar container images for the services listed below are planned but not yet available. Compose examples and documentation will be added as each image is published.

Some aggregators use proprietary protocols or require authentication that cannot be handled via a simple `--net-connector` feed profile. These require running a dedicated sidecar container that reads Beast data from `readsb:30005`.

| Service | Container | Auth | Status | Notes |
|---|---|---|---|---|
| **FlightAware** | [flightaware/piaware](https://github.com/flightaware/piaware) | `feeder-id` | 🔜 Planned | Connects to `readsb:30005` for Beast input. Handles auth, feeding, and MLAT independently. |
| **FlightRadar24** | fr24feed | `sharing-key` | 🔜 Planned | Proprietary binary. Connects to `readsb:30005` in AVR/Beast mode. |
| **Radarbox** | rbfeeder | `sharing-key` | 🔜 Planned | Proprietary binary. Connects to `readsb:30005` in Beast mode. |
| **Planefinder** | pfclient | `share-code` | 🔜 Planned | Proprietary binary. Connects to `readsb:30005` in Beast mode. |

### Notes

- **MLAT**: MLAT (multilateration) positioning is **entirely optional** — your ADS-B feed works without it. MLAT requires a separate `mlat-client` container per exchange. The readsb container handles Beast data forwarding only. If you see "MLAT: Not Found" on your feeder status page, that is normal when no mlat-client container is running. See the MLAT server table above for the correct server endpoint per exchange if you want to set it up. The mlat-client container supports **automatic location detection** (`MLAT_CLIENT_AUTO_LOCATION=true`, enabled by default) — lat/lon are resolved from your IP address and altitude from terrain elevation, so you can omit `MLAT_CLIENT_LAT`/`MLAT_CLIENT_LON`/`MLAT_CLIENT_ALT` for a quick start. For best MLAT accuracy, set your exact coordinates manually.

- **UUID**: Each feed profile gets its own UUID, stored in `/config/feed-uuid-<profile>` (e.g. `/config/feed-uuid-adsbexchange`). UUIDs are auto-generated on first run and persisted across container restarts. They are also injected into the s6 container environment (e.g. `FEED_UUID_ADSBEXCHANGE`) for downstream services. To override, set `FEED_UUID_<PROFILE>` env vars. To view: `docker exec readsb cat /config/feed-uuid-adsbexchange`

- **Checking feed status**:
  - ADSBx: https://adsbexchange.com/myip/
  - adsb.fi: https://adsb.fi/status
  - airplanes.live: https://airplanes.live/
  - plane.watch: https://plane.watch/
  - flyitalyadsb: https://flyitalyadsb.com/
  - radarplane: https://radarplane.com/

  Feed verification URLs are also logged during container startup for each active profile.

> **Note:** IP-based geolocation is approximate (typically city-level accuracy). Elevation is ground-level at the detected coordinates. For best MLAT results, set your exact coordinates manually.

> **Note on altitude:** The auto-detected altitude represents **ground elevation** at the detected coordinates, not your antenna height above sea level. For accurate MLAT, your altitude should include the height of your antenna above ground. For example, if ground elevation is `50m` and your antenna is on a `10m` rooftop mast, set `MLAT_CLIENT_ALT=60m`. When relying on auto-detection, consider adding your antenna height manually for better multilateration accuracy.

---

## Automatic Gain Optimization

The container includes an automatic gain optimization service (`svc-autogain`) that finds the optimal fixed gain for your RTL-SDR dongle. It is **enabled by default** and is the recommended way to manage gain.

### How It Works

RTL-SDR dongles have a tunable gain amplifier with discrete steps. Too much gain overloads the ADC (signals clip), too little gain means weak signals are lost in the noise floor. The autogain service finds the sweet spot:

1. Every hour (configurable), it reads `stats.json` from readsb
2. Calculates the percentage of messages with RSSI > -3 dBFS ("strong signals")
3. If strong signals are **below 0.5%** → gain is too low → **increase one step**
4. If strong signals are **above 7.0%** → gain is too high (ADC overload) → **decrease one step**
5. If strong signals are **between 0.5% and 7.0%** → gain is optimal → **no change**
6. After adjustment, readsb is automatically restarted with the new gain value

The gain value is persisted in `/config/autogain-gain` and survives container restarts.

### Gain Step Table

The service uses the same gain table as the upstream [autogain1090](https://github.com/wiedehopf/adsb-scripts) script:

```
0.0  0.9  1.4  2.7  3.7  7.7  8.7  12.5  14.4  15.7
16.6 19.7 20.7 22.9 25.4 28.0 29.7 32.8  33.8  36.4
37.2 38.6 40.2 42.1 43.4 43.9 44.5 48.0  49.6  -10 (max)
```

The initial gain starts at **49.6** (near-maximum) and steps down as needed. Most receivers settle between **25–44** depending on local RF environment.

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `READSB_AUTOGAIN` | `true` | Enable/disable autogain. Set to `false` to fall back to hardware AGC (`--gain auto`). |
| `READSB_AUTOGAIN_INTERVAL` | `3600` | Check interval in seconds. Default is 1 hour. Lower values (e.g. `1800` = 30 min) converge faster but need sufficient message volume. |
| `READSB_AUTOGAIN_LOW` | `0.5` | Low threshold (%). Below this, gain is increased. Raise if you want fewer weak signals. |
| `READSB_AUTOGAIN_HIGH` | `7.0` | High threshold (%). Above this, gain is decreased. Lower if you're in a high-RF area. |

### Monitoring Autogain

```bash
# View current gain value
docker exec readsb cat /config/autogain-gain

# Watch autogain decisions in logs
docker logs readsb 2>&1 | grep 'svc-autogain\['

# Check autogain service status
docker exec readsb s6-svstat /run/service/svc-autogain
```

Example log output:

```
svc-autogain[info]: Autogain active — interval=3600s, low=0.5%, high=7.0%
svc-autogain[info]: Current gain: 49.6
svc-autogain[info]: Decreasing gain: 49.6 → 48.0 (8.234% strong signals)
svc-autogain[info]: Restarting readsb to apply gain 48.0...
svc-autogain[info]: Gain 44.5 OK — 3.142% strong signals in range [0.5%, 7.0%]
```

### Autogain vs `--gain auto` vs Manual Gain

| Method | How it works | Recommended? |
|---|---|---|
| **Autogain** (default) | Analyzes real reception data, steps through gain table, settles on optimal fixed value | Yes — best range and signal quality |
| `--gain auto` | Hardware AGC in the RTL-SDR chip — reacts in real-time but often picks suboptimal levels | Fallback only |
| `--gain <value>` | You pick a fixed gain value — works if you know your RF environment | For experts who have tested with `rtl_test` |

### Disabling Autogain

```yaml
environment:
  - READSB_AUTOGAIN=false          # use hardware AGC (--gain auto)
  # OR specify a fixed gain directly:
  - READSB_ARGS=--net --device-type rtlsdr --gain 38.6
```

If `--gain` is specified in `READSB_ARGS`, it takes priority over both autogain and hardware AGC.

### Tips for Faster Convergence

- **First run**: Autogain starts at 49.6 and may need several hours to settle. In busy airspace it converges within 2-4 cycles.
- **Low traffic areas**: If you see "Not enough new messages" in the logs, reduce the interval: `READSB_AUTOGAIN_INTERVAL=1800`
- **High RF interference**: If gain keeps oscillating between two values, tighten the thresholds: `READSB_AUTOGAIN_LOW=1.0` and `READSB_AUTOGAIN_HIGH=5.0`
- **After moving antenna**: Delete `/config/autogain-gain` and restart the container to re-optimize from scratch.

---

## Bias-T Power for Active Antennas

Some ADS-B setups use an inline **LNA** (Low Noise Amplifier) and/or **SAW filter** module between the antenna and the RTL-SDR dongle. These modules amplify and filter the signal right at the antenna before cable loss degrades it — significantly improving range and aircraft count. They need DC power delivered through the coaxial cable, which is called **bias-T** (bias tee).

A popular example is the **Nooelec SAWbird+ ADS-B** — a dual-channel cascaded ultra-low noise amplifier and SAW filter module with dedicated 1090 MHz (ADS-B) and 978 MHz (UAT) channels. It plugs inline between your antenna and dongle. It supports **two power options**: bias-T (3–5V DC via the SMA coax) or external power via a **micro-USB port**. You only need one — not both.

### Typical Setup with SAWbird+

**Option A — Bias-T powered (cleanest setup, no extra cables):**

```
Antenna ──► SAWbird+ ADS-B (1090 MHz channel) ──► RTL-SDR dongle (serial 1090)
                                                    └─ bias-T powers SAWbird+ via coax
```

**Option B — USB powered (bias-T not needed):**

```
Antenna ──► SAWbird+ ADS-B (1090 MHz channel) ──► RTL-SDR dongle (serial 1090)
                 └─ micro-USB power cable
```

If using **Option A** (bias-T), set `READSB_BIASTEE=true` — without it the LNA has no power and actually **adds insertion loss** (makes reception worse than no filter at all). If using **Option B** (USB power), leave `READSB_BIASTEE=false` — the SAWbird+ is already powered and bias-T is unnecessary.

### When to Enable

Enable `READSB_BIASTEE=true` if you use:
- **Nooelec SAWbird+ ADS-B** powered via bias-T (no USB power connected)
- **Nooelec SAWbird+ NOAA** or other SAWbird+ variants powered via bias-T
- **RTL-SDR Blog ADS-B LNA** (inline filtered LNA)
- Any inline LNA/filter that says "requires bias-T" or "requires 3.3–5V DC via coax"
- Active antennas with a **built-in LNA** that has no separate power input

### When NOT to Enable

Do **not** enable bias-T if:
- Your antenna is **passive** (simple whip, dipole, or ground plane with no active electronics)
- Your LNA/filter has its own **separate USB or DC power supply** (some models have a micro-USB port)
- You have a **standalone bias-T injector** powered externally
- You're unsure — leave it off and check your device documentation

> **Warning**: Sending DC voltage to a device not designed for it won't damage most modern RTL-SDR dongles (they have short-circuit protection), but it's best practice to only enable when needed.

> [!CAUTION]
> **Only enable `READSB_BIASTEE=true` if your antenna or inline LNA requires DC power via coax.** Bias-T is disabled by default. If you are unsure whether your setup needs it, leave it off and consult your antenna/LNA documentation.

### Configuration

```yaml
environment:
  - READSB_BIASTEE=true
```

The container runs `rtl_biast -b 1` before starting readsb. If a specific dongle serial is configured (`READSB_DEVICE` or auto-detected `SDR_1090_SERIAL`), it targets that dongle.

### Verifying Bias-T

```bash
# Check bias-T status in logs
docker logs readsb 2>&1 | grep 'bias-T'

# Manually test bias-T inside the container
docker exec readsb rtl_biast -b 1    # enable
docker exec readsb rtl_biast -b 0    # disable
```

When bias-T is active, you should see a noticeable improvement in aircraft count and range compared to running the SAWbird+ unpowered.

### Compatible Dongles (Bias-T Capable)

| RTL-SDR Dongle | Bias-T | Voltage / Current |
|---|---|---|
| RTL-SDR Blog V3 | Yes | 4.5V, ~180mA max |
| RTL-SDR Blog V4 | Yes | 4.5V, ~180mA max |
| Nooelec NESDR SMArt v5 | Yes | 4.5V |
| Nooelec NESDR SMArTee XTR | Yes (always on) | 4.5V |
| Generic RTL2832U dongles | Usually no | — |

### Compatible LNA/Filter Modules

| Module | Frequency | Power |
|---|---|---|
| Nooelec SAWbird+ ADS-B | 1090 MHz + 978 MHz (dual) | Bias-T (3–5V via coax) or micro-USB |
| Nooelec SAWbird+ NOAA | 137 MHz | Bias-T (3–5V via coax) or micro-USB |
| RTL-SDR Blog ADS-B LNA | 1090 MHz | Bias-T (3.3–5V via coax) |
| RTL-SDR Blog Wideband LNA | Wideband | Bias-T or micro-USB |

---

## Advanced Tuning

### Gain — When to Intervene Manually

Autogain handles most situations, but you may want to adjust in these cases:

**Gain keeps oscillating:**
If the same gain value alternates between "too high" and "too low" every cycle, narrow the acceptable band:

```yaml
environment:
  - READSB_AUTOGAIN_LOW=1.0    # was 0.5
  - READSB_AUTOGAIN_HIGH=5.0   # was 7.0
```

**Want to check your RF environment:**
Run `rtl_test` inside the container to see the signal baseline:

```bash
docker exec readsb rtl_test -t                    # basic dongle test
docker exec readsb rtl_test -s 2400000 -t         # test at 2.4 MSPS
```

**Force a specific gain for testing:**

```yaml
environment:
  - READSB_AUTOGAIN=false
  - READSB_ARGS=--net --device-type rtlsdr --gain 38.6
```

### Frequency Correction (PPM)

RTL-SDR dongles have a crystal oscillator that's typically off by a few PPM (parts per million). Most R820T2-based dongles are within ±1 PPM and don't need correction. If you're seeing fewer aircraft than expected:

```bash
# Test PPM offset (let it run for 1+ minute, read the cumulative value)
docker exec readsb rtl_test -p
```

Apply correction:
```yaml
environment:
  - READSB_ARGS=--net --device-type rtlsdr --ppm 3
```

### Network Tuning

These defaults are applied automatically when feed profiles are active, but can be overridden in `READSB_ARGS`:

| Parameter | Default | Description |
|---|---|---|
| `--net-beast-reduce-interval` | `0.5` | Seconds between reduced beast output updates. Lower = more data, more bandwidth. |
| `--net-heartbeat` | `60` | Seconds between TCP keepalive heartbeats. |
| `--net-ro-size` | `1280` | Raw output buffer size in bytes. |
| `--net-ro-interval` | `0.2` | Raw output flush interval in seconds. |
| `--json-location-accuracy` | `2` | JSON position decimal places (1=~11km, 2=~1.1km). |
| `--range-outline-hours` | `24` | Hours of range data to retain for outline calculation. |
| `--max-range` | `450` | Maximum detection range in nautical miles. |
| `--write-json-every` | `1` | JSON output write interval in seconds. Increase to `5` to reduce CPU/IO. |

### Stats & Upload Tuning

| Variable | Default | Description |
|---|---|---|
| `FEED_STATS_ENABLED` | `true` | Master switch for console stats logging and ADSBx stats upload. |
| `STATS_LOG_INTERVAL` | `120` | Console stats interval in seconds. Set `60` for 1-min updates, `300` for 5-min. |
| `ADSBX_UPLOAD_INTERVAL` | `5` | ADSBx stats upload interval in seconds (matches official ADSBx feeder rate). Only active when `adsbexchange` is in `FEED_PROFILES`. |
| `LOG_LEVEL` | `info` | Minimum log verbosity: `debug`, `info`, `warn`, `error`, `fatal`. Per-upload confirmations are `debug`-level. Set to `debug` to see them, or `warn` to suppress routine messages. |

### Location Accuracy

For most users, IP geolocation (default) provides city-level accuracy which is sufficient for basic reception. For MLAT and precise range calculations:

```yaml
environment:
  - FEED_LAT=39.6195          # exact latitude
  - FEED_LON=-86.1552         # exact longitude
  - READSB_AUTO_LOCATION=false  # disable IP geolocation
```

### JSON Output Performance

If CPU or disk I/O is a concern (e.g., on a Raspberry Pi Zero):

```yaml
environment:
  - READSB_ARGS=--net --device-type rtlsdr --write-json-every 5
```

This reduces JSON writes from every second to every 5 seconds.

---

## Troubleshooting

### Log Format

All log output uses syslog format so you can identify the source and severity of each line in `docker logs`, and it integrates natively with log aggregators (Loki, Datadog, Fluentd, etc.):

```
<timestamp> <service>[<priority>]: <message>
```

```
2026-04-02T11:38:20Z init-readsb-config[info]: adsbexchange UUID: 12345678-1234-1234-1234-123456789abc
2026-04-02T11:38:20Z init-readsb-config[info]: adsb-fi UUID: 87654321-4321-4321-4321-cba987654321
2026-04-02T11:38:20Z init-readsb-config[info]: Active feed profiles: adsbexchange,adsb-fi
2026-04-02T11:38:20Z init-readsb-config[info]: Verify adsbexchange feed: https://adsbexchange.com/myip/
2026-04-02T11:38:20Z init-readsb-config[info]: Verify adsb-fi feed: https://adsb.fi/status
2026-04-02T11:38:20Z init-readsb-config[info]: fixed USB permissions: /dev/bus/usb/001/004
2026-04-02T11:38:20Z init-readsb-config[info]: receiver location: 51.5074, -0.1278
2026-04-02T11:38:21Z svc-readsb[info]: readsb container startup configuration
2026-04-02T11:38:21Z svc-readsb[info]: Using autogain-managed gain: 44.5
2026-04-02T11:38:21Z svc-readsb[decoder]: *8daa4b32584385ef2a7603346e29;
2026-04-02T11:38:21Z svc-readsb[decoder]: hex:  aa4b32   CRC: 000000 fixed bits: 0 decode: ok
2026-04-02T11:38:21Z svc-readsb[decoder]: RSSI:    -22.0 dBFS   reduce_forward: 1
2026-04-02T11:38:22Z svc-feed-stats[info]: ADSBx stats upload enabled (UUID: a1b2c3d4-e5f6-7890-abcd-ef1234567890)
2026-04-02T11:38:22Z svc-feed-stats[info]: ADSBx stats URL: https://www.adsbexchange.com/api/feeders/?feed=a1b2c3d4-e5f6-7890-abcd-ef1234567890
2026-04-02T11:38:22Z svc-feed-stats[info]: Starting stats service (upload=5s, console=120s, JSON_DIR=/run/readsb)
2026-04-02T11:40:22Z svc-feed-stats[info]: stats: 42 aircraft tracked (38 with position), 128456 messages total
2026-04-02T12:38:22Z svc-autogain[info]: Gain 44.5 OK — 3.142% strong signals in range [0.5%, 7.0%]
2026-04-02T11:38:52Z svc-feed-stats[warn]: /run/readsb/aircraft.json not updated in 45s.
```

| Service | Description |
|---|---|
| `init-readsb-config` | One-shot init: per-profile UUID generation and persistence (disk + s6 env), feed profile setup, ADSBx stats URL, USB permissions, geolocation |
| `svc-readsb` | Main readsb decoder service (startup config + decoder output) |
| `svc-feed-stats` | Periodic console stats (every 2 min by default) + ADSBx RSSI/stats upload when `adsbexchange` profile is active. Both use the same UUID. Per-upload confirmations are `debug`-level. |
| `svc-autogain` | Automatic gain optimization — adjusts RTL-SDR gain hourly based on strong signal analysis |

| Priority | Meaning |
|---|---|
| `debug` | Verbose operational detail (e.g. per-upload ADSBx confirmations). Hidden at default `info` level. Set `LOG_LEVEL=debug` to see. |
| `info` | Normal operational messages |
| `warn` | Non-fatal issues that may need attention |
| `error` | Errors that affect functionality |
| `fatal` | Critical errors causing service exit |
| `decoder` | Raw readsb decoder output (ADS-B message decoding) |

**Filter logs by service:**

```bash
docker logs readsb 2>&1 | grep 'svc-readsb\['
docker logs readsb 2>&1 | grep 'svc-feed-stats\['
docker logs readsb 2>&1 | grep 'init-readsb-config\['
```

**Filter logs by priority:**

```bash
docker logs readsb 2>&1 | grep '\[debug\]:'    # verbose upload confirmations (requires LOG_LEVEL=debug)
docker logs readsb 2>&1 | grep '\[warn\]:'
docker logs readsb 2>&1 | grep '\[error\]:\|\[fatal\]:'
docker logs readsb 2>&1 | grep '\[decoder\]:'
```

**Log verbosity control:**

Set `LOG_LEVEL` to control which messages appear. Default is `info`.

```yaml
environment:
  - LOG_LEVEL=info     # default — stats summaries, startup info, warnings, errors
  - LOG_LEVEL=debug    # all of the above + per-upload ADSBx confirmations
  - LOG_LEVEL=warn     # warnings and errors only (quietest)
```

### Container won't start or exits immediately

**Check logs:**

```bash
docker logs readsb
docker logs readsb --tail 50 -f  # Follow last 50 lines
```

**Common causes:**

- USB device not found: Verify RTL-SDR dongle is connected and restart container
- Permission denied on `/dev/bus/usb`: Container may need elevated privileges or device permissions
- Configuration error: Check `READSB_ARGS` syntax against [Customizing READSB_ARGS](#customizing-readsb_args)

### ADSBx — linking your account

This container feeds ADSBx via two pathways that share a **single UUID** from `/config/feed-uuid-adsbexchange`:

1. **Beast feed** (`--net-connector` to port 30004) — primary ADS-B data connection (persistent TCP)
2. **Stats upload** (`svc-feed-stats`) — RSSI/stats data (periodic HTTP POST every 5s, matching official ADSBx feeder)

Both pathways use the same UUID so ADSBx sees one feeder. The stats URL is logged at startup:

```
https://www.adsbexchange.com/api/feeders/?feed=YOUR-UUID-HERE
```

**To link your account:** Visit https://adsbexchange.com/myip/ and **click the pre-selected Feed UID** at the top of the "Link your receiver" section.

### No aircraft data appearing

**Verify connectivity:**

```bash
docker exec readsb cat /run/readsb/aircraft.json | jq '.aircraft | length'
```

**If count is 0:**

- Check RTL-SDR device: `docker exec readsb rtl_test -t`
- Verify antenna is connected and positioned properly
- Check current autogain value: `docker exec readsb cat /config/autogain-gain`
- If autogain hasn't settled yet, try a manual gain: add `--gain 35` to `READSB_ARGS` and set `READSB_AUTOGAIN=false`
- If using a powered antenna, ensure `READSB_BIASTEE=true` is set
- Look for RF interference: try a different location or antenna orientation

### JSON output not updating

**Check if readsb is running:**

```bash
docker exec readsb ps aux | grep readsb
```

**Verify write permissions:**

```bash
docker exec readsb ls -la /run/readsb/
```

JSON directory should be writable by the container user.

### High CPU usage or memory growth

**Profile the container:**

```bash
docker stats readsb --no-stream
```

**Troubleshooting steps:**

- Reduce JSON output frequency: Add `--write-json-every 5` (updates every 5 seconds instead of 1)
- Check for decode storms: Monitor aircraft count with `watch 'docker exec readsb jq .aircraft.length /run/readsb/aircraft.json'`
- Restart container: `docker restart readsb`

### Device permission errors (non-root mode)

RTL-SDR USB device permissions are fixed automatically during container init. If you still see permission errors:

```bash
# Verify RTL-SDR devices are visible inside the container
docker exec readsb lsusb | grep -i realtek

# Check device permissions were applied
docker exec readsb ls -la /dev/bus/usb/*/*
```

**If devices are not visible**, ensure the `devices:` mapping is correct in your compose file. On some hosts, you may need to restart the container after plugging in the dongle.

### Port conflicts

If ports are already in use, map to different host ports:

```bash
docker run ... \
  -p 30011:30001 \
  -p 30012:30002 \
  -p 30013:30003 \
  ...
```

Then update client connections to use the new ports.

### Getting help

- Check [upstream readsb documentation](https://github.com/wiedehopf/readsb)
- Review container logs: `docker logs -f readsb`
- Open an issue on [GitHub](https://github.com/blackoutsecure/docker-readsb/issues)

---

## Health Monitoring

The container includes built-in health monitoring at multiple levels:

### Docker HEALTHCHECK

The image includes a `HEALTHCHECK` that verifies `aircraft.json` exists and was updated within the last 60 seconds. Docker marks the container as `unhealthy` after 3 consecutive failures. This check is **profile-agnostic** — the same healthcheck applies regardless of which feed profiles are active, since all profiles share the same underlying readsb decoder and `aircraft.json` output.

| Setting | Value |
|---|---|
| Interval | 30s |
| Timeout | 5s |
| Start period | 60s |
| Retries | 3 |

```bash
# Check container health status
docker inspect --format='{{.State.Health.Status}}' readsb

# View health check history
docker inspect --format='{{json .State.Health}}' readsb | jq .
```

### s6 Service Supervision

All long-running services are supervised by s6-overlay and automatically restarted on crash:

```bash
# Check individual service status (equivalent of systemctl status)
docker exec readsb s6-svstat /run/service/svc-readsb
docker exec readsb s6-svstat /run/service/svc-feed-stats
docker exec readsb s6-svstat /run/service/svc-autogain
```

### Periodic Console Stats

`svc-feed-stats` logs a summary every 2 minutes by default (configurable via `STATS_LOG_INTERVAL`). Stats logging works with **all feed profiles** — it is not limited to adsbexchange:

```
svc-feed-stats[info]: stats: 42 aircraft tracked (38 with position), 128456 messages total
```

To change the interval, set `STATS_LOG_INTERVAL` to the desired number of seconds (e.g. `60` for every minute, `300` for every 5 minutes). To disable stats logging entirely, set `FEED_STATS_ENABLED=false`.

### Quick Status Commands

```bash
# Container health
docker inspect --format='{{.State.Health.Status}}' readsb

# Aircraft count
docker exec readsb cat /run/readsb/aircraft.json | jq '.aircraft | length'

# Current autogain value
docker exec readsb cat /config/autogain-gain

# Feed UUID (per-profile)
docker exec readsb cat /config/feed-uuid-adsbexchange

# List all profile UUIDs
docker exec readsb ls /config/feed-uuid-*

# Service uptime (all services)
docker exec readsb s6-svstat /run/service/svc-readsb
docker exec readsb s6-svstat /run/service/svc-feed-stats
docker exec readsb s6-svstat /run/service/svc-autogain

# RTL-SDR dongle test
docker exec readsb rtl_test -t

# Tag a dongle serial
docker exec readsb rtl_eeprom -d 0 -s 00001090

# Check bias-T status
docker exec readsb rtl_biast -b 1    # enable
docker exec readsb rtl_biast -b 0    # disable
```

---

## Release & Versioning

This project uses [semantic versioning](https://semver.org/):

- Releases published on [GitHub Releases](https://github.com/blackoutsecure/docker-readsb/releases)
- Multi-arch images (amd64, arm64v8) built automatically
- Docker Hub tags: version-specific, `latest`, and architecture-specific

**Update to latest:**

```bash
docker pull blackoutsecure/readsb:latest
docker-compose up -d  # if using compose
```

**Check image version:**

```bash
docker inspect -f '{{ index .Config.Labels "build_version" }}' blackoutsecure/readsb:latest
```

---

## Support & Getting Help

- **❓ Questions:** [GitHub Issues](https://github.com/blackoutsecure/docker-readsb/issues)
- **🐛 Bug Reports:** Include Docker version, container logs, and reproduction steps
- **📖 Upstream Documentation:** [readsb on GitHub](https://github.com/wiedehopf/readsb)
- **💬 Community:** [LinuxServer.io Discord](https://linuxserver.io/discord)

**Get help:**

```bash
docker logs readsb                          # View container logs
docker exec -it readsb /bin/bash           # Access container shell
docker inspect blackoutsecure/readsb       # Check image details
```

---

## Sponsor & Credits

Sponsored and maintained by [Blackout Secure](https://blackoutsecure.app)

Upstream project: [wiedehopf/readsb](https://github.com/wiedehopf/readsb)  
Container patterns: [LinuxServer.io](https://linuxserver.io/)

---

## References

### Project Resources

| Resource | Link |
| --- | --- |
| **Docker Hub** | [blackoutsecure/readsb](https://hub.docker.com/r/blackoutsecure/readsb) |
| **GitHub Issues** | [Report bugs or request features](https://github.com/blackoutsecure/docker-readsb/issues) |
| **GitHub Releases** | [Download releases](https://github.com/blackoutsecure/docker-readsb/releases) |

### Upstream & Related

| Project | Link |
| --- | --- |
| **readsb** | [wiedehopf/readsb](https://github.com/wiedehopf/readsb) |
| **LinuxServer.io** | [linuxserver.io](https://linuxserver.io/) |

### Technical Resources

- [ADS-B Overview](https://en.wikipedia.org/wiki/Automatic_Dependent_Surveillance%E2%80%93Broadcast)
- [Docker Documentation](https://docs.docker.com/)
- [RTL-SDR Dongles](https://www.rtl-sdr.com/)

---

## License

This project is licensed under the GNU General Public License v3.0 or later - see the LICENSE file for details.

The readsb application itself is also licensed under GPL-3.0-or-later. For more information, see the [readsb repository](https://github.com/wiedehopf/readsb).

---

*Made with ❤️ by [Blackout Secure](https://blackoutsecure.app)*
