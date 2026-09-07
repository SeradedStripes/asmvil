.include "common.inc"

.global _start

.section .text
_start:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
