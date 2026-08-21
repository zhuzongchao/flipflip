---
name: portable-project-handover
description: Make software, data, localization, automation, and document-processing projects portable across computers and AI sessions. Use when creating, resuming, restructuring, handing over, or materially changing a project. Maintain a machine-independent project entry document so a new AI or developer can restore the environment, locate the active baseline, verify current state, and continue safely without chat history.
---

# Portable Project Handover

Maintain `PROJECT_CONTEXT.md` in the project root as the handover source of truth. It must let a capable AI or developer on another computer understand the project and continue it without relying on IDE tabs, terminal history, local absolute paths, or a previous chat.

## Start Or Resume Work

1. Verify `.codex/skills/portable-project-handover/SKILL.md` exists. If it is absent or stale, run the global Skill's `scripts/install-to-project-skills.ps1 -ProjectRoot <project-root> -Force`.
2. Locate and read `PROJECT_CONTEXT.md` before making material changes.
3. Read the linked specifications, standards, logs, and active artifacts named there.
4. Inspect the actual project structure and current state. Treat files as evidence; correct stale context rather than trusting it blindly.
5. Identify the active source, editable baseline, delivery artifact, and next action before editing.
6. If the file is missing, create it from `assets/PROJECT_CONTEXT.template.md` before or alongside the first material change.

## Maintain The Document

Use concise, confirmed information. Retain sections that apply:

- project identity, purpose, users, scope, constraints, and non-goals;
- portable directory map using project-relative paths;
- architecture, data flow, interfaces, and important formats;
- environment bootstrap: prerequisites, install, run, test, build, validation, and delivery commands;
- configuration prerequisites and secret *names* only, never secret values;
- active source, baseline, output, delivery, standards, and log artifacts;
- current status: completed work, work in progress, next action, blockers, risks, and delivery readiness;
- durable decisions and conventions, with reason, date, and affected files;
- short dated change record and a first-read handover checklist.

Link to detailed specifications and logs instead of duplicating them. Preserve project documentation; `PROJECT_CONTEXT.md` is its entry index and current-state record.

## Update Rules

Update `PROJECT_CONTEXT.md` when requirements, scope, directory layout, architecture, schemas, dependencies, data sources, active baselines, outputs, tools, commands, progress, blockers, risks, or durable decisions change. Do not update it for trivial formatting-only edits.

Before ending material work, verify that the document identifies the real active baseline, latest delivery status, and next recommended action.

## Portability Rules

- Use paths relative to the project root. State platform-specific prerequisites explicitly.
- Keep dependency declarations, scripts, templates, standards, source inputs, generated outputs, and logs in the project.
- Check `.gitignore` and repository tracking. If the active baseline, delivery artifact, source data, or logs are not versioned, document how a new computer obtains them from an approved shared location or transfer package.
- Do not record API keys, tokens, passwords, personal data, or confidential values. Document only variable names, configuration templates, and access prerequisites.
- Do not depend on a specific AI model or local tool without documenting a usable fallback or setup path.
- Keep the portable skill under `.codex/skills/portable-project-handover/`. On another computer, run `scripts/install-to-user-skills.ps1` from that folder to install it into the user's global Codex skill directory.
- From a globally installed Skill, run `scripts/install-to-project-skills.ps1 -ProjectRoot <project-root>` to seed a project-local copy. Use `-Force` only after confirming that the project copy should be replaced.
- When `PROJECT_CONTEXT.md` references this Skill, verify the referenced project-local directory exists before ending material work; repair the copy or remove the stale reference.
- Before handover, make sure a fresh reader can identify the active baseline and next action in under five minutes.
