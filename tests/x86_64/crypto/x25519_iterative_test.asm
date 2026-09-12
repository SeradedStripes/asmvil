.intel_syntax noprefix
.include "common.inc"

.global _start
.section .text
_start:
    lea rdi, [rip + out]
    lea rsi, [rip + value]
    lea rdx, [rip + value]
    call x25519
    lea rdi, [rip + out]
    lea rsi, [rip + expected]
    mov ecx, 32
.Lcheck:
    mov al, BYTE PTR [rdi]
    cmp al, BYTE PTR [rsi]
    jne .Lfail
    inc rdi
    inc rsi
    dec ecx
    jnz .Lcheck
    mov eax, SYS_EXIT
    xor edi, edi
    syscall
.Lfail:
    mov eax, SYS_EXIT
    mov edi, 1
    syscall

.section .rodata
value: .byte 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
expected: .byte 0x42,0x2c,0x8e,0x7a,0x62,0x27,0xd7,0xbc,0xa1,0x35,0x0b,0x3e,0x2b,0xb7,0x27,0x9f,0x78,0x97,0xb8,0x7b,0xb6,0x85,0x4b,0x78,0x3c,0x60,0xe8,0x03,0x11,0xae,0x30,0x79
.section .bss
out: .zero 32
