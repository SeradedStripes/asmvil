.include "common.inc"

.global sys_exit

.section .text
sys_exit:
    mov x8, #SYS_EXIT
    mov x0, #0
    svc #0
