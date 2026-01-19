#!/usr/bin/env bash
# test-dispatcher-perf.sh
# Test SC-1: Dispatcher latency test (100 iterations, <100ms p95)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Dispatcher Latency Test (SC-1) ===${NC}"
echo ""

# Check if dispatcher exists
DISPATCHER="$CLAUDE_PROJECT_DIR/.claude/scripts/hooks/quality-dispatch.sh"

if [ ! -f "$DISPATCHER" ]; then
    echo -e "${RED}✗ FAIL: Dispatcher not found at $DISPATCHER${NC}"
    exit 1
fi

# Make executable
chmod +x "$DISPATCHER"

echo -e "${YELLOW}Warm-up: 3 iterations...${NC}"
for _ in {1..3}; do
    "$DISPATCHER" > /dev/null 2>&1 || true
done

echo -e "${YELLOW}Measuring: 100 iterations...${NC}"

# Measure 100 iterations
TIMES=()
for _ in {1..100}; do
    # Use high-resolution time (macOS compatible)
    START=$(gdate +%s%N 2>/dev/null || python3 -c "import time; print(int(time.time() * 1e9))")
    "$DISPATCHER" > /dev/null 2>&1 || true
    END=$(gdate +%s%N 2>/dev/null || python3 -c "import time; print(int(time.time() * 1e9))")

    DURATION=$((END - START))
    TIMES+=("$DURATION")
done

# Calculate statistics
# Note: Disable SC2207 - we need word splitting here for array assignment
# shellcheck disable=SC2207
SORTED=($(printf '%s\n' "${TIMES[@]}" | sort -n))
MEDIAN=${SORTED[49]}  # Index 49 (0-based) = 50th value
P95=${SORTED[94]}    # Index 94 = 95th percentile

# Convert to milliseconds
MEDIAN_MS=$((MEDIAN / 1000000))
P95_MS=$((P95 / 1000000))

echo ""
echo -e "${BLUE}Results:${NC}"
echo -e "  Median: ${MEDIAN_MS}ms"
echo -e "  P95:    ${P95_MS}ms"
echo ""

# Assert: p95 < 100ms
if [ $P95_MS -lt 100 ]; then
    echo -e "${GREEN}✓ PASS: P95 < 100ms${NC}"
    exit 0
else
    echo -e "${RED}✗ FAIL: P95 ≥ 100ms (target: <100ms)${NC}"
    exit 1
fi
