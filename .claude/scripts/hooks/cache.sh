#!/bin/bash
# cache.sh - Quality check cache utility with hash-based invalidation
# Provides read/write/invalidate functions for hook caching

# Source common environment library
# shellcheck source=../../lib/env.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/../../lib/env.sh" ]]; then
    source "$SCRIPT_DIR/../../lib/env.sh"
fi

# Cache file location (can be overridden via CACHE_FILE env var)
CACHE_FILE="${CACHE_FILE:-${CONFIG_DIR}/cache/quality-check.json}"

# Cache version
CACHE_VERSION=1

# Cleanup handler for temporary files
cleanup_cache_temp_files() {
    if [ -f "$CACHE_FILE.tmp" ]; then
        rm -f "$CACHE_FILE.tmp" 2>/dev/null || true
    fi
    if [ -f "$CACHE_FILE.lock" ]; then
        rm -f "$CACHE_FILE.lock" 2>/dev/null || true
    fi
}

# Register cleanup trap
trap cleanup_cache_temp_files EXIT INT TERM

# TTL defaults (seconds)
CACHE_TTL="${CACHE_TTL:-3600}"  # 1 hour default
DEBOUNCE_SECONDS="${DEBOUNCE_SECONDS:-10}"  # 10 seconds default

# Initialize cache directory and file
cache_init() {
    local cache_dir
    cache_dir=$(dirname "$CACHE_FILE")

    # Create cache directory if it doesn't exist
    if [ ! -d "$cache_dir" ]; then
        mkdir -p "$cache_dir"
    fi

    # Initialize cache file if it doesn't exist
    if [ ! -f "$CACHE_FILE" ]; then
        echo "{\"version\":$CACHE_VERSION,\"repository\":\"\",\"detected_at\":0,\"project_type\":\"\",\"tools\":{},\"last_run\":{},\"config_hashes\":{},\"profile\":{\"mode\":\"stop\"}}" > "$CACHE_FILE"
    fi
}

# Load cache settings from quality profile
cache_load_settings() {
    # Check repository profile for cache settings
    if [ -f "${CONFIG_DIR}/quality-profile.json" ]; then
        local cache_ttl
        local debounce

        cache_ttl=$(jq -r '.cache_ttl // "null"' "${CONFIG_DIR}/quality-profile.json" 2>/dev/null || echo "null")
        debounce=$(jq -r '.debounce_seconds // "null"' "${CONFIG_DIR}/quality-profile.json" 2>/dev/null || echo "null")

        # Update if values are valid numbers
        if [ "$cache_ttl" != "null" ] && [ -n "$cache_ttl" ]; then
            CACHE_TTL="$cache_ttl"
        fi

        if [ "$debounce" != "null" ] && [ -n "$debounce" ]; then
            DEBOUNCE_SECONDS="$debounce"
        fi
    fi

    # Also check settings.json
    if [ -f "${CONFIG_DIR}/settings.json" ]; then
        local cache_ttl
        local debounce

        cache_ttl=$(jq -r '.quality.cache_ttl // "null"' "${CONFIG_DIR}/settings.json" 2>/dev/null || echo "null")
        debounce=$(jq -r '.quality.debounce_seconds // "null"' "${CONFIG_DIR}/settings.json" 2>/dev/null || echo "null")

        # Update if values are valid numbers (only if not already set by profile)
        if [ "$cache_ttl" != "null" ] && [ -n "$cache_ttl" ] && [ "${CACHE_TTL:-3600}" = "3600" ]; then
            CACHE_TTL="$cache_ttl"
        fi

        if [ "$debounce" != "null" ] && [ -n "$debounce" ] && [ "${DEBOUNCE_SECONDS:-10}" = "10" ]; then
            DEBOUNCE_SECONDS="$debounce"
        fi
    fi
}

# Compute SHA256 hash for a file
# Args: file_path
# Returns: hash string (or empty if file doesn't exist)
cache_compute_hash() {
    local file="$1"

    if [ -f "$file" ]; then
        sha256sum "$file" 2>/dev/null | cut -d' ' -f1
    else
        echo ""
    fi
}

# Read cache value
# Args: key_path (jq path, e.g., .project_type)
# Returns: cached value (or empty if not found)
cache_read() {
    local key_path="$1"

    cache_init

    if [ -f "$CACHE_FILE" ]; then
        # Use bracket notation for keys with special characters
        jq -r "${key_path} // empty" "$CACHE_FILE" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# Write cache data
# Args: project_type, tool_name, tool_version, config_file, check_type (optional)
cache_write() {
    local project_type="$1"
    local tool_name="$2"
    local tool_version="${3:-unknown}"
    local config_file="$4"
    local check_type="${5:-$tool_name}"  # Default to tool_name if check_type not provided

    cache_init

    local current_time
    current_time=$(date +%s)
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
    local config_hash
    config_hash=$(cache_compute_hash "$config_file")
    local config_key
    config_key=$(basename "$config_file" | sed 's/\./_/g')

    # Build JSON update with file locking to prevent race conditions
    (
        flock -x 200 || exit 1

        jq \
            --arg version "$CACHE_VERSION" \
            --arg repo "$repo_root" \
            --argjson detected_at "$current_time" \
            --arg ptype "$project_type" \
            --arg tool "$tool_name" \
            --arg tversion "$tool_version" \
            --arg check_type "$check_type" \
            --argjson last_run "$current_time" \
            --arg config_key "$config_key" \
            --arg hash "$config_hash" \
            '
            .version = ($version | tonumber) |
            .repository = $repo |
            .detected_at = ($detected_at | tonumber) |
            .project_type = $ptype |
            .tools[$tool] = {"available": true, "version": $tversion} |
            .last_run[$check_type] = ($last_run | tonumber) |
            .config_hashes[$config_key] = $hash
            ' "$CACHE_FILE" > "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE"

    ) 200>"$CACHE_FILE.lock"
}

# Check if cache entry is valid (not expired and hash matches)
# Args: check_type (e.g., typecheck), config_file
# Returns: 0 if valid, 1 if invalid/expired
cache_check_valid() {
    local check_type="$1"
    local config_file="${2:-}"

    cache_init

    local current_time
    current_time=$(date +%s)
    local last_run
    last_run=$(jq -r ".last_run[\"$check_type\"] // empty" "$CACHE_FILE" 2>/dev/null)

    # If no last run time, cache miss
    if [ -z "$last_run" ] || [ "$last_run" = "null" ] || [ "$last_run" = "0" ]; then
        return 1
    fi

    # Check debounce
    local time_since_run=$((current_time - last_run))
    if [ "$time_since_run" -lt "$DEBOUNCE_SECONDS" ]; then
        # Within debounce window - check if config changed
        if [ -n "$config_file" ]; then
            local config_key
            config_key=$(basename "$config_file" | sed 's/\./_/g')
            local current_hash
            current_hash=$(cache_compute_hash "$config_file")
            local cached_hash
            cached_hash=$(jq -r ".config_hashes[\"$config_key\"] // empty" "$CACHE_FILE" 2>/dev/null)

            if [ "$current_hash" = "$cached_hash" ] && [ -n "$current_hash" ]; then
                # Cache hit: debounce active, no config change
                return 0
            else
                # Cache miss: config changed
                return 1
            fi
        else
            # No config file to check - assume valid within debounce
            return 0
        fi
    fi

    # Cache miss: debounce period expired
    return 1
}

# Invalidate cache entry (e.g., after config change)
# Args: check_type (e.g., typecheck)
cache_invalidate() {
    local check_type="$1"

    cache_init

    # Remove last_run entry for the check type with file locking
    (
        flock -x 200 || exit 1

        jq ".last_run.${check_type} = 0" "$CACHE_FILE" > "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE"

    ) 200>"$CACHE_FILE.lock"
}

# Get project type from cache
cache_get_project_type() {
    cache_read ".project_type"
}

# Get tool availability from cache
# Args: tool_name
cache_get_tool() {
    local tool_name="$1"
    cache_read ".tools.${tool_name}.available"
}

# Check if cache is expired (TTL)
cache_is_expired() {
    cache_init

    local current_time
    current_time=$(date +%s)
    local detected_at
    detected_at=$(cache_read ".detected_at")

    # If no detection time, consider expired
    if [ -z "$detected_at" ] || [ "$detected_at" = "null" ] || [ "$detected_at" = "0" ]; then
        return 0
    fi

    # Check TTL
    local age=$((current_time - detected_at))
    if [ "$age" -gt "$CACHE_TTL" ]; then
        return 0  # Expired
    else
        return 1  # Not expired
    fi
}

# Export functions for use in other scripts
export -f cache_init
export -f cache_compute_hash
export -f cache_read
export -f cache_write
export -f cache_check_valid
export -f cache_invalidate
export -f cache_get_project_type
export -f cache_get_tool
export -f cache_is_expired
