# desktop-cat

A lightweight macOS desktop companion cat.

Desktop Cat is not a chatbot, game, or technical demo. The goal is to make a small cat feel quietly present on the user's desktop while they work.

## Current Stage

Internal Alpha, Sprint 1.

Sprint 1 does not implement AI generation, uploads, reminders, or advanced interactions. It prepares the project so future Codex sessions can build the first runnable prototype from a stable foundation.

## First Prototype Goal

A macOS user can open the app and see a small demo black cat on the desktop.

The cat should eventually:

- appear in a transparent desktop window
- idle quietly
- walk occasionally
- be draggable by the user
- close cleanly

## Project Rules

- Companion first.
- Keep V1 lightweight.
- Prefer reusable behavior composition over new animations.
- Do not add growth systems, complex personality systems, cloud sync, or commercialization to V1.
- Future AI image generation must be replaceable through an AI service layer.
- Every change should update the relevant project document when it affects scope, architecture, or decisions.

## Where To Start

Read these files in order:

1. `PROJECT.md`
2. `MASTER_PLAN.md`
3. `DECISIONS.md`
4. `ARCHITECTURE.md`
5. `TODO.md`

## Run The Prototype

```sh
./scripts/build-app.sh
open build/DesktopCat.app
```

The current prototype is native Swift/AppKit. It displays a transparent desktop window with a cartoon black cat, a moving tail, and occasional slow walking.
