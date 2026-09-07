.include "common.inc"

.global _start

.section .text
_start:
    mov rax, SYS_WRITE
    mov rdi, 1
    lea rsi, [rip + msg]
    mov rdx, offset len
    syscall

    mov rax, SYS_EXIT
    mov rdi, 0
    syscall

.section .data
msg:
    .ascii "asmvil: x86-64 test ok\n"
len = . - msg
