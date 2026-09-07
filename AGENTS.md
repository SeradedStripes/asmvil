# AGENTS.md

## Project

ASMVIL, a super lightweight deployment system written entirely in assembly.
Targets Linux on both **x86-64** and **aarch64**.

## Build

Uses **GNU `as`** and **GNU `ld`** directly, no gcc, no C, no linker scripting.

Tooling is driven by [`just`](https://github.com/casey/just) via the `justfile`:

```bash
just build         # build for the native host arch (detected via uname -m)
just build-all     # build for both x86_64 and aarch64
just build-x86_64  # build only x86-64
just build-aarch64 # build only aarch64
just test          # assemble+link+run tests for the native host arch
just clean         # remove build/
just run           # build and run the native binary
```

`fmt` and `lint` are currently stubs.

## Cross-platform code

Keep files **cross-platform** where possible, and only split into
arch-specific files (or arch-specific builds) when you must. Both architectures
share one conceptual source, and arch-specific pieces are selected by the build
via `-I include/<arch>` / `src/<arch>/`. Avoid duplicating logic per arch; call
into arch-specific helpers only where the ABI or syscalls genuinely differ.

There is a **single shared `src/main.asm`** that calls arch-specific helpers.
Cross-platform logic (entry point, application flow) lives in `src/main.asm`,
and arch-specific pieces (syscall wrappers like `sys_exit`) live under
`src/<arch>/` and are called into from the shared code.

## Directory layout

A single shared source file keeps cross-platform logic in one place, with
arch-specific helpers split out where the ABI or syscalls genuinely differ.
Includes and tests are arch-specific and mirrored, never assume the same
file assembles for both architectures.

```
src/main.asm          # shared entry point / cross-platform logic (calls arch code)
src/x86_64/*.asm      # x86-64 helpers (syscall.asm: sys_exit, Intel syntax)
src/aarch64/*.asm     # aarch64 helpers (syscall.asm: sys_exit, ARM syntax)
include/x86_64/*.inc  # x86-64 includes (common.inc: syscall constants)
include/aarch64/*.inc # aarch64 includes (common.inc: syscall constants)
tests/x86_64/*.asm    # x86-64 tests
tests/aarch64/*.asm   # aarch64 tests
build/                # generated, gitignored
```

The `justfile` passes the matching include dir via `as -I include/<arch>` so
`.include "common.inc"` resolves to the correct arch in both `src/` and
`tests/` files. Each build assembles the shared `src/main.asm` together with
the matching `src/<arch>/syscall.asm` and links both objects.

## Architecture notes

- **x86-64**: GAS `.intel_syntax noprefix`; syscall numbers are `SYS_READ 0`,
  `SYS_WRITE 1`, `SYS_EXIT 60`. Built with `as --64` / `ld -m elf_x86_64`.
- **aarch64**: standard GAS ARM syntax (no `.intel_syntax`); syscall numbers
  are `SYS_READ 63`, `SYS_WRITE 64`, `SYS_EXIT 93`. Built with
  `as -march=armv8-a` / `ld -m aarch64linux`.

GAS quirks when writing x86-64 Intel-syntax code:
- Use `mov rdx, offset symbol` (not `mov rdx, symbol`) to load an immediate
  address; bare `symbol` is treated as a memory reference.
- Use `lea rsi, [rip + symbol]` for RIP-relative addressing across text/data.

## Code style

- **No em dashes (—).** Do not use em dashes in code, comments, or docs; use
  regular punctuation (commas, hyphens, parentheses) instead.
- **Comment only when necessary.** Code should be self-explanatory; comment the
  "why", not the "what". No decorative or redundant comments.
- **All code requires human review.** Never merge or mark work as final without
  a human reviewing it. AI-generated code is welcome but must be reviewed the
  same as any other contribution.

## Testing

Every assembly change must add/keep a matching test under `tests/<arch>/`.
A test is a standalone `.asm` with a `_start` that exits 0 on success.
`just test` assembles, links, and runs each one, and fails if any exit non-zero.
Tests live in arch-specific dirs and are run natively per-arch.

## CI

`.github/workflows/ci.yml` builds and tests natively on a matrix:
`ubuntu-latest` (x86_64) and `ubuntu-24.04-arm` (aarch64).
Always run `just test` locally before pushing.
