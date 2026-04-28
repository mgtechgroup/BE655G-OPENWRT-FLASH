# CLAUDE.md
> **Key ID: LLMX-MASTER-20260427**
> This file binds the master memory directive. Load on every session.
> Cross-platform: Works on Windows/Linux/macOS/WSL/Git Bash/PowerShell/CMD

## Core Memory Entry Point

Say **"system scan for core ai memory"** to load full context.

## Memory Cache Paths (Cross-Platform)

| Platform | Path |
|----------|------|
| Git Bash | `/c/Users/AzielMelek/.ai-memory` |
| PowerShell | `$env:USERPROFILE\.ai-memory` |
| CMD | `%USERPROFILE%\.ai-memory` |
| WSL | `/mnt/c/Users/AzielMelek/.ai-memory` |
| Unix | `~/.ai-memory` |

**Env var check first:** `AI_MEMORY_PATH`, `CLAUDE_MEMORY_PATH`, `MEMORY_CACHE_PATH`

## Core Files

| File | Purpose |
|------|---------|
| `master-key.md` | ROOT authority, Key ID LLMX-MASTER-20260427 |
| `system-memory-index.json` | Full system snapshot, path aliases, triggers |
| `context.json` | Session + model tracking |
| `todo-master.json` | Master task file |
| `projects.json` | Project registry (12 repos) |
| `mgtechgroup-projects.md` | Detailed mgtechgroup project index (92 repos) |
| `memory.jsonl` | Append-only learning log |

## Directive Summary

1. **Security first** — Never store secrets in memory or code
2. **Log all model sessions** — Record to `memory.jsonl` on every session
3. **Maintain constant memory cache** — Update `context.json` with `model_in_use`, `all_models_used[]`
4. **Use master todo file** — All tasks in `todo-master.json` as single source of truth
5. **Append-only audit log** — Write to `security/audit-log.md`

## Environment Variables

| Var | Aliases |
|-----|---------|
| Memory path | `AI_MEMORY_PATH`, `CLAUDE_MEMORY_PATH`, `MEMORY_CACHE_PATH` |
| Ollama host | `OLLAMA_HOST`, `OLLAMA_URL` |
| Docker context | `DOCKER_CONTEXT`, `DOCKER_DEFAULT_CONTEXT` |

## Agents

Invoke via `Task` tool when task matches:
- `windows-env-auditor` → `/env-audit`
- `repo-installer` → `/install-repo <url>`
- `security-gatekeeper` → `/audit`
- `self-audit-orchestrator` → `/cycle-start`

## System Info

- OS: Windows 11 Pro
- Primary shell: Git Bash / PowerShell
- Primary model: claude-sonnet-4
- Backup model: qwen2.5-coder:7b
- Ollama: localhost:11434
- Docker: desktop-linux

## Git Conventions

Use conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `sec:`, `refactor:`, `test:`

---

*Generated: 2026-04-27 | Key: LLMX-MASTER-20260427*
