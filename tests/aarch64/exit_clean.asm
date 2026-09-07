.include "common.inc"

.global _start

.section .text
_start:
    mov x0, #1
    adr x1, msg
    mov x2, #len
    mov x8, #SYS_WRITE
    svc #0

    mov x0, #0
    mov x8, #SYS_EXIT
    svc #0

.section .data
msg:
    .ascii "asmvil: aarch64 test ok\n"
len = . - msg
