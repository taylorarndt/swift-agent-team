# Security Policy

## Scope

Swift Agents consists of Markdown agent instructions and shell scripts (bash and PowerShell). The agents themselves do not execute code, access networks, or store credentials. The hook scripts output text instructions and do not perform file operations or network calls.

## Supported Versions

| Version | Supported |
|---------|-----------|
| Latest release | Yes |
| Older releases | No |

We recommend always using the latest version.

## Reporting a Vulnerability

If you discover a security issue, please report it responsibly.

**Do not open a public issue.**

Instead, email the maintainer directly or use [GitHub's private vulnerability reporting](https://github.com/Techopolis/swift-agents/security/advisories/new).

We will acknowledge receipt within 48 hours and provide a fix or mitigation as quickly as possible.

## What to Report

- Hook scripts executing unintended commands
- Agent instructions that could cause Claude to leak sensitive data
- Any file operation that could overwrite or delete user data unexpectedly

## What Is Not in Scope

- The content of agent instructions (these are prompts, not executable code)
- Swift pattern accuracy (use the Agent Gap issue template for that)
