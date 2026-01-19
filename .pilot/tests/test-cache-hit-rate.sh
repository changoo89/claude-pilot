#!/bin/bash
# test-cache-hit-rate.sh
# Test SC-2: Cache hit rate ≥90% with hash-based invalidation

set -euo pipefail

# Test configuration
CACHE_FILE="/tmp/test-quality-cache.json"
TEST_ITERATIONS=100
MIN_HIT_RATE=90  # 90%

# Source cache.sh functions
CACHE_SCRIPT="/Users/chanho/claude-pilot/.claude/scripts/hooks/cache.sh"

echo "=== Cache Hit Rate Test (SC-2) ==="
echo "Test: $TEST_ITERATIONS Stop triggers"
echo "Expected: ≥$MIN_HIT_RATE% cache hit rate"
echo ""

# Cleanup function
cleanup() {
    rm -f "$CACHE_FILE"
}
trap cleanup EXIT

# Initialize counters
HITS=0
MISSES=0

# Create a test tsconfig.json file for hashing
TEST_TSCONFIG="/tmp/test-tsconfig.json"
cat > "$TEST_TSCONFIG" <<EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs"
  }
}
EOF

echo "Phase 1: Initial cache write (cold start)"
if [ -f "$CACHE_SCRIPT" ]; then
    # Source the cache script to load functions
    . "$CACHE_SCRIPT"

    # Initialize cache and write initial data
    cache_init
    cache_write "typescript" "tsc" "5.3.0" "$TEST_TSCONFIG" "typecheck"
    echo "✓ Initial cache written"
else
    echo "✗ FAIL: cache.sh not found"
    exit 1
fi

echo ""
echo "Phase 2: $TEST_ITERATIONS cache reads (warm cache)"
echo "Measuring cache hit rate..."
echo ""

for i in $(seq 1 $TEST_ITERATIONS); do
    # Read cache and check if it's a hit (within debounce window)
    # Set DEBOUNCE_SECONDS to 1 hour to ensure cache hits
    DEBOUNCE_SECONDS=3600 cache_check_valid "typecheck" "$TEST_TSCONFIG"

    if [ $? -eq 0 ]; then
        ((HITS++))
    else
        ((MISSES++))
    fi

    # Progress indicator
    if [ $((i % 10)) -eq 0 ]; then
        echo "Progress: $i/$TEST_ITERATIONS"
    fi
done

echo ""
echo "=== Results ==="
echo "Cache Hits:   $HITS"
echo "Cache Misses: $MISSES"
echo "Total:        $TEST_ITERATIONS"

# Calculate hit rate
if [ $TEST_ITERATIONS -gt 0 ]; then
    HIT_RATE=$((HITS * 100 / TEST_ITERATIONS))
else
    HIT_RATE=0
fi

echo "Hit Rate:     ${HIT_RATE}%"
echo ""

# Assert: hit rate ≥ MIN_HIT_RATE
if [ $HIT_RATE -ge $MIN_HIT_RATE ]; then
    echo "✓ PASS: Cache hit rate ${HIT_RATE}% ≥ ${MIN_HIT_RATE}%"
    exit 0
else
    echo "✗ FAIL: Cache hit rate ${HIT_RATE}% < ${MIN_HIT_RATE}%"
    exit 1
fi
