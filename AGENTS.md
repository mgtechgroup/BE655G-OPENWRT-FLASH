# AGENTS.md
> **Key ID: LLMX-MASTER-20260427**
> Cross-platform: Windows/Linux/macOS/WSL/Git Bash/PowerShell/CMD

## Active Agents

### windows-env-auditor
- **Trigger:** `/env-audit`
- **Purpose:** PATH/Python drift, broken installs, environment audits
- **Invocations:** Use `Task` tool with subagent_type `windows-env-auditor`

### repo-installer
- **Trigger:** `/install-repo <url>`
- **Purpose:** Clone → install workflow for GitHub repos (Windows-aware)
- **Invocations:** Use `Task` tool with subagent_type `repo-installer`

### security-gatekeeper
- **Trigger:** `/audit`
- **Purpose:** Runs gitleaks + semgrep + pip-audit + shellcheck
- **Invocations:** Use `Task` tool with subagent_type `security-gatekeeper`
- **Rule:** Run before every push

### self-audit-orchestrator
- **Trigger:** `/cycle-start`, `/cycle-end`
- **Purpose:** 14-day capability cycle audits
- **Invocations:** Use `Task` tool with subagent_type `self-audit-orchestrator`

## Master Task File

All pending tasks are tracked in `todo-master.json` (single source of truth).
Location: `~/.ai-memory/todo-master.json`
Cross-platform aliases: `tasks.json`, `master-todo.json`

On task completion, update the corresponding entry in todo-master.json.

## Model Logging

Every session must log to `memory.jsonl`:
- Model identifier
- Session ID, start timestamp, entry point
- Last active timestamp on session end

Location: `~/.ai-memory/memory.jsonl`
Cross-platform aliases: `audit.jsonl`, `learning.log`

## Cross-Platform Memory Resolution

```
Memory path check order:
1. $AI_MEMORY_PATH env var
2. $CLAUDE_MEMORY_PATH env var
3. Platform-specific default:
   - Windows: $env:USERPROFILE\.ai-memory
   - Git Bash: /c/Users/AzielMelek/.ai-memory
   - WSL: /mnt/c/Users/AzielMelek/.ai-memory
   - Unix: ~/.ai-memory
```

---

*Generated: 2026-04-27 | Key: LLMX-MASTER-20260427*

## Project Index File

For full mgtechgroup project details (92+ repos), see:
- `~/.ai-memory/mgtechgroup-projects.md`
