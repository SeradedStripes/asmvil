.include "common.inc"

.global _start
.global sys_exit

.section .text
_start:
    bl main
    bl sys_exit

sys_exit:
    mov x8, #SYS_EXIT
    mov x0, #0
    svc #0
