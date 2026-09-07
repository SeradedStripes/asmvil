name := "asmvil"
main_src := "main"
build_dir := "build"
src_dir := "src"

default: build

build: build-x86_64

build-all: build-x86_64 build-aarch64

build-x86_64:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{build_dir}}/{{name}}_x86_64
    as --64 -I include/x86_64 -o {{build_dir}}/{{name}}_x86_64/{{name}}.o {{src_dir}}/{{main_src}}.asm
    ld -m elf_x86_64 -o {{build_dir}}/{{name}}_x86_64/{{name}} {{build_dir}}/{{name}}_x86_64/{{name}}.o
    echo "Built: {{build_dir}}/{{name}}_x86_64/{{name}}"

build-aarch64:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{build_dir}}/{{name}}_aarch64
    as -march=armv8-a -I include/aarch64 -o {{build_dir}}/{{name}}_aarch64/{{name}}.o {{src_dir}}/{{main_src}}.asm
    ld -m aarch64linux -o {{build_dir}}/{{name}}_aarch64/{{name}} {{build_dir}}/{{name}}_aarch64/{{name}}.o
    echo "Built: {{build_dir}}/{{name}}_aarch64/{{name}}"

run: build
    ./{{build_dir}}/{{name}}_x86_64/{{name}}

clean:
    rm -rf {{build_dir}}
    echo "Cleaned build directory"

test:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "$(ls -A tests/ 2>/dev/null)" ]; then
        echo "No tests found in tests/"
        exit 0
    fi
    for test in tests/*.asm; do
        echo "Testing: $test"
        as --64 -I include/x86_64 -o /tmp/test.o "$test"
        ld -m elf_x86_64 -o /tmp/test /tmp/test.o
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
