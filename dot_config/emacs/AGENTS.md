# Operational Instructions for Agents

## CRITICAL INSTRUCTION: Configuration & Lisp Diagnostics

These rules are mandatory whenever touching the Emacs configuration. Follow this exact order to avoid shipping broken code.

### 1. Syntax Validation (Elisp & Org) 

**For Emacs Lisp files (`init.el`, `early-init.el`):**
- **Validate:** `python bin/validate-lisp-syntax.py FILE.el`
- **Blocker:** If the tool reports issues, do NOT apply the change. Fix the syntax first.
- *Note:* Do not run this validator on bash scripts like `bin/emacs-cli`.

**For Org Configuration (`config.org`):**
- **Validate:** `./bin/validate-config`
- This script checks for unclosed source blocks and basic syntax errors in the literate config.

### 2. Batch Lint/Compile Workflow

Use these commands to verify that changes don't break the startup or compilation.

**Smoke Test (Load Configuration):**
- `emacs -Q --batch --eval '(setq user-emacs-directory default-directory)' -l init.el --eval '(message "Startup OK")'`
- *Note:* This will attempt to tangle `config.org`. Ensure `config.org` is valid before running.

**Byte-Compile (Stricter Checks):**
- `emacs -Q --batch -L . --eval '(setq byte-compile-error-on-warn t)' -f batch-byte-compile init.el early-init.el`
- *Note on init.el:* Because `init.el` uses Elpaca to dynamically load packages asynchronously, it relies on file-local variables (`-*- byte-compile-warnings: (not free-vars unresolved); -*-`) to suppress false-positive warnings. Do not clutter `init.el` with `with-no-warnings` or `eval-when-compile` blocks just to appease the byte-compiler.

### 3. Escaping Rules (Common Traps)

- **Quotes in Strings:** Escape inner quotes with backslash (`\"`), not backticks.
  - Correct: `"Org uses \"* User\""`
- **Regex:** Double-escape backslashes inside strings.
  - Correct: `"^\\* User"` (matches literal `\* User`)

## CRITICAL INSTRUCTION: Session Snapshot at Start

At this stage of the project; Agent MUST NOT run any Git commands UNTIL User asks.
Before making any changes in a new working session (first action after opening the repo), create a local rollback snapshot using file copies only.

- **Create Snapshot:**
  ```bash
  mkdir -p snapshots/$(date +%Y%m%d-%H%M%S)
  cp -a init.el early-init.el config.org bin/ README.md GEMINI.md snapshots/$(date +%Y%m%d-%H%M%S)/ 2>/dev/null || true
  ```
- **Audit:** Always show the full Stdout/Stderr of the snapshot commands.
- **Rollback:** If requested, restore from the matching `snapshots/<timestamp>/` directory via `cp -a`.

## CRITICAL INSTRUCTION: Codebase Grounding & Emacs 30+ Standards

**Rule:** Never assume the existence or signature of a function.
- **Check Definitions:** Read `config.org` or `init.el` to verify custom functions (e.g., `my/yas-try-expand-first`) before using them.
- **Modern Equivalents:** Always use modern Emacs 29+ / 30+ functions and variables.
  - Use `native-comp-jit-compilation` instead of the obsolete `comp-deferred-compilation`.
  - Use `after-focus-change-function` (via `add-function`) instead of the obsolete `focus-out-hook`.
- **Project Structure:**
  - `init.el`: Bootstrapping. Must remain minimal and use file-local warning suppression for Elpaca.
  - `config.org`: Main logic (tangled to `.el`).
  - `.local/`: All generated data (do not rely on files here for config).

## Commit Discipline

- **Defer Commits:** Request evaluation first.
- **Snapshot First:** Use the snapshot mechanism for iterations.
- **Commit:** Only commit when the user explicitly approves or after a successful "wrap up".