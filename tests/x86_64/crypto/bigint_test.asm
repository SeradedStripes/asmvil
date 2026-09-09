.intel_syntax noprefix
.include "common.inc"

# bigint tests, exit 0 on success, 1 on failure.

.global _start

.section .text
_start:
    # bigint_add: a2 + b2
    lea rdi, [rip + out]
    lea rsi, [rip + a2]
    lea rdx, [rip + b2]
    mov rcx, 2
    call bigint_add
    cmp rax, 0
    jne fail
    lea rdi, [rip + out]
    lea rsi, [rip + exp_add]
    mov rdx, 2
    call expect

    # bigint_sub: a1 - b1, no borrow
    lea rdi, [rip + out]
    lea rsi, [rip + a1]
    lea rdx, [rip + b1]
    mov rcx, 2
    call bigint_sub
    cmp rax, 0
    jne fail
    lea rdi, [rip + out]
    lea rsi, [rip + exp_sub]
    mov rdx, 2
    call expect

    # bigint_sub: borrow case (b1 - a1) returns 1
    lea rdi, [rip + out]
    lea rsi, [rip + b1]
    lea rdx, [rip + a1]
    mov rcx, 2
    call bigint_sub
    cmp rax, 1
    jne fail

    # bigint_mul: 2-limb x 2-limb into 4-limb
    lea rdi, [rip + out4]
    lea rsi, [rip + a1]
    lea rdx, [rip + b1]
    mov rcx, 2
    call bigint_mul
    lea rdi, [rip + out4]
    lea rsi, [rip + exp_mul]
    mov rdx, 4
    call expect

    # bigint_sqr
    lea rdi, [rip + out4]
    lea rsi, [rip + a1]
    mov rdx, 2
    call bigint_sqr
    lea rdi, [rip + out4]
    lea rsi, [rip + exp_sqr]
    mov rdx, 4
    call expect

    # bigint_shl then bigint_shr round-trip
    lea rdi, [rip + out]
    lea rsi, [rip + a2]
    mov rdx, 2
    mov rcx, 37
    call bigint_shl
    lea rdi, [rip + out2]
    lea rsi, [rip + out]
    mov rdx, 2
    mov rcx, 37
    call bigint_shr
    lea rdi, [rip + out2]
    lea rsi, [rip + a2]
    mov rdx, 2
    call expect

    # bigint_shr then bigint_shl round-trip
    # a3 has zero low bits, so shr does not lose data
    lea rdi, [rip + out]
    lea rsi, [rip + a3]
    mov rdx, 2
    mov rcx, 37
    call bigint_shr
    lea rdi, [rip + out2]
    lea rsi, [rip + out]
    mov rdx, 2
    mov rcx, 37
    call bigint_shl
    lea rdi, [rip + out2]
    lea rsi, [rip + a3]
    mov rdx, 2
    call expect

    # bigint_cmp equal => 0
    lea rdi, [rip + a1]
    lea rsi, [rip + a1]
    mov rdx, 2
    call bigint_cmp
    test rax, rax
    jnz fail
    # a > b => 1
    lea rdi, [rip + a1]
    lea rsi, [rip + b1]
    mov rdx, 2
    call bigint_cmp
    cmp rax, 1
    jne fail
    # a < b => -1
    lea rdi, [rip + b1]
    lea rsi, [rip + a1]
    mov rdx, 2
    call bigint_cmp
    cmp rax, -1
    jne fail

    # ct_select bit=0 picks a
    lea rdi, [rip + out]
    lea rsi, [rip + a1]
    lea rdx, [rip + b1]
    mov rcx, 2
    mov r8, 0
    call ct_select
    lea rdi, [rip + out]
    lea rsi, [rip + a1]
    mov rdx, 2
    call expect

    # ct_select bit=1 picks b
    lea rdi, [rip + out]
    lea rsi, [rip + a1]
    lea rdx, [rip + b1]
    mov rcx, 2
    mov r8, 1
    call ct_select
    lea rdi, [rip + out]
    lea rsi, [rip + b1]
    mov rdx, 2
    call expect

    # ct_eq: a1 == a1 => 1
    lea rdi, [rip + a1]
    lea rsi, [rip + a1]
    mov rdx, 2
    call ct_eq
    cmp rax, 1
    jne fail
    # ct_eq: a1 != b1 => 0
    lea rdi, [rip + a1]
    lea rsi, [rip + b1]
    mov rdx, 2
    call ct_eq
    test rax, rax
    jnz fail
    # ct_lt: b1 < a1 => 1
    lea rdi, [rip + b1]
    lea rsi, [rip + a1]
    mov rdx, 2
    call ct_lt
    cmp rax, 1
    jne fail
    # ct_lt: a1 < a1 => 0
    lea rdi, [rip + a1]
    lea rsi, [rip + a1]
    mov rdx, 2
    call ct_lt
    test rax, rax
    jnz fail

    # All tests passed
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall

fail:
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

# expect(rdi=got, rsi=want, rdx=limbs) - exit 1 on mismatch
expect:
    push rbx
    push r12
    push r13
    mov r12, rdi
    mov r13, rsi
    mov rbx, rdx
0:
    test rbx, rbx
    jz 1f
    mov rax, [r12]
    mov rcx, [r13]
    cmp rax, rcx
    jne fail
    add r12, 8
    add r13, 8
    sub rbx, 1
    jmp 0b
1:
    pop r13
    pop r12
    pop rbx
    ret

.section .data
a2:
    .quad 0xffffffffffffffff, 0x0000000000000001
b2:
    .quad 0x0000000000000002, 0x0000000000000002
exp_add:
    .quad 0x0000000000000001, 0x0000000000000004

a1:
    .quad 0x000000000000000f, 0x0000000000000010
a3:
    .quad 0x0000000000000000, 0x0000000000000001
b1:
    .quad 0x0000000000000005, 0x0000000000000002
exp_sub:
    .quad 0x000000000000000a, 0x000000000000000e
exp_mul:
    .quad 0x000000000000004b, 0x000000000000006e, 0x0000000000000020, 0x0000000000000000
exp_sqr:
    .quad 0x00000000000000e1, 0x00000000000001e0, 0x0000000000000100, 0x0000000000000000

out:
    .quad 0, 0
out2:
    .quad 0, 0
out4:
    .quad 0, 0, 0, 0
