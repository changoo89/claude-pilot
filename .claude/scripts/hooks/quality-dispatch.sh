#!/usr/bin/env bash
# quality-dispatch.sh
# O(1) project type detection and validator routing with caching
# Part of hooks performance optimization

# shellcheck source=cache.sh
CACHE_SCRIPT="$(dirname "$0")/cache.sh"

set -e

# Cleanup handler for temporary files
cleanup_dispatch_temp_files() {
    # Clean up any temporary files created during execution
    if [ -n "${CACHE_FILE:-}" ] && [ -f "$CACHE_FILE.tmp" ]; then
        rm -f "$CACHE_FILE.tmp" 2>/dev/null || true
    fi
    if [ -n "${CACHE_FILE:-}" ] && [ -f "$CACHE_FILE.lock" ]; then
        rm -f "$CACHE_FILE.lock" 2>/dev/null || true
    fi
}

# Register cleanup trap
trap cleanup_dispatch_temp_files EXIT INT TERM

# Skip during setup
if [ "$PILOT_SETUP_IN_PROGRESS" = "1" ]; then
  exit 0
fi

# Source cache functions
if [ -f "$CACHE_SCRIPT" ]; then
    # shellcheck source=/dev/null
    . "$CACHE_SCRIPT"
fi

# Detect project type (O(1) file existence checks)
detect_project_type() {
    local project_type=""

    # Priority order: first match wins
    if [ -f "tsconfig.json" ]; then
        project_type="typescript"
    elif [ -f "go.mod" ]; then
        project_type="go"
    elif [ -f "Cargo.toml" ]; then
        project_type="rust"
    elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
        project_type="python"
    elif [ -f "package.json" ]; then
        project_type="nodejs"
    fi

    echo "$project_type"
}

# Detect tool availability (O(1) command -v checks)
detect_tools() {
    local project_type="$1"
    local tools_available=""

    case "$project_type" in
        typescript|nodejs)
            if command -v tsc &> /dev/null || command -v npx &> /dev/null; then
                tools_available="${tools_available}tsc "
            fi
            if command -v eslint &> /dev/null || command -v npx &> /dev/null; then
                tools_available="${tools_available}eslint "
            fi
            ;;
        go)
            if command -v gofmt &> /dev/null; then
                tools_available="${tools_available}gofmt "
            fi
            ;;
        rust)
            if command -v cargo &> /dev/null; then
                tools_available="${tools_available}cargo "
            fi
            ;;
        python)
            if command -v pylint &> /dev/null; then
                tools_available="${tools_available}pylint "
            fi
            if command -v ruff &> /dev/null; then
                tools_available="${tools_available}ruff "
            fi
            ;;
    esac

    echo "$tools_available"
}

# Validate mode value is one of: off, stop, strict
validate_mode() {
    local mode="$1"
    case "$mode" in
        off|stop|strict)
            echo "$mode"
            return 0
            ;;
        *)
            # Invalid mode - log warning and use default
            echo "Invalid quality mode: $mode (using default: stop)" >&2
            echo "stop"
            return 1
            ;;
    esac
}

# Resolve quality mode from profile system
# Priority: ENV > repo profile > settings.json > default (stop)
resolve_mode() {
    # 1. Environment variable (highest priority)
    if [ -n "$QUALITY_MODE" ]; then
        validate_mode "$QUALITY_MODE"
        return
    fi

    # 2. Repository profile
    if [ -f ".claude/quality-profile.json" ]; then
        local mode
        mode=$(jq -r '.mode // "stop"' .claude/quality-profile.json 2>/dev/null || echo "stop")
        validate_mode "$mode"
        return
    fi

    # 3. User settings
    if [ -f ".claude/settings.json" ]; then
        local mode
        mode=$(jq -r '.quality.mode // "stop"' .claude/settings.json 2>/dev/null || echo "stop")
        validate_mode "$mode"
        return
    fi

    # 4. Plugin default
    echo "stop"
}

# Check if validator should run based on language-specific overrides
should_run_validator() {
    local validator="$1"  # typecheck, lint
    local lang="$2"      # typescript, python, go, rust

    # Check repository profile for language override
    if [ -f ".claude/quality-profile.json" ]; then
        local enabled
        enabled=$(jq -r ".language_overrides.${lang}.${validator} // \"null\"" \
            .claude/quality-profile.json 2>/dev/null || echo "null")

        if [ "$enabled" = "false" ]; then
            return 1  # Disabled
        elif [ "$enabled" = "true" ]; then
            return 0  # Enabled
        fi
    fi

    # Default: enabled if tool detected
    return 0
}

# Run validators based on project type
run_validators() {
    local project_type="$1"
    local hook_dir
    local config_file=""
    local check_type=""
    hook_dir="$(dirname "$0")"

    # Determine config file and check type based on project type
    case "$project_type" in
        typescript)
            config_file="tsconfig.json"
            check_type="typecheck"
            ;;
        nodejs)
            config_file="package.json"
            check_type="lint"
            ;;
        go)
            config_file="go.mod"
            check_type="lint"
            ;;
        rust)
            config_file="Cargo.toml"
            check_type="lint"
            ;;
        python)
            config_file="pyproject.toml"
            check_type="lint"
            ;;
    esac

    # Check cache before running validators
    if [ -n "$config_file" ] && [ -f "$config_file" ]; then
        if cache_check_valid "$check_type" "$config_file" 2>/dev/null; then
            # Cache hit - skip validation
            exit 0
        fi
    fi

    # Run validators
    case "$project_type" in
        typescript)
            # Check if typecheck should run
            if should_run_validator "typecheck" "typescript"; then
                if [ -f "$hook_dir/typecheck.sh" ]; then
                    "$hook_dir/typecheck.sh"
                    # Update cache after successful validation
                    cache_write "$project_type" "tsc" "unknown" "$config_file" "$check_type"
                fi
            else
                exit 0  # Validator disabled by profile
            fi
            ;;
        nodejs|go|rust|python)
            # Check if lint should run
            if should_run_validator "lint" "$project_type"; then
                if [ -f "$hook_dir/lint.sh" ]; then
                    "$hook_dir/lint.sh"
                    # Update cache after successful validation
                    cache_write "$project_type" "lint" "unknown" "$config_file" "$check_type"
                fi
            else
                exit 0  # Validator disabled by profile
            fi
            ;;
        "")
            # No project type detected, skip silently
            exit 0
            ;;
    esac
}

# Main execution
main() {
    local project_type
    local tools_available
    local mode

    # Resolve quality mode
    mode=$(resolve_mode)

    # Load cache settings from profile
    cache_load_settings 2>/dev/null || true

    # Handle mode=off: exit immediately without running validators
    if [ "$mode" = "off" ]; then
        exit 0
    fi

    # Handle mode=strict: disable cache/debounce for per-operation validation
    if [ "$mode" = "strict" ]; then
        export DEBOUNCE_SECONDS=0
        export CACHE_TTL=0
    fi

    # Detect project type
    project_type=$(detect_project_type)

    # Early exit if no matching project type
    if [ -z "$project_type" ]; then
        exit 0
    fi

    # Detect available tools
    tools_available=$(detect_tools "$project_type")

    # Early exit if no tools available
    if [ -z "$tools_available" ]; then
        exit 0
    fi

    # Run validators with cache integration
    run_validators "$project_type"
}

main
