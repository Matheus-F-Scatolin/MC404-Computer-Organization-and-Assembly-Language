.section .text

.align 2
.globl my_function
my_function:
    # a0: 1st parm
    # a1: 2nd param
    # a2: 3rd param
    addi sp, sp, -16
    sw a0, 12(sp)
    sw a1, 8(sp)
    sw a2, 4(sp)
    sw ra, 0(sp)

    # SUM 1 -> t0
    add a0, a0, a1 # a1 = a0 + a1
    mv t0, a0 # t0 = SUM 1

    # CALL 1
    lw a1, 12(sp)
    jal mystery_function
    lw ra, 0(sp)

    # DIFF 1: 2nd value - ret(mys_func) -> t1
    lw a1, 8(sp)  #2nd value
    # a1 - ret
    sub t1, a1, a0

    # SUM 2 -> t2
    lw a1, 4(sp)
    add t2, t1, a1

    # CALL 2: \SUM2, 2nd
    mv a0, t2
    lw a1, 8(sp)
    addi sp, sp, -16
    sw t0, 12(sp)
    sw t1, 8(sp)
    sw t2, 4(sp)
    jal mystery_function
    lw t0, 12(sp)
    lw t1, 8(sp)
    lw t2, 4(sp)
    addi sp, sp, 16
    lw ra, 0(sp)

    # DIFF 2 -> t3: 3rd - ret(mys_func)
    lw a3, 4(sp)
    sub t3, a3, a0

    # SUM 3:  t3 + t2 -> t4
    add t4, t3, t2

    mv a0, t4

    lw ra, 0(sp)
    addi sp, sp, 16
    ret
