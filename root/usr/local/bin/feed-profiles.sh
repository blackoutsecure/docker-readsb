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
        adsbexchange)   echo "feed1.adsbexchange.com,30004,beast_reduce_out,feed2.adsbexchange.com,64004" ;;
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
