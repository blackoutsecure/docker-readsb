<p align="center">
  <img src="https://raw.githubusercontent.com/blackoutsecure/docker-readsb/main/logo.png" alt="readsb logo" width="200">
</p>

# blackoutsecure/readsb

[![GitHub Stars](https://img.shields.io/github/stars/blackoutsecure/docker-readsb?style=flat-square&color=E7931D&logo=github)](https://github.com/blackoutsecure/docker-readsb/stargazers)
[![Docker Pulls](https://img.shields.io/docker/pulls/blackoutsecure/readsb?style=flat-square&color=E7931D&logo=docker&logoColor=FFFFFF)](https://hub.docker.com/r/blackoutsecure/readsb)
[![GitHub Release](https://img.shields.io/github/release/blackoutsecure/docker-readsb.svg?style=flat-square&color=E7931D&logo=github&logoColor=FFFFFF)](https://github.com/blackoutsecure/docker-readsb/releases)
[![Release CI](https://img.shields.io/github/actions/workflow/status/blackoutsecure/docker-readsb/release.yml?style=flat-square&label=release%20ci&color=E7931D)](https://github.com/blackoutsecure/docker-readsb/actions/workflows/release.yml)
[![Docker Hub CI](https://img.shields.io/github/actions/workflow/status/blackoutsecure/docker-readsb/dockerhub-publish.yml?style=flat-square&label=docker%20hub%20ci&color=E7931D)](https://github.com/blackoutsecure/docker-readsb/actions/workflows/dockerhub-publish.yml)
[![Balena CI](https://img.shields.io/github/actions/workflow/status/blackoutsecure/docker-readsb/balenablock-publish.yml?style=flat-square&label=balena%20ci&color=E7931D)](https://github.com/blackoutsecure/docker-readsb/actions/workflows/balenablock-publish.yml)
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
  - [Docker CLI](#docker-cli-click-here-for-more-info)
  - [Balena Deployment](#balena-deployment)
- [Parameters](#parameters)
- [Configuration](#configuration)
- [Application Setup](#application-setup)
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
    restart: unless-stopped
    tmpfs:
      - /tmp
      - /run
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
      - READSB_USER=root
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
    restart: unless-stopped
    read_only: false
    tmpfs:
      - /tmp
      - /run
```

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
  --restart unless-stopped \
  blackoutsecure/readsb:latest
```

### Balena Deployment

This image can be deployed to Balena-powered IoT devices using the included `balena-compose.yml` file:

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
| `-e PUID=911` | User ID for non-root operation | Optional |
| `-e PGID=911` | Group ID for non-root operation | Optional |

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

By default, this container runs as `root` for best USB RTL-SDR device compatibility.

**Root mode (default):**

- No `PUID` or `PGID` needed
- RTL-SDR USB access works out-of-the-box

**Non-root mode (advanced):**

- Set `READSB_USER` to your username
- Provide matching `PUID` and `PGID` values
- Defaults to `911:911` if omitted
- RTL-SDR device access requires proper permissions

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
- **Non-root user**: Supported via `READSB_USER` (requires device permission setup for RTL-SDR access)

---

## Troubleshooting

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

If running with `READSB_USER` set to a non-root user:

```bash
# Find the numeric user/group ID
docker exec readsb id

# Grant USB access to the group (host-side)
sudo usermod -a -G plugdev <username>
```

Then restart container with proper `PUID` and `PGID` environment variables.

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

The readsb application itself is also licensed under GPL-3.0. For more information, see the [readsb repository](https://github.com/wiedehopf/readsb).

---

*Made with ❤️ by [Blackout Secure](https://blackoutsecure.app)*
