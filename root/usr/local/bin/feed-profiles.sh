#!/usr/bin/env bash
# /usr/local/bin/feed-profiles.sh
# Shared feed profile definitions — sourced by init and svc scripts.
# Do NOT execute directly.

# Parse FEED_PROFILES comma-separated string into an array.
# Usage: parse_feed_profiles -> sets FEED_PROFILE_LIST array
parse_feed_profiles() {
    FEED_PROFILE_LIST=()
    local profiles="${FEED_PROFILES:-adsbexchange}"
    if [[ -z "${profiles}" ]]; then
        return
    fi
    IFS=',' read -ra FEED_PROFILE_LIST <<< "${profiles}"
    # Trim whitespace and lowercase each entry
    local i
    for i in "${!FEED_PROFILE_LIST[@]}"; do
        FEED_PROFILE_LIST[$i]=$(echo "${FEED_PROFILE_LIST[$i]}" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    done
}

# Check if a specific profile is active
# Usage: has_feed_profile "adsbexchange" && echo yes
has_feed_profile() {
    local target="$1"
    local p
    for p in "${FEED_PROFILE_LIST[@]}"; do
        if [[ "${p}" == "${target}" ]]; then
            return 0
        fi
    done
    return 1
}

# Return the --net-connector arg for a given profile name.
# Returns empty string for unknown profiles.
get_feed_connector() {
    local profile="$1"
    case "${profile}" in
        adsbexchange)   echo "feed1.adsbexchange.com,30004,beast_reduce_out" ;;
        adsb-fi)        echo "feed.adsb.fi,30004,beast_reduce_out" ;;
        airplaneslive)  echo "feed.airplanes.live,30004,beast_reduce_out" ;;
        planewatch)     echo "atc.plane.watch,30004,beast_reduce_out" ;;
        opensky)        echo "feed.opensky-network.org,30005,beast_reduce_out" ;;
        flyitalyadsb)   echo "dati.flyitalyadsb.com,4905,beast_reduce_out" ;;
        adsbhub)        echo "data.adsbhub.org,5002,beast_reduce_out" ;;
        radarplane)     echo "feed.radarplane.com,30001,beast_reduce_out" ;;
        *)              echo "" ;;
    esac
}

# Return secondary/failover --net-connector for profiles that have one.
# Returns empty string if the profile has no failover endpoint.
get_feed_connector_secondary() {
    local profile="$1"
    case "${profile}" in
        adsbexchange)   echo "feed2.adsbexchange.com,64004,beast_reduce_out" ;;
        *)              echo "" ;;
    esac
}

# Return the MLAT server endpoint for a given profile (for documentation/logging only)
get_mlat_server() {
    local profile="$1"
    case "${profile}" in
        adsbexchange)   echo "feed.adsbexchange.com:31090" ;;
        adsb-fi)        echo "feed.adsb.fi:31090" ;;
        airplaneslive)  echo "feed.airplanes.live:31090" ;;
        planewatch)     echo "mlat.plane.watch:31090" ;;
        flyitalyadsb)   echo "dati.flyitalyadsb.com:30100" ;;
        radarplane)     echo "mlat.radarplane.com:40900" ;;
        *)              echo "" ;;
    esac
}

# Return the feed status/verification URL for a given profile.
# Usage: get_feed_status_url "adsbexchange" -> URL or empty
get_feed_status_url() {
    local profile="$1"
    case "${profile}" in
        adsbexchange)   echo "https://adsbexchange.com/myip/" ;;
        adsb-fi)        echo "https://adsb.fi/status" ;;
        airplaneslive)  echo "https://airplanes.live/" ;;
        planewatch)     echo "https://plane.watch/" ;;
        flyitalyadsb)   echo "https://flyitalyadsb.com/" ;;
        radarplane)     echo "https://radarplane.com/" ;;
        *)              echo "" ;;
    esac
}

# Convert a profile name to an uppercase env-var suffix.
# e.g. "adsb-fi" -> "ADSB_FI", "adsbexchange" -> "ADSBEXCHANGE"
get_profile_env_suffix() {
    local profile="$1"
    echo "${profile}" | tr '[:lower:]' '[:upper:]' | tr '-' '_'
}

# Return the UUID file path for a given profile.
# e.g. "adsbexchange" -> /config/feed-uuid-adsbexchange
get_profile_uuid_file() {
    local profile="$1"
    echo "/config/feed-uuid-${profile}"
}

# Read the UUID for a given profile from its file.
# Returns empty string if file does not exist.
get_profile_uuid() {
    local profile="$1"
    local uuid_file
    uuid_file=$(get_profile_uuid_file "${profile}")
    if [[ -f "${uuid_file}" ]]; then
        tr -d '[:space:]' < "${uuid_file}"
    fi
}

# ── MLAT (Multilateration) ────────────────────────────────────────────────────
# MLAT requires a separate mlat-client process that connects to the readsb
# beast output (port 30005) and to the aggregator's MLAT server.
#
# IMPORTANT: mlat-client MUST use the SAME UUID as the beast feed so the
# aggregator can correlate both data streams into a single feeder identity.
# For ADSBexchange, the official mlat-client accepts --uuid-file pointing
# to the same file used by readsb (/config/feed-uuid-adsbexchange).
#
# mlat-client also requires:
#   --user <NAME>        Human-readable feeder name (shown on MLAT map)
#   --lat / --lon / --alt Precise antenna location (15m/45ft accuracy needed)
#   --server <HOST:PORT> MLAT server endpoint (see get_mlat_server below)
#
# Since mlat-client is a separate binary (Python), it runs as a sidecar
# container sharing the /config volume for UUID access.
#   TODO: Create blackoutsecure/mlat-client container image.

# ── Profiles requiring separate containers (not supported via --net-connector) ──
# These aggregators use proprietary binaries/protocols and require a dedicated
# sidecar container that reads Beast data from readsb on port 30005.
#
# FlightAware — requires piaware container with a feeder-id.
#   Upstream: https://github.com/flightaware/piaware
#   TODO: Create blackoutsecure/piaware container image.
#
# FlightRadar24 — requires fr24feed container with a sharing key.
#   Upstream: https://www.flightradar24.com/share-your-data
#   TODO: Create blackoutsecure/fr24feed container image.
#
# Radarbox — requires rbfeeder container with a sharing key.
#   Upstream: https://www.radarbox.com/sharing-data
#   TODO: Create blackoutsecure/rbfeeder container image.
#
# Planefinder — requires pfclient container with a share code.
#   Upstream: https://planefinder.net/sharing/
#   TODO: Create blackoutsecure/pfclient container image.
