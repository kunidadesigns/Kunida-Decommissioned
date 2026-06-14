#!/bin/bash
# Setup Continue with LM Studio fallback chain (Ollama → LM Studio → Cloud)

set -e

echo "📦 Setting up Continue with LM Studio fallback chain..."

# Backup existing config
CONTINUE_CONFIG="$HOME/.continue/config.json"
if [ -f "$CONTINUE_CONFIG" ]; then
  cp "$CONTINUE_CONFIG" "$CONTINUE_CONFIG.backup-$(date +%s)"
  echo "✓ Backed up existing config to $CONTINUE_CONFIG.backup-*"
fi

# Create enhanced Continue config with LM Studio fallback
cat > "$CONTINUE_CONFIG" << 'EOF'
{
  "models": [
    {
      "title": "Qwen Coder 7B (Local)",
      "provider": "ollama",
      "model": "qwen2.5-coder:7b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "Qwen Coder 14B (LM Studio Fallback)",
      "provider": "openai",
      "model": "qwen/qwen2.5-coder-14b",
      "apiBase": "http://172.17.176.1:1234/v1",
      "apiKey": "lm-studio"
    },
    {
      "title": "DeepSeek Chat (Cloud Fallback)",
      "provider": "openai",
      "model": "deepseek-chat",
      "apiBase": "https://api.deepseek.com/v1",
      "apiKey": "$DEEPSEEK_API_KEY"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Qwen Coder 1.5B",
    "provider": "ollama",
    "model": "qwen2.5-coder:1.5b-base"
  },
  "embeddingsProvider": {
    "provider": "ollama",
    "model": "nomic-embed-text"
  },
  "contextProviders": [
    {
      "name": "code",
      "params": {}
    },
    {
      "name": "docs",
      "params": {}
    },
    {
      "name": "web"
    }
  ],
  "slashCommands": [
    {
      "name": "chat",
      "description": "Start a new chat"
    },
    {
      "name": "edit",
      "description": "Edit selected code"
    }
  ],
  "disableIndexing": false,
  "allowAutoCompleteLosingFocus": true,
  "useStreamingChat": true
}
EOF

echo "✓ Created $CONTINUE_CONFIG with LM Studio fallback"

# Verify Ollama is running
if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
  OLLAMA_MODELS=$(curl -s http://localhost:11434/api/tags | grep -o '"name":"[^"]*"' | wc -l)
  echo "✓ Ollama running with $OLLAMA_MODELS models"
else
  echo "⚠️  Ollama not responding. Start with: ollama serve"
fi

# Verify LM Studio accessibility (optional, won't fail if not running)
if curl -s http://172.17.176.1:1234/v1/models >/dev/null 2>&1; then
  echo "✓ LM Studio accessible at 172.17.176.1:1234"
else
  echo "ℹ️  LM Studio not running (optional fallback)"
fi

echo ""
echo "✅ Continue LM Studio fallback configured:"
echo "   Primary: Ollama (qwen2.5-coder:7b)"
echo "   Secondary: LM Studio (qwen2.5-coder:14b)"
echo "   Tertiary: DeepSeek Chat (cloud)"
echo ""
echo "Restart VS Code to load new configuration."
