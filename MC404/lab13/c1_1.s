.section .data
.globl my_var
my_var: .word 10

.section .text
.globl increment_my_var

.align 2
increment_my_var:
    lw t0, my_var
    addi t0, t0, 1
    la t1, my_var
    sw t0, (t1)
    ret