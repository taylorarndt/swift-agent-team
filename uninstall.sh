#!/bin/bash
# Swift Agents Uninstaller
# Built by Taylor Arndt - https://github.com/taylorarndt
#
# Usage:
#   bash uninstall.sh            Interactive mode
#   bash uninstall.sh --global   Uninstall from ~/.claude/
#   bash uninstall.sh --project  Uninstall from .claude/ in the current directory

set -e

# Parse flags for non-interactive uninstall
choice=""
if [ "$1" = "--global" ]; then
  choice="2"
elif [ "$1" = "--project" ]; then
  choice="1"
fi

if [ -z "$choice" ]; then
  echo ""
  echo "  Swift Agents Uninstaller"
  echo "  ============================"
  echo ""
  echo "  Where would you like to uninstall from?"
  echo ""
  echo "  1) Project   - Remove from .claude/ in the current directory"
  echo "  2) Global    - Remove from ~/.claude/"
  echo ""
  printf "  Choose [1/2]: "
  read -r choice
fi

case "$choice" in
  1)
    TARGET_DIR="$(pwd)/.claude"
    SETTINGS_FILE="$TARGET_DIR/settings.json"
    echo ""
    echo "  Uninstalling from project: $(pwd)"
    ;;
  2)
    TARGET_DIR="$HOME/.claude"
    SETTINGS_FILE="$TARGET_DIR/settings.json"
    echo ""
    echo "  Uninstalling from: $TARGET_DIR"
    ;;
  *)
    echo "  Invalid choice. Exiting."
    exit 1
    ;;
esac

echo ""
echo "  Removing agents..."
AGENTS_DIR="$TARGET_DIR/agents"
if [ -d "$AGENTS_DIR" ]; then
  for agent in "$AGENTS_DIR"/*.md; do
    [ -f "$agent" ] || continue
    name="$(basename "${agent%.md}")"
    rm "$agent"
    echo "    - $name"
  done
fi

echo ""
echo "  Removing hooks..."
if [ -f "$TARGET_DIR/hooks/SWIFT AGENTS CHECK.sh" ]; then
  rm "$TARGET_DIR/hooks/SWIFT AGENTS CHECK.sh"
  echo "    - SWIFT AGENTS CHECK.sh"
fi
if [ -f "$TARGET_DIR/hooks/SWIFT AGENTS CHECK.ps1" ]; then
  rm "$TARGET_DIR/hooks/SWIFT AGENTS CHECK.ps1"
  echo "    - SWIFT AGENTS CHECK.ps1"
fi

# Try to remove hook from settings.json
echo ""
if [ -f "$SETTINGS_FILE" ] && grep -q "SWIFT AGENTS CHECK" "$SETTINGS_FILE" 2>/dev/null; then
  if command -v python3 &>/dev/null; then
    CLEANED=$(python3 -c "
import json, sys
try:
    with open('$SETTINGS_FILE', 'r') as f:
        settings = json.load(f)
    if 'hooks' in settings and 'UserPromptSubmit' in settings['hooks']:
        groups = settings['hooks']['UserPromptSubmit']
        settings['hooks']['UserPromptSubmit'] = [
            g for g in groups
            if not any('SWIFT AGENTS CHECK' in h.get('command', '') for h in g.get('hooks', []))
        ]
        if not settings['hooks']['UserPromptSubmit']:
            del settings['hooks']['UserPromptSubmit']
        if not settings['hooks']:
            del settings['hooks']
    print(json.dumps(settings, indent=2))
except Exception as e:
    print('CLEAN_FAILED', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null) && {
      echo "$CLEANED" > "$SETTINGS_FILE"
      echo "  Removed hook from settings.json."
    } || {
      echo "  Could not auto-remove hook from settings.json."
      echo "  Remove the UserPromptSubmit hook referencing SWIFT AGENTS CHECK manually."
    }
  else
    echo "  NOTE: The hook entry in settings.json was not removed."
    echo "  Remove the UserPromptSubmit hook referencing SWIFT AGENTS CHECK.sh"
    echo "  from your settings.json manually."
  fi
fi

# Remove auto-update (global uninstall only)
if [ "$choice" = "2" ]; then
  echo ""
  echo "  Removing auto-update..."

  # Remove LaunchAgent (macOS)
  PLIST_FILE="$HOME/Library/LaunchAgents/com.techopolis.swift-agents-update.plist"
  if [ -f "$PLIST_FILE" ]; then
    launchctl bootout "gui/$(id -u)" "$PLIST_FILE" 2>/dev/null || true
    rm "$PLIST_FILE"
    echo "    - LaunchAgent removed"
  fi

  # Remove cron job (Linux)
  if crontab -l 2>/dev/null | grep -q "swift-agents-update"; then
    crontab -l 2>/dev/null | grep -v "swift-agents-update" | crontab -
    echo "    - Cron job removed"
  fi

  # Remove update script, cache, version file, and log
  rm -f "$TARGET_DIR/.swift-agents-update.sh"
  rm -f "$TARGET_DIR/.swift-agents-version"
  rm -f "$TARGET_DIR/.swift-agents-update.log"
  rm -rf "$TARGET_DIR/.swift-agents-repo"
  echo "    - Update files cleaned up"
fi

# Clean up empty directories
rmdir "$TARGET_DIR/hooks" 2>/dev/null || true
rmdir "$TARGET_DIR/agents" 2>/dev/null || true

echo ""
echo "  Uninstall complete."
echo ""
