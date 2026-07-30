#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate bash)"

if ! command -v claude &> /dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

if ! command -v opencode &> /dev/null; then
  curl -fsSL https://opencode.ai/install | bash
fi

if ! command -v codex &> /dev/null; then
  npm install -g @openai/codex
fi

if ! command -v copilot &> /dev/null; then
  npm install -g @github/copilot
fi
