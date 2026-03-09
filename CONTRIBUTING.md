# Contributing to Swift Agents

First off, thank you for considering contributing. Modern Swift deserves modern AI tooling, and every improvement to these agents helps developers ship better code.

## Ways to Contribute

### Report agent gaps

The most valuable contributions are **agent gap reports** — cases where an agent missed something, gave wrong advice, or enforced an outdated pattern. These reports directly improve agent instructions. Use the [Agent Gap](https://github.com/Techopolis/swift-agents/issues/new?template=agent_gap.yml) issue template.

### Improve agent instructions

Each agent is a Markdown file with a system prompt. If you know a pattern an agent should catch, or a rule it enforces incorrectly, open a PR with the fix. Agent files live in:

- `.claude/agents/` — Claude Code agents

When updating an agent, follow the existing structure and tone of that agent's file.

### Add framework-specific patterns

The agents cover core Swift and SwiftUI but there is always room for more framework knowledge. If you work with MapKit, HealthKit, StoreKit, CloudKit, ARKit, or another Apple framework and know patterns or pitfalls specific to it, those additions are welcome in the relevant agent instructions.

### Add platform coverage

The agents focus on iOS and macOS. watchOS, visionOS, and tvOS knowledge is welcome, especially accessibility patterns and platform-specific concurrency considerations.

### Fix installer or hook scripts

The hook scripts support macOS, Linux, and Windows. Bug fixes and improvements are welcome, especially for edge cases on systems we have not tested.

### Improve documentation

Clearer docs, better examples, typo fixes — all welcome.

## How to Submit a PR

1. Fork the repo
2. Create a branch from `main` (`git checkout -b my-fix`)
3. Make your changes
4. Test on your system (copy the `.claude` folder into a Swift project, verify agents load with `/agents`)
5. Open a PR with a clear description of what changed and why

## Guidelines

- **Keep agent instructions focused.** Each agent owns one domain. Do not add concurrency rules to the SwiftUI agent or security patterns to the testing agent.
- **Match the existing style.** Read the agent you are modifying before making changes. Follow the same structure and tone.
- **Cite Swift Evolution proposals.** When adding concurrency or language-level patterns, reference the SE number (e.g., SE-0466).
- **Test your changes.** Install the agents and verify they work. If you changed an agent, try invoking it with a prompt that exercises the change.
- **One concern per PR.** A PR that fixes one agent gap is easier to review than one that changes five agents and the installer.

## Code of Conduct

This project follows a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold it. Be kind, be respectful, and remember that good tooling helps everyone.

## Questions?

Open a [discussion](https://github.com/Techopolis/swift-agents/discussions) or file an issue. No question is too basic.
