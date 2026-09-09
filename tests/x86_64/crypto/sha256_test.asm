.intel_syntax noprefix
.include "common.inc"

# sha256 tests: NIST vectors (FIPS 180-4) plus buffering/partitioning checks.
# exit 0 on success, 1 on failure.

.global _start

.section .text
_start:
    # empty message
    lea rdi, [rip + ctx]
    call sha256_init
    lea rdi, [rip + ctx]
    lea rsi, [rip + digest]
    call sha256_final
    lea rdi, [rip + digest]
    lea rsi, [rip + expect_empty]
    mov rdx, 32
    call expect

    # "abc" single call
    lea rdi, [rip + ctx]
    call sha256_init
    lea rdi, [rip + ctx]
    lea rsi, [rip + msg_abc]
    mov rdx, 3
    call sha256_update
    lea rdi, [rip + ctx]
    lea rsi, [rip + digest]
    call sha256_final
    lea rdi, [rip + digest]
    lea rsi, [rip + expect_abc]
    mov rdx, 32
    call expect

    # "abc" byte by byte (partial-buffer path)
    lea rdi, [rip + ctx]
    call sha256_init
    lea rbx, [rip + msg_abc]
    mov r12, 0
1:
    cmp r12, 3
    jae 2f
    lea rdi, [rip + ctx]
    lea rsi, [rbx + r12]
    mov rdx, 1
    call sha256_update
    add r12, 1
    jmp 1b
2:
    lea rdi, [rip + ctx]
    lea rsi, [rip + digest]
    call sha256_final
    lea rdi, [rip + digest]
    lea rsi, [rip + expect_abc]
    mov rdx, 32
    call expect

    # 56-byte message (448 bits) single call
    lea rdi, [rip + ctx]
    call sha256_init
    lea rdi, [rip + ctx]
    lea rsi, [rip + msg_448]
    mov rdx, 56
    call sha256_update
    lea rdi, [rip + ctx]
    lea rsi, [rip + digest]
    call sha256_final
    lea rdi, [rip + digest]
    lea rsi, [rip + expect_448]
    mov rdx, 32
    call expect

    # 56-byte message fed 48 then 8 (block-boundary crossing)
    lea rdi, [rip + ctx]
    call sha256_init
    lea rdi, [rip + ctx]
    lea rsi, [rip + msg_448]
    mov rdx, 48
    call sha256_update
    lea rdi, [rip + ctx]
    lea rsi, [rip + msg_448 + 48]
    mov rdx, 8
    call sha256_update
    lea rdi, [rip + ctx]
    lea rsi, [rip + digest]
    call sha256_final
    lea rdi, [rip + digest]
    lea rsi, [rip + expect_448]
    mov rdx, 32
    call expect

    # 100-byte message: single shot vs 60 + 40 (forces full-buffer compress mid-update)
    lea rdi, [rip + ctx]
    call sha256_init
    lea rdi, [rip + ctx]
    lea rsi, [rip + msg_100]
    mov rdx, 100
    call sha256_update
    lea rdi, [rip + ctx]
    lea rsi, [rip + digest]
    call sha256_final
    lea rdi, [rip + ctx2]
    call sha256_init
    lea rdi, [rip + ctx2]
    lea rsi, [rip + msg_100]
    mov rdx, 60
    call sha256_update
    lea rdi, [rip + ctx2]
    lea rsi, [rip + msg_100 + 60]
    mov rdx, 40
    call sha256_update
    lea rdi, [rip + ctx2]
    lea rsi, [rip + digest2]
    call sha256_final
    lea rdi, [rip + digest]
    lea rsi, [rip + digest2]
    mov rdx, 32
    call expect

    # one million 'a' (multi-block fast path)
    lea rdi, [rip + msg_a]
    mov rcx, 1000000
    mov rax, 0x6161616161616161
3:
    mov [rdi], rax
    add rdi, 8
    sub rcx, 8
    jnz 3b
    lea rdi, [rip + ctx]
    call sha256_init
    lea rdi, [rip + ctx]
    lea rsi, [rip + msg_a]
    mov rdx, 1000000
    call sha256_update
    lea rdi, [rip + ctx]
    lea rsi, [rip + digest]
    call sha256_final
    lea rdi, [rip + digest]
    lea rsi, [rip + expect_1ma]
    mov rdx, 32
    call expect

    # all good
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall

fail:
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

# expect(rdi=got, rsi=want, rdx=len) - exit 1 on mismatch
expect:
    push rbx
    push r12
    push r13
    mov r12, rdi
    mov r13, rsi
    mov rbx, rdx
0:
    test rbx, rbx
    jz 1f
    mov rax, [r12]
    mov rcx, [r13]
    cmp rax, rcx
    jne fail
    add r12, 8
    add r13, 8
    sub rbx, 8
    jmp 0b
1:
    pop r13
    pop r12
    pop rbx
    ret

.section .data
msg_abc:
    .asciz "abc"
msg_448:
    .asciz "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"

msg_100:
    .byte 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a
    .byte 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13
    .byte 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23
    .byte 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33
    .byte 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x40, 0x41, 0x42, 0x43
    .byte 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x53
    .byte 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f, 0x60, 0x61, 0x62, 0x63
    .byte 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 0x70, 0x71, 0x72, 0x73
    .byte 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f, 0x80, 0x81, 0x82, 0x83
    .byte 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f, 0x90, 0x91, 0x92, 0x93

expect_empty:
    .byte 0xe3, 0xb0, 0xc4, 0x42, 0x98, 0xfc, 0x1c, 0x14
    .byte 0x9a, 0xfb, 0xf4, 0xc8, 0x99, 0x6f, 0xb9, 0x24
    .byte 0x27, 0xae, 0x41, 0xe4, 0x64, 0x9b, 0x93, 0x4c
    .byte 0xa4, 0x95, 0x99, 0x1b, 0x78, 0x52, 0xb8, 0x55

expect_abc:
    .byte 0xba, 0x78, 0x16, 0xbf, 0x8f, 0x01, 0xcf, 0xea
    .byte 0x41, 0x41, 0x40, 0xde, 0x5d, 0xae, 0x22, 0x23
    .byte 0xb0, 0x03, 0x61, 0xa3, 0x96, 0x17, 0x7a, 0x9c
    .byte 0xb4, 0x10, 0xff, 0x61, 0xf2, 0x00, 0x15, 0xad

expect_448:
    .byte 0x24, 0x8d, 0x6a, 0x61, 0xd2, 0x06, 0x38, 0xb8
    .byte 0xe5, 0xc0, 0x26, 0x93, 0x0c, 0x3e, 0x60, 0x39
    .byte 0xa3, 0x3c, 0xe4, 0x59, 0x64, 0xff, 0x21, 0x67
    .byte 0xf6, 0xec, 0xed, 0xd4, 0x19, 0xdb, 0x06, 0xc1

expect_1ma:
    .byte 0xcd, 0xc7, 0x6e, 0x5c, 0x99, 0x14, 0xfb, 0x92
    .byte 0x81, 0xa1, 0xc7, 0xe2, 0x84, 0xd7, 0x3e, 0x67
    .byte 0xf1, 0x80, 0x9a, 0x48, 0xa4, 0x97, 0x20, 0x0e
    .byte 0x04, 0x6d, 0x39, 0xcc, 0xc7, 0x11, 0x2c, 0xd0

digest:
    .space 32
digest2:
    .space 32
ctx:
    .space 112
ctx2:
    .space 112

.bss
msg_a:
    .zero 1000000
