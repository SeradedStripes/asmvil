.intel_syntax noprefix
.include "common.inc"

# RFC 8439 section 2.8.2 AEAD vector; exit 0 on success.

.global _start

.macro CHECK dat, exp, n
    lea rdi, [rip + \dat]
    lea rsi, [rip + \exp]
    mov rdx, \n
    call expect
.endm

.macro INIT
    lea rdi, [rip + ctx]
    lea rsi, [rip + key]
    lea rdx, [rip + nonce]
    call aead_init
    test al, al
    jz fail
.endm

.section .text
_start:
    INIT
    lea rdi, [rip + ctx]
    lea rsi, [rip + aad]
    mov edx, 12
    call aead_update_aad
    test al, al
    jz fail
    lea rdi, [rip + ctx]
    lea rsi, [rip + plaintext]
    lea rdx, [rip + ciphertext_out]
    mov ecx, 114
    call aead_seal
    test al, al
    jz fail
    CHECK ciphertext_out, ciphertext, 114
    lea rdi, [rip + ctx]
    lea rsi, [rip + tag_out]
    call aead_final
    test al, al
    jz fail
    CHECK tag_out, tag, 16

    # Split AAD and ciphertext at non-block boundaries; finalization caches.
    INIT
    lea rdi, [rip + ctx]
    lea rsi, [rip + aad]
    mov edx, 5
    call aead_update_aad
    test al, al
    jz fail
    lea rdi, [rip + ctx]
    lea rsi, [rip + aad + 5]
    mov edx, 7
    call aead_update_aad
    test al, al
    jz fail
    lea rdi, [rip + ctx]
    lea rsi, [rip + plaintext]
    lea rdx, [rip + ciphertext_out]
    mov ecx, 63
    call aead_seal
    test al, al
    jz fail
    lea rdi, [rip + ctx]
    lea rsi, [rip + plaintext + 63]
    lea rdx, [rip + ciphertext_out + 63]
    mov ecx, 51
    call aead_seal
    test al, al
    jz fail
    CHECK ciphertext_out, ciphertext, 114
    lea rdi, [rip + ctx]
    lea rsi, [rip + tag_out]
    call aead_final
    test al, al
    jz fail
    CHECK tag_out, tag, 16
    lea rdi, [rip + ctx]
    lea rsi, [rip + tag_out]
    call aead_final
    test al, al
    jz fail
    CHECK tag_out, tag, 16

    # Empty AAD and plaintext are valid and deterministic.
    INIT
    lea rdi, [rip + ctx]
    xor esi, esi
    xor edx, edx
    call aead_update_aad
    test al, al
    jz fail
    lea rdi, [rip + ctx]
    lea rsi, [rip + plaintext]
    lea rdx, [rip + ciphertext_out]
    xor ecx, ecx
    call aead_seal
    test al, al
    jz fail
    lea rdi, [rip + ctx]
    lea rsi, [rip + tag_out]
    call aead_final
    test al, al
    jz fail
    lea rdi, [rip + ctx]
    lea rsi, [rip + tag_out]
    call aead_verify
    cmp eax, 1
    jne fail

    INIT
    lea rdi, [rip + ctx]
    lea rsi, [rip + aad]
    mov edx, 12
    call aead_update_aad
    test al, al
    jz fail
    lea rdi, [rip + ctx]
    lea rsi, [rip + ciphertext]
    lea rdx, [rip + plaintext_out]
    mov ecx, 114
    call aead_open
    test al, al
    jz fail
    CHECK plaintext_out, plaintext, 114
    lea rdi, [rip + ctx]
    lea rsi, [rip + tag]
    call aead_verify
    cmp eax, 1
    jne fail
    lea rdi, [rip + ctx]
    lea rsi, [rip + bad_tag]
    call aead_verify
    test eax, eax
    jnz fail

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

.section .rodata
key:
    .byte 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87
    .byte 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f
    .byte 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97
    .byte 0x98, 0x99, 0x9a, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f
nonce:
    .byte 0x07, 0x00, 0x00, 0x00, 0x40, 0x41, 0x42, 0x43
    .byte 0x44, 0x45, 0x46, 0x47
aad:
    .byte 0x50, 0x51, 0x52, 0x53, 0xc0, 0xc1, 0xc2, 0xc3
    .byte 0xc4, 0xc5, 0xc6, 0xc7
plaintext:
    .ascii "Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it."
ciphertext:
    .byte 0xd3, 0x1a, 0x8d, 0x34, 0x64, 0x8e, 0x60, 0xdb
    .byte 0x7b, 0x86, 0xaf, 0xbc, 0x53, 0xef, 0x7e, 0xc2
    .byte 0xa4, 0xad, 0xed, 0x51, 0x29, 0x6e, 0x08, 0xfe
    .byte 0xa9, 0xe2, 0xb5, 0xa7, 0x36, 0xee, 0x62, 0xd6
    .byte 0x3d, 0xbe, 0xa4, 0x5e, 0x8c, 0xa9, 0x67, 0x12
    .byte 0x82, 0xfa, 0xfb, 0x69, 0xda, 0x92, 0x72, 0x8b
    .byte 0x1a, 0x71, 0xde, 0x0a, 0x9e, 0x06, 0x0b, 0x29
    .byte 0x05, 0xd6, 0xa5, 0xb6, 0x7e, 0xcd, 0x3b, 0x36
    .byte 0x92, 0xdd, 0xbd, 0x7f, 0x2d, 0x77, 0x8b, 0x8c
    .byte 0x98, 0x03, 0xae, 0xe3, 0x28, 0x09, 0x1b, 0x58
    .byte 0xfa, 0xb3, 0x24, 0xe4, 0xfa, 0xd6, 0x75, 0x94
    .byte 0x55, 0x85, 0x80, 0x8b, 0x48, 0x31, 0xd7, 0xbc
    .byte 0x3f, 0xf4, 0xde, 0xf0, 0x8e, 0x4b, 0x7a, 0x9d
    .byte 0xe5, 0x76, 0xd2, 0x65, 0x86, 0xce, 0xc6, 0x4b
    .byte 0x61, 0x16
tag:
    .byte 0x1a, 0xe1, 0x0b, 0x59, 0x4f, 0x09, 0xe2, 0x6a
    .byte 0x7e, 0x90, 0x2e, 0xcb, 0xd0, 0x60, 0x06, 0x91
bad_tag:
    .byte 0x1a, 0xe1, 0x0b, 0x59, 0x4f, 0x09, 0xe2, 0x6a
    .byte 0x7e, 0x90, 0x2e, 0xcb, 0xd0, 0x60, 0x06, 0x90

.section .bss
.p2align 4
ctx:
    .zero 408
ciphertext_out:
    .zero 114
plaintext_out:
    .zero 114
tag_out:
    .zero 16
