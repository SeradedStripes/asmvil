name := "asmvil"
main_src := "main"
build_dir := "build"
src_dir := "src"

default: build

native-arch:
    #!/usr/bin/env bash
    case "$(uname -m)" in
        x86_64|amd64) echo "x86_64" ;;
        aarch64|arm64) echo "aarch64" ;;
        *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
    esac

build: 
    #!/usr/bin/env bash
    set -euo pipefail
    case "$(uname -m)" in
        x86_64|amd64)
            just build-x86_64
            ;;
        aarch64|arm64)
            just build-aarch64
            ;;
        *)
            echo "Unsupported architecture: $(uname -m)" >&2
            exit 1
            ;;
    esac

build-all: build-x86_64 build-aarch64

build-x86_64:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{build_dir}}/{{name}}_x86_64
    as --64 -I include/x86_64 -o {{build_dir}}/{{name}}_x86_64/{{name}}.o {{src_dir}}/x86_64/{{main_src}}.asm
    ld -m elf_x86_64 -o {{build_dir}}/{{name}}_x86_64/{{name}} {{build_dir}}/{{name}}_x86_64/{{name}}.o
    echo "Built: {{build_dir}}/{{name}}_x86_64/{{name}}"

build-aarch64:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{build_dir}}/{{name}}_aarch64
    as -march=armv8-a -I include/aarch64 -o {{build_dir}}/{{name}}_aarch64/{{name}}.o {{src_dir}}/aarch64/{{main_src}}.asm
    ld -m aarch64linux -o {{build_dir}}/{{name}}_aarch64/{{name}} {{build_dir}}/{{name}}_aarch64/{{name}}.o
    echo "Built: {{build_dir}}/{{name}}_aarch64/{{name}}"

run: build
    ./{{build_dir}}/{{name}}_$(uname -m)/{{name}}

clean:
    rm -rf {{build_dir}}
    echo "Cleaned build directory"

test:
    #!/usr/bin/env bash
    set -euo pipefail
    case "$(uname -m)" in
        x86_64|amd64)
            arch=x86_64
            asflags="--64"
            ldflags="-m elf_x86_64"
            ;;
        aarch64|arm64)
            arch=aarch64
            asflags="-march=armv8-a"
            ldflags="-m aarch64linux"
            ;;
        *)
            echo "Unsupported architecture: $(uname -m)" >&2
            exit 1
            ;;
    esac
    testdir="tests/$arch"
    if [ ! -d "$testdir" ] || [ -z "$(ls -A "$testdir" 2>/dev/null)" ]; then
        echo "No tests found in $testdir/"
        exit 0
    fi
    for test in "$testdir"/*.asm; do
        echo "Testing: $test"
        as $asflags -I "include/$arch" -o /tmp/test.o "$test"
        ld $ldflags -o /tmp/test /tmp/test.o
        /tmp/test
        echo "PASS: $test"
        rm -f /tmp/test /tmp/test.o
    done
    echo "All tests passed"

fmt:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "fmt is not configured for assembly yet"

lint:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "lint is not configured for assembly yet"
