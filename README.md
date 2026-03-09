# Swift Agents

[![Swift 6.2](https://img.shields.io/badge/Swift-6.2-F05138.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS-lightgrey.svg)](https://developer.apple.com)
[![Claude Code](https://img.shields.io/badge/Built%20for-Claude%20Code-blueviolet.svg)](https://docs.anthropic.com/en/docs/claude-code)
[![VS Code Copilot](https://img.shields.io/badge/Built%20for-VS%20Code%20Copilot-007ACC.svg)](https://code.visualstudio.com/docs/copilot/copilot-customization)

**16 specialized Swift agents for Claude Code and VS Code Copilot.**

Built by [Taylor Arndt](https://github.com/taylorarndt) at [Techopolis](https://github.com/Techopolis). Swift 6.2 strict concurrency, Apple Foundation Models, on-device AI, SwiftUI best practices, and mobile accessibility — enforced on every prompt.

Agents handle the review workflow. [Marketplace skills](https://github.com/Techopolis/awesome-ios-ai) provide the deep reference knowledge. This keeps agents slim, fast, and focused.

## The Problem

AI coding tools write Swift like it is 2020. They use ObservableObject when @Observable exists. They ignore actor isolation. They produce views with no accessibility modifiers. They have never heard of Apple Foundation Models or @Generable.

## Before and After

**Without Swift Agents:**

```swift
class SettingsViewModel: ObservableObject {
    @Published var notifications = false
}

struct SettingsView: View {
    @StateObject var vm = SettingsViewModel()
    var body: some View {
        NavigationView {
            Toggle("Notifications", isOn: $vm.notifications)
        }
    }
}
```

**With Swift Agents:**

```swift
@Observable
class SettingsViewModel {
    var notifications = false
}

struct SettingsView: View {
    @State private var vm = SettingsViewModel()
    var body: some View {
        NavigationStack {
            Toggle("Notifications", isOn: $vm.notifications)
                .accessibilityLabel("Push notifications")
                .accessibilityHint("Enables or disables push notifications for this app")
        }
    }
}
```

Modern `@Observable` instead of `ObservableObject`. `NavigationStack` instead of deprecated `NavigationView`. Accessibility labels and hints so VoiceOver users know what the toggle does.

## The Team

| Agent | Role |
|-------|------|
| **swift-lead** | Orchestrator. Routes tasks to the right specialists. |
| **concurrency-specialist** | Swift 6.2 strict concurrency, actors, Sendable, async/await. |
| **foundation-models-specialist** | Apple Foundation Models (iOS 26+), @Generable, @Guide, tool calling. |
| **on-device-ai-architect** | MLX Swift, llama.cpp, Core ML, device tier planning, multi-backend fallback. |
| **mobile-a11y-specialist** | iOS/macOS accessibility, VoiceOver, Dynamic Type, focus management. |
| **swiftui-specialist** | Modern SwiftUI, @Observable, state management, NavigationStack. |
| **app-review-guardian** | App Store review compliance, privacy manifests, IAP rules. |
| **testing-specialist** | Swift Testing, XCTest, testable architecture. |
| **swift-security-specialist** | Keychain, CryptoKit, biometric auth, ATS, certificate pinning. |
| **coreml-specialist** | Core ML conversion, quantization, deployment. |
| **mlx-specialist** | MLX Swift, MLXLLM, MLXVLM, GPU memory, LoRA. |
| **meta-glasses-sdk-specialist** | Meta Wearables DAT, camera streaming, device pairing. |
| **swiftdata-specialist** | SwiftData persistence, @Model, @Query, migration. |
| **visionos-specialist** | visionOS, RealityKit, ARKit, immersive spaces. |
| **storekit-specialist** | StoreKit 2, subscriptions, entitlement verification. |
| **performance-specialist** | Instruments, MetricKit, hang detection, memory management. |

## How It Works

A `UserPromptSubmit` hook fires on every prompt. If the task involves Swift code, the hook delegates to the **swift-lead**. The lead evaluates the task and invokes the relevant specialists. Multiple specialists can review a single task.

Agents are slim workflow reviewers (~50-80 lines each). They flag issues and enforce patterns. For deep reference knowledge, they rely on [marketplace skills](https://skills.sh/?q=swift) that load on demand. The installer offers to install companion skills automatically.

## Prerequisites

**For Claude Code:**
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- A Claude Code subscription (Pro, Max, or Team)

**For VS Code Copilot:**
- [VS Code](https://code.visualstudio.com/) (1.106+) or VS Code Insiders
- [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) extension
- A GitHub Copilot subscription

## Installation

### One-Liner (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/Techopolis/swift-agents/main/install.sh | bash
```

The installer asks which tool(s) and where (project or global). It also offers to install companion skills from the marketplace.

### Non-Interactive

```bash
# Claude Code — project
curl -fsSL https://raw.githubusercontent.com/Techopolis/swift-agents/main/install.sh | bash -s -- --project

# Claude Code — global
curl -fsSL https://raw.githubusercontent.com/Techopolis/swift-agents/main/install.sh | bash -s -- --global

# VS Code Copilot — project
curl -fsSL https://raw.githubusercontent.com/Techopolis/swift-agents/main/install.sh | bash -s -- --vscode

# VS Code Copilot — global
curl -fsSL https://raw.githubusercontent.com/Techopolis/swift-agents/main/install.sh | bash -s -- --vscode-global

# Both — project
curl -fsSL https://raw.githubusercontent.com/Techopolis/swift-agents/main/install.sh | bash -s -- --both

# Both — global
curl -fsSL https://raw.githubusercontent.com/Techopolis/swift-agents/main/install.sh | bash -s -- --both-global
```

### Manual Install

**Project-level** (recommended, travels with the repo):

```bash
git clone https://github.com/Techopolis/swift-agents.git
cp -r swift-agents/.claude /path/to/your/swift-project/
```

**Global** (available in all projects):

```bash
git clone https://github.com/Techopolis/swift-agents.git
cp -r swift-agents/.claude/agents/*.md ~/.claude/agents/
mkdir -p ~/.claude/hooks
cp swift-agents/.claude/hooks/hooks.json ~/.claude/hooks/
```

Then merge the hook into your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/Users/yourname/.claude/hooks/swift-team-eval.sh"
          }
        ]
      }
    ]
  }
}
```

### Updating

If you enabled auto-updates during install, agents update daily at 9:00 AM. To update manually:

```bash
bash update.sh              # Update global install
bash update.sh --project    # Update project install
```

### Uninstalling

```bash
bash uninstall.sh           # Interactive
bash uninstall.sh --global  # Remove global install
bash uninstall.sh --project # Remove from current project
```

### Verify

Start Claude Code in your Swift project and type `/agents`. You should see all 16 agents.

## Usage

### Claude Code

#### Automatic (via hook)

Just write code normally. The hook fires on every prompt and the swift-lead routes to the right specialists.

#### Manual (invoke directly)

```
/concurrency-specialist review the async code in NetworkService.swift
/foundation-models-specialist help me implement @Generable for recipe output
/mobile-a11y-specialist audit the accessibility of ProfileView.swift
/swiftui-specialist review the navigation stack implementation
/swift-lead full review of the chat feature
```

### VS Code Copilot

After installing, agents are available in VS Code Copilot's agent mode. Use `@swift-lead`, `@concurrency-specialist`, `@swiftui-specialist`, etc. in Copilot Chat.

## Companion Skills

Agents are slim reviewers. They rely on marketplace skills for deep reference knowledge. The installer offers to install these automatically. You can also install them manually:

```bash
npx skills add avdlee/swift-concurrency-agent-skill@swift-concurrency -g -y
npx skills add dimillian/skills@swiftui-liquid-glass -g -y
npx skills add dimillian/skills@swiftui-ui-patterns -g -y
npx skills add dimillian/skills@ios-debugger-agent -g -y
```

The full companion skills list is maintained at [awesome-ios-ai](https://github.com/Techopolis/awesome-ios-ai).

## Configuration

If agents stop loading silently, increase the character budget:

```bash
export SLASH_COMMAND_TOOL_CHAR_BUDGET=50000
```

## Contributing

Contributions welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Areas where help is especially welcome:
- Additional Swift Evolution proposals coverage
- Framework-specific patterns (MapKit, HealthKit, CloudKit)
- watchOS specialist knowledge
- Corrections to anything the agents get wrong

Found an agent gap? Use the [Agent Gap](https://github.com/Techopolis/swift-agents/issues/new?template=agent_gap.yml) issue template.

## License

MIT

## About

Built by [Taylor Arndt](https://github.com/taylorarndt), COO at [Techopolis](https://github.com/Techopolis). Developer and accessibility specialist. Part of [awesome-ios-ai](https://github.com/Techopolis/awesome-ios-ai), a community-curated list of AI tools for Swift and iOS development.
