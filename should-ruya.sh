#!/usr/bin/env bash
#
# should-ruya.sh - Check if ruya consolidation should run
#
# Returns exit code 0 if ruya should run, 1 if not.
# Condition: 24+ hours since last consolidation.
#
# Reads memory type from ~/.claude/skills/ruya/.ruya-config
# Supports: native (Claude Code auto-memory), openclaw, project-root

set -euo pipefail

SKILL_DIR="$HOME/.claude/skills/ruya"
CONFIG="$SKILL_DIR/.ruya-config"

# Read config or default to native
RUYA_MEMORY_TYPE="native"
if [[ -f "$CONFIG" ]]; then
    RUYA_MEMORY_TYPE=$(grep '^RUYA_MEMORY_TYPE=' "$CONFIG" | cut -d= -f2 || echo "native")
fi

# Find the .last-ruya timestamp based on memory type
LAST_DREAM_FILE=""
case "$RUYA_MEMORY_TYPE" in
    native)
        # Search all Claude Code project memory dirs for the most recent .last-ruya
        for dir in "$HOME/.claude/projects/"*/memory/; do
            if [[ -f "$dir/.last-ruya" ]]; then
                LAST_DREAM_FILE="$dir/.last-ruya"
                break
            fi
        done
        # If no .last-ruya found anywhere, ruya has never run - condition met
        if [[ -z "$LAST_DREAM_FILE" ]]; then
            echo "ruya conditions met: first-run (no .last-ruya found)"
            exit 0
        fi
        ;;
    openclaw|project-root)
        RUYA_MEMORY_PATH=$(grep '^RUYA_MEMORY_PATH=' "$CONFIG" | cut -d= -f2 || echo ".")
        RUYA_MEMORY_PATH="${RUYA_MEMORY_PATH/#\~/$HOME}"
        LAST_DREAM_FILE="$RUYA_MEMORY_PATH/.last-ruya"
        if [[ ! -f "$LAST_DREAM_FILE" ]]; then
            echo "ruya conditions met: first-run"
            exit 0
        fi
        ;;
esac

# Check: 24+ hours since last consolidation
LAST_DREAM=$(cat "$LAST_DREAM_FILE")
NOW=$(date +%s)
ELAPSED=$(( NOW - LAST_DREAM ))
HOURS_ELAPSED=$(( ELAPSED / 3600 ))

if (( HOURS_ELAPSED < 24 )); then
    exit 1  # Too soon
fi

echo "ruya conditions met: ${HOURS_ELAPSED}h since last ruya"
exit 0
