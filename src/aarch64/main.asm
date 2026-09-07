.include "common.inc"

.global _start

.section .text
_start:
    mov x0, #0
    mov x8, #SYS_EXIT
    svc #0
