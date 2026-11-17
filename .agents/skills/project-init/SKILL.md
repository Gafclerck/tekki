---
name: project-init
description: Initialise un projet Flutter avec Git, Clean Architecture feature-first, workflow Gitflow, Conventional Commits et validation complète.
---

# Project Initialization

## Objective

Initialize a new Flutter project from an empty or unconfigured directory.

Always inspect the current state before executing commands. Never assume that Git, Flutter, branches, or project files are already configured.

## 1. Inspect

Before changing anything:

* Check whether the directory contains files.
* Check whether Git is initialized.
* Check the current branch.
* Check whether `main` and `develop` exist.
* Check Flutter and Dart versions.
* Inspect the available project configuration.

Never overwrite existing project files without explicit justification.

## 2. Initial Git Repository

If Git is not initialized:

1. Initialize Git.
2. If the project contains no source code, create `.gitkeep` at the repository root.
3. Create the initial commit:

```text
chore: initialize repository
```

The initial commit must exist before creating the development branch.

## 3. Main and Develop

The repository must use:

```text
main
develop
```

Rules:

* `main` is protected from direct development.
* `develop` is protected from direct development.
* Never implement features directly on either branch.

If the initial branch has another name, rename it to `main`.

Create `develop` from `main`.

## 4. Tooling Branch

Create the first project setup branch from `develop`:

```text
feat/001-tooling
```

All initial project configuration must be performed on this branch.

Examples:

* Flutter project configuration
* linting
* formatting
* dependency configuration
* project structure
* environment configuration
* testing infrastructure
* CI configuration
* documentation required for development

Do not mix product features into this branch.

## 5. Flutter Architecture

The project must follow:

```text
Clean Architecture
        +
Feature-first
```

Each feature must respect:

```text
feature/
├── presentation/
├── domain/
└── data/
```

Shared functionality genuinely used by multiple features belongs in:

```text
core/
```

Do not create speculative abstractions in `core`.

Keep dependencies flowing toward the domain layer.

## 6. Code Quality

The project must follow:

* SOLID principles.
* Single Responsibility.
* Open/Closed Principle.
* Interface Segregation.
* Inversion of Control.
* Low coupling.
* High cohesion.
* Small and focused widgets.
* Separation of UI, business logic, and data access.

Never put business logic or data access directly inside widgets.

Prefer existing project abstractions over introducing new ones.

## 7. Commits

Use Conventional Commits.

Allowed prefixes include:

```text
feat:
fix:
refactor:
chore:
test:
docs:
build:
ci:
```

Rules:

* One logical change per commit.
* Message must be clear and precise.
* Message must be short.
* Commit message must remain on one line.
* Never create meaningless commits.

Examples:

```text
chore: configure flutter project
chore: add lint configuration
test: configure test environment
ci: add flutter checks
```

## 8. Validation

Before considering `feat/001-tooling` complete:

```bash
flutter pub get
flutter analyze
flutter test
```

Fix all errors introduced by the setup.

Do not declare the project ready while validation is failing.

## 9. Integration

When the tooling branch is complete:

1. Verify the working tree is clean.
2. Verify all relevant checks pass.
3. Prepare a Pull Request from:

```text
feat/001-tooling → develop
```

Do not merge if validation fails.

After integration, verify that `develop` remains functional.

## 10. Initial Release

Once the initial project setup has been integrated into `develop`, create the initial development release:

```text
v0.1.0
```

Use Semantic Versioning.

For the initial project setup, tagging `v0.1.0` from the validated `develop` state is acceptable.

For later production releases, follow the project's established release workflow.

## 11. Final Verification

Before finishing, report:

* Current branch.
* Git status.
* Created branches.
* Important commits.
* Flutter version.
* Validation results.
* Final project structure.
* Whether `feat/001-tooling` is ready for Pull Request.

Never claim that an operation succeeded without verifying its result.

## Restrictions

* Never work directly on `main`.
* Never work directly on `develop`.
* Never skip validation.
* Never overwrite existing project configuration blindly.
* Never create unnecessary abstractions.
* Never put shared feature-specific logic in `core`.
* Never overload widgets.
* Never bypass the project's architecture.

Comments must be concise and meaningful.

Do not use em dashes (`—`). Use regular hyphens (`-`).

Avoid decorative comment separators or repeated symbols.

