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
- [Troubleshooting](#troubleshooting)
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
| `-e PUID=1000` | User ID for file ownership (LinuxServer.io base image standard) | Optional |
| `-e PGID=1000` | Group ID for file ownership (LinuxServer.io base image standard) | Optional |
| `-e READSB_DEVICE=` | RTL-SDR device index or serial for 1090 MHz (overrides auto-detection) | Optional |
| `-e FEED_PROFILES=` | Comma-separated feed exchanges (e.g. `adsbexchange,adsb-fi`). Defaults to `adsbexchange` if unset. | Optional |
| `-e FEED_UUID=` | Feeder UUID (auto-generated on first run, persisted in `/config/feed-uuid`) | Optional |
| `-e FEED_STATS_ENABLED=true` | Enable ADSBx stats upload (requires `adsbexchange` in `FEED_PROFILES`) | Optional |
| `-e FEED_UAT_INPUT=` | UAT 978 MHz source as `host:port` (e.g. `dump978:30978`). Requires [docker-dump978](https://github.com/blackoutsecure/docker-dump978) sidecar. US only. | Optional |
| `-e FEED_LAT=` | Receiver latitude (e.g. `47.6062`). Fallback if `--lat` not in `READSB_ARGS`. | Optional |
| `-e FEED_LON=` | Receiver longitude (e.g. `-122.3321`). Fallback if `--lon` not in `READSB_ARGS`. | Optional |
| `-e READSB_AUTO_LOCATION=true` | Auto-detect latitude/longitude via IP geolocation when `FEED_LAT`/`FEED_LON` not set. | Optional |

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
- **RTL-SDR Support**: USB devices are auto-detected when passed to the container
- **Aircraft Database**: Includes [tar1090 aircraft database](https://github.com/wiedehopf/tar1090-db) for accurate identification
- **Automatic Gain Control**: Enabled by default for rtlsdr devices (configurable via `READSB_ARGS`)

### Customizing READSB_ARGS

The `READSB_ARGS` environment variable allows you to customize readsb behavior. By default (for rtlsdr devices), automatic gain control is enabled.

**Common examples:**

```bash
# RTL-SDR with default automatic gain
-e READSB_ARGS="--net --device-type rtlsdr"

# Network-only mode (no local RTL-SDR)
-e READSB_ARGS="--net --lat 51.5 --lon -0.1"

# Fixed gain setting (overrides automatic)
-e READSB_ARGS="--net --device-type rtlsdr --gain 35 --freq-correction 10"

# Location-aware with max range
-e READSB_ARGS="--net --device-type rtlsdr --lat 51.5 --lon -0.1 --max-range 350"
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
| `FEED_UUID` | (auto-generated) | Feeder UUID. Auto-generated on first run and persisted in `/config/feed-uuid`. Set this to force a specific UUID. |
| `FEED_STATS_ENABLED` | `true` | Enable stats upload to ADS-B Exchange (only used when `adsbexchange` is in `FEED_PROFILES`). |
| `FEED_UAT_INPUT` | (empty) | UAT 978 MHz data source as `host:port` (e.g. `dump978:30978`). Only applies in the US. |
| `FEED_LAT` | (empty) | Receiver latitude in decimal degrees. Used as fallback if `--lat` is not in `READSB_ARGS`. |
| `FEED_LON` | (empty) | Receiver longitude in decimal degrees. Used as fallback if `--lon` is not in `READSB_ARGS`. |
| `READSB_AUTO_LOCATION` | `true` | Auto-detect latitude/longitude via IP geolocation when `FEED_LAT`/`FEED_LON` are not set. Set to `false` to disable. |

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

| Profile name | MLAT server endpoint |
|---|---|
| `adsbexchange` | `feed.adsbexchange.com:31090` |
| `adsb-fi` | `feed.adsb.fi:31090` |
| `airplaneslive` | `feed.airplanes.live:31090` |
| `planewatch` | `mlat.plane.watch:31090` |
| `flyitalyadsb` | `dati.flyitalyadsb.com:30100` |
| `radarplane` | `mlat.radarplane.com:40900` |

### Quick Start — Single Exchange

```yaml
services:
  readsb:
    image: blackoutsecure/readsb:latest
    container_name: readsb
    environment:
      - TZ=Etc/UTC
      - READSB_ARGS=--net --device-type rtlsdr
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
      - MLAT_CLIENT_LAT=51.5074
      - MLAT_CLIENT_LON=-0.1278
      - MLAT_CLIENT_ALT=50m
      - MLAT_CLIENT_USER_ID=myfeeder-london
      - MLAT_CLIENT_RESULTS=beast,connect,readsb:30104
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
      - MLAT_CLIENT_LAT=51.5074
      - MLAT_CLIENT_LON=-0.1278
      - MLAT_CLIENT_ALT=50m
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
      - MLAT_CLIENT_LAT=51.5074
      - MLAT_CLIENT_LON=-0.1278
      - MLAT_CLIENT_ALT=50m
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
      - MLAT_CLIENT_LAT=51.5074
      - MLAT_CLIENT_LON=-0.1278
      - MLAT_CLIENT_ALT=50m
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

- **MLAT**: MLAT positioning requires a separate `mlat-client` container per exchange. The readsb container handles Beast data forwarding only. See the MLAT server table above for the correct server endpoint per exchange.

- **UUID**: The feed UUID is auto-generated on first run and persisted in `/config/feed-uuid`. It is shared across all active feed profiles. To view your UUID: `docker exec readsb cat /config/feed-uuid`

- **Checking feed status**:
  - ADSBx: https://adsbexchange.com/myip/
  - adsb.fi: https://adsb.fi/
  - airplanes.live: https://airplanes.live/

> **Note:** IP-based geolocation is approximate (typically city-level accuracy). Elevation is ground-level at the detected coordinates. For best MLAT results, set your exact coordinates manually.

> **Note on altitude:** The auto-detected altitude represents **ground elevation** at the detected coordinates, not your antenna height above sea level. For accurate MLAT, your altitude should include the height of your antenna above ground. For example, if ground elevation is `50m` and your antenna is on a `10m` rooftop mast, set `MLAT_CLIENT_ALT=60m`. When relying on auto-detection, consider adding your antenna height manually for better multilateration accuracy.

---

## Troubleshooting

### Log Format

All log output uses syslog format so you can identify the source and severity of each line in `docker logs`, and it integrates natively with log aggregators (Loki, Datadog, Fluentd, etc.):

```
<timestamp> <service>[<priority>]: <message>
```

```
2026-04-02T11:38:20Z init-readsb-config[info]: Feed UUID: 12345678-1234-1234-1234-123456789abc
2026-04-02T11:38:20Z init-readsb-config[info]: Active feed profiles: adsbexchange,adsb-fi
2026-04-02T11:38:20Z init-readsb-config[info]: receiver location: 51.5074, -0.1278
2026-04-02T11:38:21Z svc-readsb[info]: readsb container startup configuration
2026-04-02T11:38:21Z svc-readsb[decoder]: *8daa4b32584385ef2a7603346e29;
2026-04-02T11:38:21Z svc-readsb[decoder]: hex:  aa4b32   CRC: 000000 fixed bits: 0 decode: ok
2026-04-02T11:38:21Z svc-readsb[decoder]: RSSI:    -22.0 dBFS   reduce_forward: 1
2026-04-02T11:38:22Z svc-feed-stats[info]: Starting ADSBx stats upload -- UUID=12345678-...
2026-04-02T11:38:52Z svc-feed-stats[warn]: /run/readsb/aircraft.json not updated in 45s.
```

| Service | Description |
|---|---|
| `init-readsb-config` | One-shot init: UUID generation, feed profile setup, geolocation |
| `svc-readsb` | Main readsb decoder service (startup config + decoder output) |
| `svc-feed-stats` | ADSBExchange stats upload loop |

| Priority | Meaning |
|---|---|
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
docker logs readsb 2>&1 | grep '\[warn\]:'
docker logs readsb 2>&1 | grep '\[error\]:\|\[fatal\]:'
docker logs readsb 2>&1 | grep '\[decoder\]:'
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

### No aircraft data appearing

**Verify connectivity:**

```bash
docker exec readsb cat /run/readsb/aircraft.json | jq '.aircraft | length'
```

**If count is 0:**

- Check RTL-SDR device: `docker exec readsb rtl_test -t`
- Verify antenna is connected and positioned properly
- Try manual gain: Set `--gain 35` (or other value 0-49) if auto-gain isn't performing well
- Look for RF interference: Try a different location or antenna orientation

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
