#!/usr/bin/env bash
#
# ruya-hook.sh - Stop hook that checks ruya conditions and triggers consolidation
#
# Add to settings.json:
#   "hooks": {
#     "Stop": [{
#       "type": "command",
#       "command": "bash ~/.claude/skills/ruya/ruya-hook.sh"
#     }]
#   }
#
# Fires when a Claude Code session ends. Checks if 24hrs + 5 sessions
# have passed since last ruya. If so, spawns claude in the background
# to run /ruya. Zero overhead when conditions aren't met (~10ms check).

SKILL_DIR="$HOME/.claude/skills/ruya"

# Run the condition check
if bash "$SKILL_DIR/should-ruya.sh" 2>/dev/null; then
    # Conditions met - spawn ruya in background
    # Use claude -p to run the ruya skill non-interactively
    nohup claude -p "Run the ruya memory consolidation skill. Read ~/.claude/skills/ruya/SKILL.md and execute all 4 phases for all projects." \
        --allowedTools "Read,Write,Edit,Bash,Glob,Grep" \
        > /tmp/ruya-$(date +%Y%m%d-%H%M%S).log 2>&1 &

    echo "Ruya consolidation started in background (PID: $!)"
fi

# Always exit 0 so we don't block the session from closing
exit 0
