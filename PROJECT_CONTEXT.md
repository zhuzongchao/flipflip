# Project Context

## Project Identity

- Purpose: FlipFlip desktop Electron application for organizing and playing image, video, audio, and script scenes.
- Users: FlipFlip users and maintainers.
- Current objective: Electron compatibility migration T3.1 on the `upgrade-electron` branch.
- Repository root: This directory.

## Scope And Constraints

- Confirmed requirements: Upgrade webpack and directly related build loaders/plugins; verify build and app startup.
- Non-goals: Do not change dependencies outside Electron and `@electron/remote`; T3.2-T3.4 remain out of scope.
- Compatibility and delivery constraints: Windows development; Electron 43.4.1 runtime; webpack 5 must build both main and renderer bundles.
- Quality and safety rules: Keep changes focused and preserve existing behavior.

## Directory Map

| Relative path | Purpose | Notes |
|---|---|---|
| `src/main` | Electron main-process TypeScript | Bundled to `dist/main.bundle.js` |
| `src/renderer` | React renderer application | Bundled to `dist/renderer.bundle.js` |
| `webpack.dev.js` | Development webpack configuration | Multi-compiler config |
| `webpack.prod.js` | Production webpack configuration | Multi-compiler config |
| `MAINTENANCE.md` | Maintenance roadmap and task list | T3.1 status |
| `dist` | Generated bundles | Recreated by build scripts |

## Architecture And Data Flow

- Inputs: TypeScript/TSX, SCSS/CSS, fonts, and image assets under `src`.
- Processing: webpack compiles separate Electron main and renderer targets.
- Outputs: JavaScript bundles and copied assets under `dist`.
- Important interfaces and formats: Electron main entry is `src/main/main.ts`; renderer entry is `src/renderer/renderer.tsx`.

## Environment Bootstrap

- Prerequisites: Node.js, Yarn 1, Windows; existing `node_modules` may be reused.
- Install: `yarn install`.
- Run: Clear `NODE_OPTIONS` and `ELECTRON_RUN_AS_NODE`, then run `yarn start` after building.
- Test and validate: `yarn build`; `yarn production`.
- Build or deliver: `yarn build` creates development bundles; `yarn production` creates production bundles.
- Configuration and secret names: None required for build.

## Active Artifacts

- Source input: `src/`.
- Editable baseline: `upgrade-electron` at the T3.1 working tree.
- Latest output: `dist/` (generated).
- Latest delivery artifact: None.
- Standards and specifications: `MAINTENANCE.md`.
- Logs and issue tracking: Git history and `MAINTENANCE.md`.

## Current State

- Completed: Environment setup, baseline build/start validation, VS Code tasks.
- In progress: T3.1 Electron 4.2.12 to 43.4.1 compatibility migration.
- Next action: Commit T3.1 after review; T3.2 runtime regression remains pending.
- Blockers: None known.
- Known risks: Broader runtime regression and packaging remain deferred to T3.2/T3.3.
- Delivery readiness: T3.1 typecheck, build, and Electron startup pass; broader runtime regression is deferred to T3.2.

## Durable Decisions

| Date | Decision | Reason | Affected paths |
|---|---|---|---|
| 2026-08-21 | Upgrade only the webpack build chain for T1 | Keep migration incremental and verifiable | `package.json`, `yarn.lock`, webpack configs |

## Handover Checklist

1. Read this file and `MAINTENANCE.md`.
2. Verify `src`, webpack configs, and `dist` exist.
3. Run `yarn build` before material edits and after changes.
4. Review current blockers and risks.

## Change Record

| Date | Material change | Reason | Detail |
|---|---|---|---|
| 2026-08-21 | Added project handover context | Make the project portable between sessions | Captures T1 baseline and validation commands |
| 2026-08-21 | Migrated build chain to webpack 5 | Complete T1 | Upgraded webpack/loaders, adjusted CLI and loader options, verified builds |
| 2026-08-21 | Bumped application version to 3.2.3 | Mark the webpack migration release | Updated `package.json` and `yarn.lock` |
| 2026-08-21 | Migrated TypeScript to 5.9.3 | Complete T2 | Updated React 17 declaration packages, fixed strict return annotations, verified `tsc --noEmit` and `yarn build` |
| 2026-08-22 | Migrated Electron to 43.4.1 compatibility mode | Complete T3.1 | Added `@electron/remote`, explicit webPreferences flags, cache IPC, and verified typecheck/build/startup |
