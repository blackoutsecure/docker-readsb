#!/usr/bin/env bash
# /usr/local/bin/sdr-enumerate.sh
# Enumerate RTL-SDR dongles and assign the 1090 MHz device for readsb.
# Sourced by init-readsb-config; do NOT execute directly.
#
# 1090 MHz device selection (readsb owns this dongle):
#   READSB_DEVICE  - manual override: device index OR serial (always wins)
#   Auto-detection - first non-UAT-tagged dongle becomes 1090 device
#
# UAT 978 MHz detection (informational only):
#   readsb does NOT decode 978 MHz. If a UAT-tagged dongle is detected,
#   a log hint is emitted pointing to blackoutsecure/docker-dump978.
#   UAT data is ingested via FEED_UAT_INPUT=dump978:30978 (network).
#
# Serial-number convention (community standard):
#   Serial containing "978" or "uat"  -> UAT dongle (logged, not used by readsb)
#   Everything else                   -> 1090 MHz candidate
#
# Outputs:
#   SDR_1090_INDEX   - device index/serial for readsb --device (empty if none)
#   SDR_1090_SERIAL  - serial number of the 1090 dongle (empty if by index)
#   SDR_UAT_DETECTED - "true" if a UAT-tagged dongle was found (informational)
#   SDR_UAT_SERIAL   - serial of the UAT dongle (for logging)
#   SDR_DONGLE_COUNT - total number of RTL-SDR dongles detected
#   SDR_MODE         - "manual", "auto", or "none"

enumerate_sdr_dongles() {
    SDR_1090_INDEX=""
    SDR_1090_SERIAL=""
    SDR_UAT_DETECTED="false"
    SDR_UAT_SERIAL=""
    SDR_DONGLE_COUNT=0
    SDR_MODE="none"

    local manual_device="${READSB_DEVICE:-}"

    # -- Manual assignment (READSB_DEVICE takes priority) --
    if [[ -n "${manual_device}" ]]; then
        SDR_MODE="manual"
        if [[ "${manual_device}" =~ ^[0-9]+$ ]]; then
            SDR_1090_INDEX="${manual_device}"
        else
            # Serial number -- readsb accepts serial via --device
            SDR_1090_INDEX="${manual_device}"
            SDR_1090_SERIAL="${manual_device}"
        fi

        # Still count dongles for logging
        if command -v lsusb >/dev/null 2>&1; then
            SDR_DONGLE_COUNT=$(lsusb 2>/dev/null | grep -icE '0bda:(2832|2838)' || echo 0)
        fi

        return 0
    fi

    # -- Auto-detection --
    if ! command -v lsusb >/dev/null 2>&1; then
        return 1
    fi

    local rtl_devices
    rtl_devices=$(lsusb 2>/dev/null | grep -icE '0bda:(2832|2838)' || true)
    SDR_DONGLE_COUNT="${rtl_devices}"

    if [[ ${SDR_DONGLE_COUNT} -eq 0 ]]; then
        return 0
    fi

    SDR_MODE="auto"

    if command -v rtl_test >/dev/null 2>&1; then
        local idx=0
        while [[ ${idx} -lt ${SDR_DONGLE_COUNT} ]]; do
            local serial
            serial=$(rtl_test -d "${idx}" -t 2>&1 | grep -oP 'SN:\s*\K\S+' | head -1 || true)

            if [[ -z "${serial}" ]]; then
                serial=$(rtl_eeprom -d "${idx}" 2>&1 | grep -oP 'Serial number:\s*\K\S+' | head -1 || true)
            fi

            local serial_lower="${serial,,}"

            if [[ "${serial_lower}" == *"978"* || "${serial_lower}" == *"uat"* ]]; then
                # UAT dongle -- log it but don't assign to readsb
                SDR_UAT_DETECTED="true"
                SDR_UAT_SERIAL="${serial}"
            elif [[ -z "${SDR_1090_INDEX}" ]]; then
                SDR_1090_INDEX="${idx}"
                SDR_1090_SERIAL="${serial}"
            fi

            idx=$((idx + 1))
        done
    else
        # No rtl_test: single dongle -> assume 1090
        if [[ ${SDR_DONGLE_COUNT} -eq 1 ]]; then
            SDR_1090_INDEX=0
        fi
    fi

    return 0
}
