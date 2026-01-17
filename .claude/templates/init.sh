#!/bin/bash
# init.sh - Template for complex workflow initialization
# Usage: Copy to project root, customize for specific task

set -euo pipefail

# Task metadata
TASK_NAME="{{TASK_NAME}}"
TASK_ID="{{TASK_ID}}"
START_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "========================================"
echo "Initializing: $TASK_NAME"
echo "Task ID: $TASK_ID"
echo "Started: $START_TIME"
echo "========================================"

# Step 1: Create feature list from plan
echo "[1/5] Creating feature list..."
# Extract SC items from plan and populate feature-list.json

# Step 2: Initialize progress tracking
echo "[2/5] Initializing progress tracking..."
# Create progress.md with template

# Step 3: Verify dependencies
echo "[3/5] Verifying dependencies..."
# Check for required tools, environments, services

# Step 4: Create checkpoint (git commit)
echo "[4/5] Creating checkpoint..."
# git add . && git commit -m "feat: initialize $TASK_NAME"

# Step 5: Start execution
echo "[5/5] Ready for execution"
echo ""
echo "Next steps:"
echo "  1. Review feature-list.json"
echo "  2. Update progress.md as features complete"
echo "  3. Run tests after each feature"
echo ""
