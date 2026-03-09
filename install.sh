#!/bin/bash
# Swift Agents Installer
# Built by Taylor Arndt - https://github.com/taylorarndt
#
# Usage:
#   bash install.sh                    Interactive mode
#   bash install.sh --project          Claude Code to .claude/ in current directory
#   bash install.sh --global           Claude Code globally to ~/.claude/
#   bash install.sh --vscode           VS Code Copilot to .github/ in current directory
#   bash install.sh --vscode-global    VS Code Copilot globally (sat-init command)
#   bash install.sh --both             Both tools to current directory
#   bash install.sh --both-global      Both tools globally
#
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/Techopolis/swift-agents/main/install.sh | bash

set -e

# Determine source: running from repo clone or piped from curl?
DOWNLOADED=false

# When piped from curl, BASH_SOURCE is empty — always download in that case
if [ -z "${BASH_SOURCE[0]}" ] || [ "${BASH_SOURCE[0]}" = "bash" ] || [ "${BASH_SOURCE[0]}" = "/bin/bash" ]; then
  SCRIPT_DIR=""
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
fi

if [ -z "$SCRIPT_DIR" ] || [ ! -d "$SCRIPT_DIR/agents" ] || [ ! -f "$SCRIPT_DIR/hooks/hooks.json" ]; then
  # Running from curl pipe or without full repo — download first
  DOWNLOADED=true
  TMPDIR_DL="$(mktemp -d)"
  echo ""
  echo "  Downloading Swift Agents..."

  if ! command -v git &>/dev/null; then
    echo "  Error: git is required. Install git and try again."
    rm -rf "$TMPDIR_DL"
    exit 1
  fi

  git clone --quiet https://github.com/Techopolis/swift-agents.git "$TMPDIR_DL/swift-agents" 2>/dev/null
  SCRIPT_DIR="$TMPDIR_DL/swift-agents"
  echo "  Downloaded."
fi

AGENTS_SRC="$SCRIPT_DIR/agents"
HOOKS_JSON_SRC="$SCRIPT_DIR/hooks/hooks.json"
VSCODE_AGENTS_SRC="$SCRIPT_DIR/.github/agents"
VSCODE_HOOKS_SRC="$SCRIPT_DIR/.github/hooks"
VSCODE_INSTRUCTIONS_SRC="$SCRIPT_DIR/.github/copilot-instructions.md"

# Auto-detect agents from source directory
AGENTS=()
if [ -d "$AGENTS_SRC" ]; then
  for f in "$AGENTS_SRC"/*.md; do
    [ -f "$f" ] && AGENTS+=("$(basename "$f")")
  done
fi

# Validate source files exist
if [ ${#AGENTS[@]} -eq 0 ]; then
  echo "  Error: No agents found in $AGENTS_SRC"
  echo "  Make sure you are running this script from the swift-agents directory."
  [ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"
  exit 1
fi

if [ ! -f "$HOOKS_JSON_SRC" ]; then
  echo "  Error: hooks.json not found at $HOOKS_JSON_SRC"
  [ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"
  exit 1
fi

# Parse flags for non-interactive install
TOOL=""
SCOPE=""
for arg in "$@"; do
  case "$arg" in
    --project)        TOOL="claude"; SCOPE="project" ;;
    --global)         TOOL="claude"; SCOPE="global" ;;
    --vscode)         TOOL="vscode"; SCOPE="project" ;;
    --vscode-global)  TOOL="vscode"; SCOPE="global" ;;
    --both)           TOOL="both";   SCOPE="project" ;;
    --both-global)    TOOL="both";   SCOPE="global" ;;
  esac
done

if [ -z "$TOOL" ]; then
  if [ -t 0 ] || [ -c /dev/tty ]; then
    echo ""
    echo "  Swift Agents Installer"
    echo "  Built by Taylor Arndt"
    echo "  ========================="
    echo ""
    echo "  Which tool(s)?"
    echo ""
    echo "  1) Claude Code"
    echo "  2) VS Code Copilot"
    echo "  3) Both"
    echo ""
    printf "  Choose [1/2/3]: "
    read -r tool_choice < /dev/tty 2>/dev/null || tool_choice="3"

    case "$tool_choice" in
      1) TOOL="claude" ;;
      2) TOOL="vscode" ;;
      3) TOOL="both" ;;
      *)
        echo "  Invalid choice. Exiting."
        [ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"
        exit 1
        ;;
    esac

    echo ""
    echo "  Where?"
    echo ""
    echo "  1) Project  - Current directory (recommended, travels with repo)"
    echo "  2) Global   - All projects"
    echo ""
    printf "  Choose [1/2]: "
    read -r scope_choice < /dev/tty 2>/dev/null || scope_choice="1"

    case "$scope_choice" in
      1) SCOPE="project" ;;
      2) SCOPE="global" ;;
      *)
        echo "  Invalid choice. Exiting."
        [ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"
        exit 1
        ;;
    esac
  else
    echo ""
    echo "  No interactive terminal detected. Defaulting to both tools, global."
    echo "  Use flags: --project, --global, --vscode, --vscode-global, --both, --both-global"
    TOOL="both"
    SCOPE="global"
  fi
fi

INSTALL_CLAUDE=false
INSTALL_VSCODE=false
VSCODE_GLOBAL=false

case "$TOOL" in
  claude) INSTALL_CLAUDE=true ;;
  vscode) INSTALL_VSCODE=true ;;
  both)   INSTALL_CLAUDE=true; INSTALL_VSCODE=true ;;
esac

case "$SCOPE" in
  project)
    if [ "$INSTALL_CLAUDE" = true ]; then
      TARGET_DIR="$(pwd)/.claude"
      SETTINGS_FILE="$TARGET_DIR/settings.json"
    fi
    if [ "$INSTALL_VSCODE" = true ]; then
      VSCODE_TARGET="$(pwd)/.github"
    fi
    echo ""
    echo "  Installing to project: $(pwd)"
    ;;
  global)
    if [ "$INSTALL_CLAUDE" = true ]; then
      TARGET_DIR="$HOME/.claude"
      SETTINGS_FILE="$TARGET_DIR/settings.json"
    fi
    if [ "$INSTALL_VSCODE" = true ]; then
      VSCODE_TARGET="$HOME/.swift-agents/vscode"
      VSCODE_GLOBAL=true
    fi
    echo ""
    echo "  Installing globally"
    ;;
esac

# =======================
# Claude Code Installation
# =======================
if [ "$INSTALL_CLAUDE" = true ]; then

# Create directories
mkdir -p "$TARGET_DIR/agents"
mkdir -p "$TARGET_DIR/hooks"

# Copy agents
echo ""
echo "  Copying Claude Code agents..."
for agent in "${AGENTS[@]}"; do
  if [ ! -f "$AGENTS_SRC/$agent" ]; then
    echo "    ! Missing: $agent (skipped)"
    continue
  fi
  cp "$AGENTS_SRC/$agent" "$TARGET_DIR/agents/$agent"
  name="${agent%.md}"
  echo "    + $name"
done

# Copy hooks
echo ""
echo "  Copying hooks..."
cp "$HOOKS_JSON_SRC" "$TARGET_DIR/hooks/hooks.json"
echo "    + hooks.json"

# Handle settings.json — merge hooks from hooks.json into settings.json
echo ""

if [ -f "$SETTINGS_FILE" ]; then
  # Check if hooks already exist
  if grep -q "SWIFT AGENTS CHECK" "$SETTINGS_FILE" 2>/dev/null; then
    echo "  Hooks already configured in settings.json. Skipping."
  else
    # Try to auto-merge with python3 (available on macOS and most Linux)
    if command -v python3 &>/dev/null; then
      MERGED=$(python3 -c "
import json, sys
try:
    with open('$SETTINGS_FILE', 'r') as f:
        settings = json.load(f)
    with open('$TARGET_DIR/hooks/hooks.json', 'r') as f:
        hooks_data = json.load(f)
    if 'hooks' not in settings:
        settings['hooks'] = {}
    for event, groups in hooks_data.get('hooks', {}).items():
        if event not in settings['hooks']:
            settings['hooks'][event] = []
        settings['hooks'][event].extend(groups)
    print(json.dumps(settings, indent=2))
except Exception as e:
    print('MERGE_FAILED', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null) && {
        echo "$MERGED" > "$SETTINGS_FILE"
        echo "  Updated existing settings.json with hooks."
      } || {
        echo "  Existing settings.json found but could not auto-merge."
        echo "  Copy the hooks from hooks/hooks.json into your settings.json manually."
      }
    else
      echo "  Existing settings.json found."
      echo "  python3 not available for auto-merge."
      echo "  Copy the hooks from hooks/hooks.json into your settings.json manually."
    fi
  fi
else
  # Create settings.json from hooks.json
  cp "$TARGET_DIR/hooks/hooks.json" "$SETTINGS_FILE"
  echo "  Created settings.json with hooks configured."
fi

# Save current version hash
if command -v git &>/dev/null && [ -d "$SCRIPT_DIR/.git" ]; then
  git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null > "$TARGET_DIR/.swift-agents-version"
fi

fi  # end INSTALL_CLAUDE

# =======================
# VS Code Copilot Installation
# =======================
if [ "$INSTALL_VSCODE" = true ]; then

mkdir -p "$VSCODE_TARGET/agents"
mkdir -p "$VSCODE_TARGET/hooks"

# Copy VS Code agent files
echo ""
echo "  Copying VS Code Copilot agents..."
if [ -d "$VSCODE_AGENTS_SRC" ]; then
  for agent in "$VSCODE_AGENTS_SRC"/*.agent.md; do
    [ -f "$agent" ] || continue
    NAME=$(basename "$agent")
    cp "$agent" "$VSCODE_TARGET/agents/$NAME"
    name="${NAME%.agent.md}"
    echo "    + $name"
  done
else
  echo "    ! VS Code agents directory not found (skipped)"
fi

# Copy VS Code hooks
echo ""
echo "  Copying VS Code hooks..."
if [ -f "$VSCODE_HOOKS_SRC/hooks.json" ]; then
  cp "$VSCODE_HOOKS_SRC/hooks.json" "$VSCODE_TARGET/hooks/hooks.json"
  echo "    + hooks.json"
else
  echo "    ! VS Code hooks not found (skipped)"
fi

# Copy copilot-instructions.md
if [ -f "$VSCODE_INSTRUCTIONS_SRC" ]; then
  cp "$VSCODE_INSTRUCTIONS_SRC" "$VSCODE_TARGET/copilot-instructions.md"
  echo "    + copilot-instructions.md"
fi

fi  # end INSTALL_VSCODE

# =======================
# VS Code Global: sat-init helper
# =======================
if [ "$VSCODE_GLOBAL" = true ]; then

SAT_INIT_DIR="$HOME/.local/bin"
SAT_INIT="$SAT_INIT_DIR/sat-init"
mkdir -p "$SAT_INIT_DIR"

cat > "$SAT_INIT" << 'SATINIT'
#!/bin/bash
# Swift Agents — Stamp VS Code Copilot agents into current project
# Usage: cd /path/to/swift-project && sat-init
set -e

SRC="$HOME/.swift-agents/vscode"

if [ ! -d "$SRC/agents" ]; then
  echo ""
  echo "  Error: Swift Agents VS Code agents not installed globally."
  echo "  Run: curl -fsSL https://raw.githubusercontent.com/Techopolis/swift-agents/main/install.sh | bash -s -- --vscode-global"
  echo ""
  exit 1
fi

DEST=".github"
mkdir -p "$DEST/agents" "$DEST/hooks"

COPIED=0
for agent in "$SRC/agents/"*.agent.md; do
  [ -f "$agent" ] || continue
  cp "$agent" "$DEST/agents/"
  COPIED=$((COPIED + 1))
done

[ -f "$SRC/hooks/hooks.json" ] && cp "$SRC/hooks/hooks.json" "$DEST/hooks/"
[ -f "$SRC/copilot-instructions.md" ] && cp "$SRC/copilot-instructions.md" "$DEST/"

echo ""
echo "  Swift Agents — VS Code Copilot agents installed"
echo "  $COPIED agents copied to $DEST/agents/"
echo "  Hooks and instructions copied to $DEST/"
echo ""
SATINIT
chmod +x "$SAT_INIT"

echo ""
echo "  Created helper command: sat-init"
echo "  Location: $SAT_INIT"

# Ensure ~/.local/bin is in PATH
if ! echo "$PATH" | tr ':' '\n' | grep -q "$HOME/.local/bin"; then
  SHELL_RC=""
  if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
  elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
  elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_RC="$HOME/.bash_profile"
  fi

  if [ -n "$SHELL_RC" ]; then
    if ! grep -q 'swift-agents' "$SHELL_RC" 2>/dev/null; then
      echo '' >> "$SHELL_RC"
      echo '# Swift Agents - sat-init command' >> "$SHELL_RC"
      echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
      echo "  Added ~/.local/bin to PATH in $(basename "$SHELL_RC")"
      echo "  Restart your terminal or run: source $SHELL_RC"
    fi
  else
    echo "  Note: Add ~/.local/bin to your PATH to use sat-init globally:"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
  fi
fi

fi  # end VSCODE_GLOBAL

# Auto-update setup (global Claude Code install only, interactive only)
if [ "$SCOPE" = "global" ] && [ "$INSTALL_CLAUDE" = true ] && { [ -t 0 ] || [ -c /dev/tty ]; }; then
  echo ""
  echo "  Would you like to enable auto-updates?"
  echo "  This checks GitHub daily for new agents and improvements."
  echo ""
  printf "  Enable auto-updates? [y/N]: "
  auto_update=""
  read -r auto_update < /dev/tty 2>/dev/null || auto_update="n"

  if [ "$auto_update" = "y" ] || [ "$auto_update" = "Y" ]; then
    UPDATE_SCRIPT="$TARGET_DIR/.swift-agents-update.sh"

    # Write a self-contained update script
    cat > "$UPDATE_SCRIPT" << 'UPDATESCRIPT'
#!/bin/bash
set -e
REPO_URL="https://github.com/Techopolis/swift-agents.git"
CACHE_DIR="$HOME/.claude/.swift-agents-repo"
INSTALL_DIR="$HOME/.claude"
LOG_FILE="$HOME/.claude/.swift-agents-update.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }

command -v git &>/dev/null || { log "git not found"; exit 1; }

if [ -d "$CACHE_DIR/.git" ]; then
  cd "$CACHE_DIR"
  git fetch origin main --quiet 2>/dev/null
  LOCAL=$(git rev-parse HEAD 2>/dev/null)
  REMOTE=$(git rev-parse origin/main 2>/dev/null)
  [ "$LOCAL" = "$REMOTE" ] && { log "Already up to date."; exit 0; }
  git reset --hard origin/main --quiet 2>/dev/null
else
  mkdir -p "$(dirname "$CACHE_DIR")"
  git clone --quiet "$REPO_URL" "$CACHE_DIR" 2>/dev/null
fi

cd "$CACHE_DIR"
HASH=$(git rev-parse --short HEAD 2>/dev/null)
UPDATED=0

for agent in agents/*.md; do
  NAME=$(basename "$agent")
  SRC="$CACHE_DIR/$agent"
  DST="$INSTALL_DIR/agents/$NAME"
  [ -f "$SRC" ] || continue
  if ! cmp -s "$SRC" "$DST" 2>/dev/null; then
    cp "$SRC" "$DST"
    log "Updated: ${NAME%.md}"
    UPDATED=$((UPDATED + 1))
  fi
done

# Remove agents no longer in repo
for DST in "$INSTALL_DIR"/agents/*.md; do
  [ -f "$DST" ] || continue
  NAME=$(basename "$DST")
  [ ! -f "$CACHE_DIR/agents/$NAME" ] && {
    rm "$DST"
    log "Removed: ${NAME%.md}"
    UPDATED=$((UPDATED + 1))
  }
done

SRC="$CACHE_DIR/hooks/hooks.json"
DST="$INSTALL_DIR/hooks/hooks.json"
[ -f "$SRC" ] && [ -f "$DST" ] && ! cmp -s "$SRC" "$DST" && {
  cp "$SRC" "$DST"
  log "Updated: hooks.json"
  UPDATED=$((UPDATED + 1))
}

# Also update VS Code global agents if installed
VSCODE_DIR="$HOME/.swift-agents/vscode"
if [ -d "$VSCODE_DIR/agents" ] && [ -d "$CACHE_DIR/.github/agents" ]; then
  for agent in "$CACHE_DIR"/.github/agents/*.agent.md; do
    [ -f "$agent" ] || continue
    NAME=$(basename "$agent")
    DST="$VSCODE_DIR/agents/$NAME"
    if ! cmp -s "$agent" "$DST" 2>/dev/null; then
      cp "$agent" "$DST"
      log "Updated VS Code: ${NAME%.agent.md}"
      UPDATED=$((UPDATED + 1))
    fi
  done
  for DST in "$VSCODE_DIR"/agents/*.agent.md; do
    [ -f "$DST" ] || continue
    NAME=$(basename "$DST")
    [ ! -f "$CACHE_DIR/.github/agents/$NAME" ] && {
      rm "$DST"
      log "Removed VS Code: ${NAME%.agent.md}"
      UPDATED=$((UPDATED + 1))
    }
  done
  SRC="$CACHE_DIR/.github/hooks/hooks.json"
  DST="$VSCODE_DIR/hooks/hooks.json"
  [ -f "$SRC" ] && [ -f "$DST" ] && ! cmp -s "$SRC" "$DST" && {
    cp "$SRC" "$DST"
    log "Updated VS Code: hooks.json"
    UPDATED=$((UPDATED + 1))
  }
  SRC="$CACHE_DIR/.github/copilot-instructions.md"
  DST="$VSCODE_DIR/copilot-instructions.md"
  [ -f "$SRC" ] && [ -f "$DST" ] && ! cmp -s "$SRC" "$DST" && {
    cp "$SRC" "$DST"
    log "Updated VS Code: copilot-instructions.md"
    UPDATED=$((UPDATED + 1))
  }
fi

echo "$HASH" > "$INSTALL_DIR/.swift-agents-version"
log "Check complete: $UPDATED files updated (version $HASH)."
UPDATESCRIPT
    chmod +x "$UPDATE_SCRIPT"

    # Detect platform and set up scheduler
    if [ "$(uname)" = "Darwin" ]; then
      # macOS: LaunchAgent
      PLIST_DIR="$HOME/Library/LaunchAgents"
      PLIST_FILE="$PLIST_DIR/com.techopolis.swift-agents-update.plist"
      mkdir -p "$PLIST_DIR"
      cat > "$PLIST_FILE" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.techopolis.swift-agents-update</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>${UPDATE_SCRIPT}</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>9</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>${HOME}/.claude/.swift-agents-update.log</string>
  <key>StandardErrorPath</key>
  <string>${HOME}/.claude/.swift-agents-update.log</string>
  <key>RunAtLoad</key>
  <false/>
</dict>
</plist>
PLIST
      launchctl bootout "gui/$(id -u)" "$PLIST_FILE" 2>/dev/null || true
      launchctl bootstrap "gui/$(id -u)" "$PLIST_FILE" 2>/dev/null
      echo "  Auto-updates enabled (daily at 9:00 AM via launchd)."
    else
      # Linux: cron job
      CRON_CMD="0 9 * * * /bin/bash $UPDATE_SCRIPT"
      (crontab -l 2>/dev/null | grep -v "swift-agents-update"; echo "$CRON_CMD") | crontab -
      echo "  Auto-updates enabled (daily at 9:00 AM via cron)."
    fi
    echo "  Update log: ~/.claude/.swift-agents-update.log"
  else
    echo "  Auto-updates skipped. You can run update.sh manually anytime."
  fi
fi

# =======================
# Companion Skills from Marketplace
# =======================
# Skills provide reference knowledge that the slimmed-down agents rely on.
# The skill list is maintained by the community at awesome-ios-ai.

install_companion_skills() {
  echo ""
  echo "  ========================="
  echo "  Companion Skills (from skills.sh marketplace)"
  echo "  ========================="
  echo ""
  echo "  Your agents rely on community skills for deep reference knowledge."
  echo "  These are maintained by third-party authors on skills.sh."
  echo ""

  # Fetch the recommended skills list from awesome-ios-ai on GitHub
  SKILLS_URL="https://raw.githubusercontent.com/Techopolis/awesome-ios-ai/main/companion-skills.txt"
  SKILLS_LIST=""

  if command -v curl &>/dev/null; then
    SKILLS_LIST=$(curl -fsSL "$SKILLS_URL" 2>/dev/null) || true
  elif command -v wget &>/dev/null; then
    SKILLS_LIST=$(wget -qO- "$SKILLS_URL" 2>/dev/null) || true
  fi

  if [ -z "$SKILLS_LIST" ]; then
    echo "  Could not fetch skill list from GitHub."
    echo "  Install companion skills manually:"
    echo ""
    echo "    npx skills add avdlee/swift-concurrency-agent-skill@swift-concurrency -g -y"
    echo "    npx skills add dimillian/skills@swiftui-liquid-glass -g -y"
    echo "    npx skills add dimillian/skills@swiftui-ui-patterns -g -y"
    echo "    npx skills add dimillian/skills@ios-debugger-agent -g -y"
    echo ""
    echo "  Full list: https://github.com/Techopolis/awesome-ios-ai"
    return
  fi

  # Check if npx/skills CLI is available
  if ! command -v npx &>/dev/null; then
    echo "  npx not found. Install Node.js to use the skills CLI."
    echo "  Then run: npx skills add <skill> -g -y"
    echo ""
    echo "  Recommended skills:"
    echo "$SKILLS_LIST" | grep -v '^#' | grep -v '^$' | while IFS= read -r line; do
      echo "    npx skills add $line -g -y"
    done
    return
  fi

  echo "  Recommended companion skills:"
  echo ""
  SKILL_ITEMS=()
  while IFS= read -r line; do
    # Skip comments and blank lines
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue
    SKILL_ITEMS+=("$line")
  done <<< "$SKILLS_LIST"

  for i in "${!SKILL_ITEMS[@]}"; do
    skill="${SKILL_ITEMS[$i]}"
    # Extract display name (after # comment on same line, or just the skill ref)
    ref=$(echo "$skill" | awk '{print $1}')
    desc=$(echo "$skill" | sed 's/^[^ ]* *//')
    [ "$desc" = "$ref" ] && desc=""
    printf "    %d) %s" "$((i + 1))" "$ref"
    [ -n "$desc" ] && printf "  — %s" "$desc"
    echo ""
  done

  echo ""
  printf "  Install all companion skills? [Y/n]: "
  install_skills=""
  if [ -t 0 ] || [ -c /dev/tty ]; then
    read -r install_skills < /dev/tty 2>/dev/null || install_skills="y"
  else
    install_skills="y"
  fi

  if [ "$install_skills" != "n" ] && [ "$install_skills" != "N" ]; then
    echo ""
    INSTALLED=0
    FAILED=0
    for skill in "${SKILL_ITEMS[@]}"; do
      ref=$(echo "$skill" | awk '{print $1}')
      printf "    Installing %s..." "$ref"
      if npx skills add "$ref" -g -y &>/dev/null; then
        echo " done"
        INSTALLED=$((INSTALLED + 1))
      else
        echo " failed"
        FAILED=$((FAILED + 1))
      fi
    done
    echo ""
    echo "  Skills installed: $INSTALLED"
    [ "$FAILED" -gt 0 ] && echo "  Skills failed: $FAILED (install manually with: npx skills add <skill> -g -y)"
  else
    echo ""
    echo "  Skipped. Install later with:"
    for skill in "${SKILL_ITEMS[@]}"; do
      ref=$(echo "$skill" | awk '{print $1}')
      echo "    npx skills add $ref -g -y"
    done
  fi
}

# Ask about companion skills (interactive only)
if [ -t 0 ] || [ -c /dev/tty ]; then
  echo ""
  printf "  Install companion skills from the marketplace? [Y/n]: "
  want_skills=""
  read -r want_skills < /dev/tty 2>/dev/null || want_skills="y"
  if [ "$want_skills" != "n" ] && [ "$want_skills" != "N" ]; then
    install_companion_skills
  fi
fi

# Verify installation
echo ""
echo "  ========================="
echo "  Installation complete!"

if [ "$INSTALL_CLAUDE" = true ]; then
echo ""
echo "  Claude Code agents installed:"
for agent in "${AGENTS[@]}"; do
  name="${agent%.md}"
  if [ -f "$TARGET_DIR/agents/$agent" ]; then
    echo "    [x] $name"
  else
    echo "    [ ] $name (missing)"
  fi
done
echo ""
echo "  Claude Code hooks:"
if [ -f "$TARGET_DIR/hooks/hooks.json" ]; then
  echo "    [x] hooks.json"
else
  echo "    [ ] hooks.json (missing)"
fi
echo ""
echo "  Settings:"
if grep -q "SWIFT AGENTS CHECK" "$SETTINGS_FILE" 2>/dev/null; then
  echo "    [x] Hooks configured in settings.json"
else
  echo "    [ ] Hooks NOT configured -- add them manually (see above)"
fi
fi

if [ "$INSTALL_VSCODE" = true ]; then
echo ""
if [ "$VSCODE_GLOBAL" = true ]; then
  echo "  VS Code Copilot agents installed globally:"
  echo "  Source: $VSCODE_TARGET/"
else
  echo "  VS Code Copilot agents installed:"
fi
for agent in "$VSCODE_TARGET"/agents/*.agent.md; do
  [ -f "$agent" ] || continue
  name="$(basename "${agent%.agent.md}")"
  echo "    [x] $name"
done
echo ""
echo "  VS Code Copilot extras:"
[ -f "$VSCODE_TARGET/hooks/hooks.json" ] && echo "    [x] hooks.json"
[ -f "$VSCODE_TARGET/copilot-instructions.md" ] && echo "    [x] copilot-instructions.md"
if [ "$VSCODE_GLOBAL" = true ]; then
  echo ""
  echo "  Helper command:"
  if [ -f "$HOME/.local/bin/sat-init" ]; then
    echo "    [x] sat-init"
  else
    echo "    [ ] sat-init (missing)"
  fi
  echo ""
  echo "  Usage: cd /path/to/swift-project && sat-init"
fi
fi

# Clean up temp download
[ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"

echo ""
if [ "$INSTALL_CLAUDE" = true ]; then
  echo "  If agents do not load, increase the character budget:"
  echo "    export SLASH_COMMAND_TOOL_CHAR_BUDGET=50000"
  echo ""
  echo "  Start Claude Code and try: \"Build a settings screen with a toggle\""
  echo "  The swift-lead should activate automatically."
fi
if [ "$INSTALL_VSCODE" = true ]; then
  echo ""
  if [ "$VSCODE_GLOBAL" = true ]; then
    echo "  To set up VS Code agents in any Swift project:"
    echo "    cd /path/to/swift-project && sat-init"
    echo ""
    echo "  Then open VS Code and use Copilot Chat in agent mode."
  else
    echo "  Open VS Code and use Copilot Chat in agent mode."
  fi
  echo "  Invoke @swift-lead or the agents will activate based on context."
fi
echo ""
