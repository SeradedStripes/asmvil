.include "common.inc"

.global _start

.section .text
_start:
    call main
    call sys_exit

# Cross-platform application entry point.
main:
    ret
