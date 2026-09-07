.include "common.inc"

.global sys_exit

.section .text
sys_exit:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
