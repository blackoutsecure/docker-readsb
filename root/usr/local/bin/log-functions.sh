#!/usr/bin/env bash
# /usr/local/bin/log-functions.sh
# Shared logging library — sourced by init and svc scripts.
# Do NOT execute directly.
#
# Provides syslog-format logging:
#   <timestamp> <service>[<priority>]: <message>
#
# Usage:
#   SVC_NAME="svc-readsb"
#   . /usr/local/bin/log-functions.sh
#   log_info  "starting up"          # → 2026-04-02T11:38:21Z svc-readsb[info]: starting up
#   log_warn  "disk nearly full"     # → 2026-04-02T11:38:21Z svc-readsb[warn]: disk nearly full
#   log_error "connection refused"   # → ... [error]: ...  (also to stderr)
#   log_fatal "cannot continue"      # → ... [fatal]: ...  (also to stderr)
#   log_kv    "KEY" "value"          # → ... [info]: KEY:            value

# Guard: SVC_NAME must be set by the calling script before sourcing.
if [[ -z "${SVC_NAME:-}" ]]; then
    echo "FATAL: SVC_NAME must be set before sourcing log-functions.sh" >&2
    exit 1
fi

# ── Core formatter ────────────────────────────────────────────────────────────
# _log <priority> <fd> <message ...>
_log() {
    local priority="$1"
    local fd="$2"
    shift 2
    printf '%s %s[%s]: %s\n' \
        "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
        "${SVC_NAME}" \
        "${priority}" \
        "$*" >&"${fd}"
}

# ── Public API ────────────────────────────────────────────────────────────────
log_info()  { _log info  1 "$@"; }
log_warn()  { _log warn  2 "$@"; }
log_error() { _log error 2 "$@"; }
log_fatal() { _log fatal 2 "$@"; }

# Key-value pair with aligned columns (stdout, info priority).
log_kv() {
    local key="$1"
    local value="$2"
    printf '%s %s[%s]: %-15s %s\n' \
        "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
        "${SVC_NAME}" \
        "info" \
        "${key}:" \
        "${value}"
}

# ── Decoder log pipe ─────────────────────────────────────────────────────────
# Returns an awk command string that prefixes each stdin line with syslog format.
# Usage:  exec some-binary 2>&1 | eval "$(log_pipe_cmd decoder)"
log_pipe_cmd() {
    local priority="${1:-decoder}"
    # Use awk for per-line timestamping; fflush() prevents buffering.
    printf "awk '{ printf \"%%s %s[%s]: %%s\\\\n\", strftime(\"%%Y-%%m-%%dT%%H:%%M:%%SZ\", systime(), 1), \$0; fflush() }'" \
        "${SVC_NAME}" "${priority}"
}
