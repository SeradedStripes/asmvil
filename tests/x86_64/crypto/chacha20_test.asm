.intel_syntax noprefix
.include "common.inc"

# RFC 8439 block, stream, in-place and counter-exhaustion tests.

.global _start

.macro CHECK dat, exp, n
    lea rdi, [rip + \dat]
    lea rsi, [rip + \exp]
    mov rdx, \n
    call expect
.endm

.macro INIT counter, nonce
    lea rdi, [rip + ctx]
    lea rsi, [rip + key]
    mov edx, \counter
    lea rcx, [rip + \nonce]
    call chacha20_init
.endm

.macro XOR_OK src, dst, n
    lea rdi, [rip + ctx]
    lea rsi, [rip + \src]
    lea rdx, [rip + \dst]
    mov rcx, \n
    call chacha20_xor
    test al, al
    jz fail
.endm

.section .text
_start:
    # RFC 8439 section 2.3.2 block-function test.
    lea rdi, [rip + key]
    mov esi, 1
    lea rdx, [rip + block_nonce]
    lea rcx, [rip + block_out]
    call chacha20_block
    CHECK block_out, expected_block, 64

    # RFC 8439 section 2.4.2 encryption test.
    INIT 1, cipher_nonce
    XOR_OK plaintext, out, 114
    CHECK out, ciphertext, 114

    # The same stream split across a block boundary with a zero-length call.
    INIT 1, cipher_nonce
    XOR_OK plaintext, out, 63
    XOR_OK plaintext + 63, out + 63, 0
    XOR_OK plaintext + 63, out + 63, 51
    CHECK out, ciphertext, 114

    # Exact in-place decryption is supported.
    lea rdi, [rip + ciphertext]
    lea rsi, [rip + out]
    mov rdx, 114
    call copy
    INIT 1, cipher_nonce
    XOR_OK out, out, 114
    CHECK out, plaintext, 114

    # Counter 0xffffffff yields one final block and then rejects more output.
    lea rdi, [rip + key]
    mov esi, -1
    lea rdx, [rip + cipher_nonce]
    lea rcx, [rip + block_out]
    call chacha20_block
    INIT -1, cipher_nonce
    lea rdi, [rip + out]
    mov ecx, 65
.Lfill_sentinel:
    mov BYTE PTR [rdi], 0x5a
    inc rdi
    dec ecx
    jnz .Lfill_sentinel
    lea rdi, [rip + ctx]
    lea rsi, [rip + zeroes]
    lea rdx, [rip + out]
    mov ecx, 65
    call chacha20_xor
    test al, al
    jnz fail
    lea rdi, [rip + out]
    mov ecx, 65
.Lcheck_sentinel:
    cmp BYTE PTR [rdi], 0x5a
    jne fail
    inc rdi
    dec ecx
    jnz .Lcheck_sentinel
    XOR_OK zeroes, out, 64
    CHECK out, block_out, 64
    lea rdi, [rip + ctx]
    lea rsi, [rip + zeroes]
    lea rdx, [rip + out + 64]
    mov ecx, 1
    call chacha20_xor
    test al, al
    jnz fail
    cmp BYTE PTR [rip + out + 64], 0x5a
    jne fail

    mov rax, SYS_EXIT
    xor edi, edi
    syscall

fail:
    mov rax, SYS_EXIT
    mov edi, 1
    syscall

expect:
    test rdx, rdx
    jz .Lexpect_done
.Lexpect_next:
    mov al, BYTE PTR [rdi]
    cmp al, BYTE PTR [rsi]
    jne fail
    inc rdi
    inc rsi
    dec rdx
    jnz .Lexpect_next
.Lexpect_done:
    ret

copy:
    test rdx, rdx
    jz .Lcopy_done
.Lcopy_next:
    mov al, BYTE PTR [rdi]
    mov BYTE PTR [rsi], al
    inc rdi
    inc rsi
    dec rdx
    jnz .Lcopy_next
.Lcopy_done:
    ret

.section .rodata
key:
    .byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07
    .byte 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f
    .byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17
    .byte 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f
block_nonce:
    .byte 0x00, 0x00, 0x00, 0x09, 0x00, 0x00
    .byte 0x00, 0x4a, 0x00, 0x00, 0x00, 0x00
cipher_nonce:
    .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .byte 0x00, 0x4a, 0x00, 0x00, 0x00, 0x00

plaintext:
    .ascii "Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it."

expected_block:
    .byte 0x10, 0xf1, 0xe7, 0xe4, 0xd1, 0x3b, 0x59, 0x15
    .byte 0x50, 0x0f, 0xdd, 0x1f, 0xa3, 0x20, 0x71, 0xc4
    .byte 0xc7, 0xd1, 0xf4, 0xc7, 0x33, 0xc0, 0x68, 0x03
    .byte 0x04, 0x22, 0xaa, 0x9a, 0xc3, 0xd4, 0x6c, 0x4e
    .byte 0xd2, 0x82, 0x64, 0x46, 0x07, 0x9f, 0xaa, 0x09
    .byte 0x14, 0xc2, 0xd7, 0x05, 0xd9, 0x8b, 0x02, 0xa2
    .byte 0xb5, 0x12, 0x9c, 0xd1, 0xde, 0x16, 0x4e, 0xb9
    .byte 0xcb, 0xd0, 0x83, 0xe8, 0xa2, 0x50, 0x3c, 0x4e

ciphertext:
    .byte 0x6e, 0x2e, 0x35, 0x9a, 0x25, 0x68, 0xf9, 0x80
    .byte 0x41, 0xba, 0x07, 0x28, 0xdd, 0x0d, 0x69, 0x81
    .byte 0xe9, 0x7e, 0x7a, 0xec, 0x1d, 0x43, 0x60, 0xc2
    .byte 0x0a, 0x27, 0xaf, 0xcc, 0xfd, 0x9f, 0xae, 0x0b
    .byte 0xf9, 0x1b, 0x65, 0xc5, 0x52, 0x47, 0x33, 0xab
    .byte 0x8f, 0x59, 0x3d, 0xab, 0xcd, 0x62, 0xb3, 0x57
    .byte 0x16, 0x39, 0xd6, 0x24, 0xe6, 0x51, 0x52, 0xab
    .byte 0x8f, 0x53, 0x0c, 0x35, 0x9f, 0x08, 0x61, 0xd8
    .byte 0x07, 0xca, 0x0d, 0xbf, 0x50, 0x0d, 0x6a, 0x61
    .byte 0x56, 0xa3, 0x8e, 0x08, 0x8a, 0x22, 0xb6, 0x5e
    .byte 0x52, 0xbc, 0x51, 0x4d, 0x16, 0xcc, 0xf8, 0x06
    .byte 0x81, 0x8c, 0xe9, 0x1a, 0xb7, 0x79, 0x37, 0x36
    .byte 0x5a, 0xf9, 0x0b, 0xbf, 0x74, 0xa3, 0x5b, 0xe6
    .byte 0xb4, 0x0b, 0x8e, 0xed, 0xf2, 0x78, 0x5e, 0x42
    .byte 0x87, 0x4d

.section .bss
.p2align 4
ctx:
    .zero 144
block_out:
    .zero 64
zeroes:
    .zero 64
out:
    .zero 128
