.include "common.inc"

.global _start
.global sys_exit

.section .text
_start:
    call main
    call sys_exit

sys_exit:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
