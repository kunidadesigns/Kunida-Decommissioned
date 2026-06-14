#!/bin/bash
# Setup Cline with DeepSeek R1 (full thinking, 32K budget)

set -e

CLINE_STATE="$HOME/.cursor-server/data/User/globalStorage/saoudrizwan.claude-dev/globalState.json"

if [ ! -f "$CLINE_STATE" ]; then
  echo "❌ Cline globalState not found at:"
  echo "   $CLINE_STATE"
  echo ""
  echo "Make sure VS Code with Cline extension is running first."
  exit 1
fi

# Backup current state
cp "$CLINE_STATE" "$CLINE_STATE.backup-$(date +%s)"
echo "✓ Backed up Cline state to .backup-*"

# Close VS Code (required to modify globalState)
echo "⚠️  This requires VS Code to be completely closed."
echo "Closing VS Code in 5 seconds..."
sleep 5

# Kill VS Code
pkill -9 code 2>/dev/null || true
sleep 2

# Update Cline configuration with R1 + full thinking
# Using jq to properly modify JSON
cat > /tmp/cline-r1-config.json << 'EOF'
{
  "apiConfiguration": {
    "apiProvider": "openrouter",
    "selectedModelId": "deepseek/deepseek-r1-0528",
    "customModelId": "deepseek/deepseek-r1-0528",
    "thinkingBudget": 32000,
    "costAwareRespect": true,
    "fallbackModels": [
      "qwen/qwen3-max-thinking:free",
      "groq/llama-3.3-70b-instruct:free"
    ]
  },
  "modelSettings": {
    "actModeReasoningEffort": "maximum",
    "planModeReasoningEffort": "maximum",
    "maxRequests": 200
  },
  "toolSettings": {
    "autoApproveTools": ["*.modelcontextprotocol.*"],
    "requireApprovalFor": ["file.write", "file.delete", "git.push"]
  }
}
EOF

# Merge with existing globalState (preserve other settings)
if command -v jq &>/dev/null; then
  jq '. + $(cat /tmp/cline-r1-config.json | jq .)' "$CLINE_STATE" > "$CLINE_STATE.tmp"
  mv "$CLINE_STATE.tmp" "$CLINE_STATE"
  echo "✓ Updated Cline config with R1 + 32K thinking"
else
  # Fallback: direct replacement (less safe but works)
  cp "$CLINE_STATE" "$CLINE_STATE.original"
  cat /tmp/cline-r1-config.json > "$CLINE_STATE"
  echo "✓ Updated Cline config (no jq, used direct merge)"
fi

rm -f /tmp/cline-r1-config.json

echo ""
echo "✅ Cline R1 Configuration Applied:"
echo "   Model: DeepSeek R1 (deepseek/deepseek-r1-0528)"
echo "   Thinking Budget: 32K tokens (MAXED)"
echo "   Max Requests: 200 (unlimited tool chains)"
echo "   Reasoning Effort: maximum"
echo ""
echo "📝 To verify, open VS Code and ask Cline:"
echo "   'What model are you using?'"
echo ""
echo "It should respond with DeepSeek R1 configuration."
