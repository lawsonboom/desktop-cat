# Architecture

## Principle

Keep the app modular, lightweight, and easy for future Codex sessions to extend.

## Target Platform

macOS first.

The expected final install format is a DMG.

## Candidate Stack

The preferred direction is a lightweight desktop app stack such as Tauri with a simple web UI layer.

This is not yet final. Sprint 1 should not lock in unnecessary dependencies before the first prototype task begins.

## Core Modules

### Render

Draws the cat and any small UI elements such as speech bubbles.

Render does not decide behavior.

### Motion

Plays reusable motions such as idle, walk, sit, sleep, stretch, groom, eat, and paw.

Motion does not decide why an action occurs.

### Brain

Chooses the next behavior.

The brain should answer one question: what should the cat do next?

### Interaction

Receives user input such as dragging, petting, feeding, and toy actions.

Interaction sends events to the brain.

### Scheduler

Tracks time-based events such as work duration, idle time, and future habit routines.

### Resources

Manages cat profiles, demo assets, generated assets, configuration, and local data.

### AI Service

Handles future AI image generation through replaceable providers.

The application must not call a specific image API directly from unrelated modules.

## Data Flow

User input or time event enters Interaction or Scheduler.

Brain decides the next behavior.

Motion selects the motion or sequence.

Render displays the result.

Resources provide assets and settings.

## V1 Constraint

Prefer behavior composition over new assets. A new feature that requires several new animations should move to the backlog unless it directly improves companionship.

