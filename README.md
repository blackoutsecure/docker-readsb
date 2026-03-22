[linuxserver.io](https://linuxserver.io/)

[Blog](https://blog.linuxserver.io/) [Discord](https://linuxserver.io/discord) [Discourse](https://discourse.linuxserver.io/) [GitHub](https://github.com/linuxserver) [Open Collective](https://opencollective.com/linuxserver)

The [LinuxServer.io](https://linuxserver.io/) team brings you another container release featuring:

* regular and timely application updates
* easy user mappings (PGID, PUID)
* custom base image with s6 overlay
* weekly base OS updates with common layers across the entire LinuxServer.io ecosystem to minimise space usage, down time and bandwidth
* regular security updates

Find us at:

* [Blog](https://blog.linuxserver.io/) - all the things you can do with our containers including How-To guides, opinions and much more!
* [Discord](https://linuxserver.io/discord) - realtime support / chat with the community and the team.
* [Discourse](https://discourse.linuxserver.io/) - post on our community forum.
* [GitHub](https://github.com/linuxserver) - view the source for all of our repositories.
* [Open Collective](https://opencollective.com/linuxserver) - please consider helping us by either donating or contributing to our budget

---

# [linuxserver/readsb](https://github.com/blackoutsecure/docker-readsb)

[![Discord](https://img.shields.io/discord/354974912613449730.svg?style=flat-square&color=E7931D&logo=discord&logoColor=FFFFFF)](https://linuxserver.io/discord)
[![GitHub Release](https://img.shields.io/github/release/blackoutsecure/docker-readsb.svg?style=flat-square&color=E7931D&logo=github&logoColor=FFFFFF)](https://github.com/blackoutsecure/docker-readsb/releases)

LinuxServer.io style containerized build of [readsb](https://github.com/wiedehopf/readsb), a high-performance ADS-B decoder with RTL-SDR support. Outputs JSON and network feeds, running in a hardened LinuxServer.io-based environment for reliable aircraft signal decoding.

---

## Supported Architectures

We utilise the docker manifest for multi-platform awareness. More information is available from docker [here](https://distribution.github.io/distribution/spec/manifest-v2-2/#manifest-list) and our announcement [here](https://blog.linuxserver.io/2019/02/21/the-lsio-pipeline-project/).

Simply pulling `ghcr.io/blackoutsecure/readsb:latest` should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

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
    image: ghcr.io/blackoutsecure/readsb:latest
    container_name: readsb
    environment:
      - TZ=Etc/UTC
      - READSB_USER=root
      - READSB_ARGS=--net --device-type rtlsdr --gain auto
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
      - /dev/bus/usb:/dev/bus/usb  # RTL-SDR device
    restart: unless-stopped
    read_only: false
    tmpfs:
      - /tmp
      - /run
```

### docker-compose with RTL-SDR over network (e.g., from a remote receiver)

```yaml
---
services:
  readsb:
    image: ghcr.io/blackoutsecure/readsb:latest
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
  -e READSB_USER=root \
  -e READSB_ARGS="--net --device-type rtlsdr --gain auto" \
  -p 30001:30001 \
  -p 30002:30002 \
  -p 30003:30003 \
  -p 30004:30004 \
  -p 30005:30005 \
  -p 30104:30104 \
  -v /path/to/readsb/config:/config \
  -v /path/to/readsb/json:/run/readsb \
  --device=/dev/bus/usb:/dev/bus/usb \
  --read-only=false \
  --user root \
  --tmpfs /tmp \
  --tmpfs /run \
  --restart unless-stopped \
  ghcr.io/blackoutsecure/readsb:latest
```

### Balena Deployment

This image can be deployed to Balena-powered IoT devices. Use the included `balena-compose.yml` file for deployment:

```bash
balena push <your-fleet-name>
```

The balena-compose configuration includes:
- Privileged access and host networking for RTL-SDR USB device access
- Kernel modules and firmware support via Balena labels
- D-Bus and Supervisor API features for system integration

Key Balena features enabled:
- `io.balena.features.kernel-modules: '1'` - RTL-SDR kernel driver support
- `io.balena.features.firmware: '1'` - Firmware loading capability  
- `network_mode: host` - Direct hardware access
- `privileged: true` - Full device access for USB SDR

For more information on Balena deployment, see the [Balena documentation](https://docs.balena.io/).

### Balena Block Publication

This project is registered as a public Balena Block and is available on [balenaHub](https://hub.balena.io/blocks). 

#### For Block Maintainers

To release new versions of this block:

```bash
# Push a new release
balena push <block-name>
```

Release management is handled via the Balena Dashboard:
- New releases are tracked and can be set as default
- Each release can be pinned or set to track latest
- Manage block visibility in Settings (toggle to make public)

#### For Block Users

To use this block in your Balena fleet, add it to your `docker-compose.yml`:

```yaml
services:
  readsb:
    image: bh.cr/balenablocks/readsb-aarch64
    privileged: true
    network_mode: host
    environment:
      - TZ=Etc/UTC
      - READSB_ARGS=--net --device-type rtlsdr --gain auto
    volumes:
      - config:/config
    devices:
      - /dev/bus/usb:/dev/bus/usb
    ports:
      - "30001:30001"
      - "30002:30002"
      - "30003:30003"
      - "30004:30004"
      - "30005:30005"
      - "30104:30104"
    restart: unless-stopped
```

Available image references:
- `bh.cr/balenablocks/readsb-aarch64` - Latest aarch64 (ARM 64-bit)
- `bh.cr/balenablocks/readsb-aarch64:1.0.0` - Specific version (aarch64)
- `bh.cr/balenablocks/readsb-amd64` - Latest amd64 (x86-64)

---

## Parameters

Containers are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 30001:30001` | Raw protocol output (TCP) |
| `-p 30002:30002` | Raw protocol input (TCP) |
| `-p 30003:30003` | SBS protocol compatible output (TCP) |
| `-p 30004:30004` | Beast protocol output (TCP) |
| `-p 30005:30005` | Beast protocol input (TCP) |
| `-p 30104:30104` | JSON protocol output (TCP) |
| `-e TZ=Etc/UTC` | specify a timezone to use, see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). |
| `-e READSB_USER=root` | Default user. Root is recommended for USB RTL-SDR compatibility. |
| `-e READSB_ARGS=` | Additional arguments for readsb (see Application Setup) |
| `-e PUID=911` | Optional UserID when `READSB_USER` is set to a non-root user. |
| `-e PGID=911` | Optional GroupID when `READSB_USER` is set to a non-root user. |
| `-v /config` | Configuration directory for database and persistent data |
| `-v /run/readsb` | JSON output directory |
| `--device=/dev/bus/usb:/dev/bus/usb` | RTL-SDR USB device access |
| `--read-only=false` | Default mode. Recommended for most RTL-SDR USB deployments. |
| `--user root` | Default user for reliable USB device access. |

---

## Environment variables from files (Docker secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

As an example:

```bash
-e FILE__MYVAR=/run/secrets/mysecretvariable
```

Will set the environment variable `MYVAR` based on the contents of the `/run/secrets/mysecretvariable` file.

---

## Umask for running applications

For all of our images we provide the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting. Keep in mind umask is not chmod it subtracts from permissions based on it's value it does not add. Please read up [here](https://en.wikipedia.org/wiki/Umask) before asking for support.

---

## User / Group Identifiers

By default, this container runs as `root` (`READSB_USER=root`) for best USB RTL-SDR compatibility.

In root mode, you do not need to set `PUID` or `PGID`.

If you choose non-root operation, set `READSB_USER` to your target username and provide matching `PUID` and `PGID`.

If you set `READSB_USER=abc` and omit `PUID`/`PGID`, the runtime defaults to `911:911`.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id your_user` as below:

```bash
id your_user
```

Example output:

```
uid=1000(your_user) gid=1000(your_user) groups=1000(your_user)
```

---

## Application Setup

The container is pre-configured to run readsb with network support enabled. By default, it will:

* Listen for RTL-SDR devices and attempt auto-detection
* Output ADS-B data in multiple protocol formats to exposed ports
* Write JSON-formatted output to `/run/readsb/` for consumption by other applications
* Apply automatic gain control (AGC)
* Use jemalloc for improved memory efficiency

### Port Descriptions

* **30001**: Raw protocol output (TCP) - 8-bit binary messages
* **30002**: Raw protocol input (TCP) - Allows remote input of Mode S messages
* **30003**: SBS protocol output (TCP) - Compatible with aircraft tracking software like PlanePlotter and VirtualRadar
* **30004**: Beast protocol output (TCP) - Compact binary protocol with timestamps
* **30005**: Beast protocol input (TCP) - Allows remote Beast protocol input
* **30104**: JSON protocol output (TCP) - JSON-formatted ADS-B data suitable for web applications

### RTL-SDR Device Setup

To use an RTL-SDR USB dongle:

1. Pass the USB device(s) to the container: `--device=/dev/bus/usb:/dev/bus/usb`
2. Optionally modify `READSB_ARGS` to set specific RTL-SDR parameters

### Customizing readsb Arguments

The `READSB_ARGS` environment variable allows you to customize readsb behavior:

### READSB_ARGS Breakdown

Defaults in this table mean behavior when that specific item is omitted from your `READSB_ARGS` value.

| Item | Required/Optional | Default Value | Description |
| --- | --- | --- | --- |
| `--net` | Optional (recommended) | Disabled | Enables network services (inputs/outputs) for readsb. |
| `--device-type rtlsdr` | Conditionally required (local RTL-SDR input) | No SDR device selected (none) | Selects RTL-SDR as the local receiver source. Remove for network-only operation. |
| `--gain auto` | Optional | Auto gain (for `--device-type rtlsdr`) | Uses automatic tuner gain selection for RTL-SDR. |
| `--write-json /run/readsb` | Optional (recommended) | `/run/readsb` | Writes JSON output files used by local web/consumer tools into `/run/readsb`. |
| `--write-json-every 1` | Optional | 1 second | JSON output interval in seconds. 1 provides near-real-time updates. |
| `--db-file /usr/local/share/tar1090/aircraft.csv.gz` | Optional (recommended) | `/usr/local/share/tar1090/aircraft.csv.gz` | Uses the bundled tar1090 aircraft database for enriched aircraft metadata. |

```bash
# Set fixed gain (in dB)
-e READSB_ARGS="--net --device-type rtlsdr --gain 40"

# Add frequency correction (in PPM)
-e READSB_ARGS="--net --device-type rtlsdr --freq-correction 10 --gain auto"

# Set location for aircraft range calculations
-e READSB_ARGS="--net --device-type rtlsdr --lat 51.5 --lon -0.1"

# Include ICAO filtering
-e READSB_ARGS="--net --device-type rtlsdr --mode-ac-auto"

# Full example with multiple options
-e READSB_ARGS="--net --device-type rtlsdr --gain auto --lat 51.5 --lon -0.1 --max-range 350"
```

For a comprehensive list of available options, see the [readsb documentation](https://github.com/wiedehopf/readsb).

### JSON Output

The container outputs JSON data to `/run/readsb/`. This directory contains:

* `aircraft.json` - Current aircraft data with positions, callsigns, and altitudes
* `receiver.json` - Statistics and receiver information

These files are updated frequently and can be consumed by visualization tools or other applications.

### Database and Persistent Data

The `/config` volume stores:

* Aircraft database (aircraft.csv.gz)
* Application state and caches
* Any custom configuration files

### Using with tar1090

The container includes the [tar1090 aircraft database](https://github.com/wiedehopf/tar1090-db) for accurate aircraft identification. This database is automatically updated with container updates.

### Read-Only Operation

This image can be run with a read-only container filesystem. For details please [read the docs](https://docs.linuxserver.io/misc/read-only/).

#### Caveats

* JSON output directory must be mounted to a host path or tmpfs
* Temporary directories must be writable (typically via tmpfs mount)

### Non-Root Operation

This image can be run with a non-root user. For details please [read the docs](https://docs.linuxserver.io/misc/non-root/).

#### Caveats

* RTL-SDR device access requires proper permissions for the user
* JSON output directory must be writable by the non-root user

### Default Runtime Mode

By default this image now runs as `root` and with `read_only: false` to maximize RTL-SDR USB compatibility out of the box.

---

## Docker Mods

[Docker Mods](https://mods.linuxserver.io/) | [Docker Universal Mods](https://mods.linuxserver.io/?mod=universal)

We publish various [Docker Mods](https://github.com/linuxserver/docker-mods) to enable additional functionality within the containers. The list of Mods available for this image (if any) as well as universal mods that can be applied to any one of our images can be accessed via the links above.

---

## Support Info

* Shell access whilst the container is running: `docker exec -it readsb /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f readsb`
* Container version number: `docker inspect -f '{{ index .Config.Labels "build_version" }}' readsb`
* Image version number: `docker inspect -f '{{ index .Config.Labels "build_version" }}' ghcr.io/blackoutsecure/readsb:latest`

---

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. With some exceptions (noted in the relevant readme.md), we do not recommend or support updating apps inside the container. Please consult the Application Setup section above to see if it is recommended for the image.

Below are the instructions for updating containers:

### Via Docker Compose

* Update images:
  * All images: `docker-compose pull`
  * Single image: `docker-compose pull readsb`
* Update containers:
  * All containers: `docker-compose up -d`
  * Single container: `docker-compose up -d readsb`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Run

* Update the image: `docker pull ghcr.io/blackoutsecure/readsb:latest`
* Stop the running container: `docker stop readsb`
* Delete the container: `docker rm readsb`
* Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images: `docker image prune`

### Image Update Notifications - Diun (Docker Image Update Notifier)

We recommend [Diun](https://crazymax.dev/diun/) for update notifications. Other tools that automatically update containers unattended are not recommended or supported.

---

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:

Build-time source defaults:

* READSB_REPO_URL=[https://github.com/wiedehopf/readsb](https://github.com/wiedehopf/readsb)
* READSB_REPO_BRANCH=dev

You can override these at build time if you want to test another fork or branch.

```bash
git clone https://github.com/blackoutsecure/docker-readsb.git
cd docker-readsb
docker build \
  --no-cache \
  --pull \
  --build-arg READSB_REPO_URL=https://github.com/wiedehopf/readsb \
  --build-arg READSB_REPO_BRANCH=dev \
  -t ghcr.io/blackoutsecure/readsb:latest .
```

The ARM variants can be built on x86_64 hardware and vice versa using `ghcr.io/linuxserver/qemu-static`

```bash
docker run --rm --privileged ghcr.io/linuxserver/qemu-static --reset
```

Once registered you can define the dockerfile to use with `-f Dockerfile.aarch64`.

---

## Versions

* **22.03.26:** - Initial release - based on LinuxServer.io standards with hardened defaults
* **20.03.26:** - Dockerfile optimization and multi-stage build implementation

---

## License

This project is licensed under the GNU General Public License v3.0 or later - see the LICENSE file for details.

The readsb application itself is also licensed under GPL-3.0. For more information, see the [readsb repository](https://github.com/wiedehopf/readsb).

---

## References

* [readsb GitHub Repository](https://github.com/wiedehopf/readsb)
* [tar1090 Database](https://github.com/wiedehopf/tar1090-db)
* [LinuxServer.io Discord](https://linuxserver.io/discord)
* [LinuxServer.io Blog](https://blog.linuxserver.io/)
* [ADS-B Information](https://en.wikipedia.org/wiki/Automatic_Dependent_Surveillance%E2%80%93Broadcast)
* [Mode S Protocol](https://en.wikipedia.org/wiki/Mode%20S)
