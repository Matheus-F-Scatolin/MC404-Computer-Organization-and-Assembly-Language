.text

.align 2
.globl fill_array_int
fill_array_int:
    addi sp, sp, -404
    sw ra, 400(sp)
    # 0(sp) = 0
    # 4(sp) = 1
    # ...
    # 392(sp) = 98
    # 396(sp) = 99
    mv t0, sp  # t0 is the position counter
    li t1, 0  # t1 is the counter (0 to 99)
    li t2, 100
    while:
        sw t1, 0(t0)

        addi t0, t0, 4
        addi t1, t1, 1
        blt t1, t2, while # if t0 < 100, j to while
    
    mv a0, sp
    jal mystery_function_int

    lw ra, 400(sp)
    addi sp, sp, 404
    ret

.align 2
.globl fill_array_short
fill_array_short:
    addi sp, sp, -204
    sw ra, 200(sp)
    mv t0, sp  # t0 is the position counter
    li t1, 0  # t1 is the counter (0 to 99)
    li t2, 100
    while1:
        sh t1, 0(t0)

        addi t0, t0, 2
        addi t1, t1, 1
        blt t1, t2, while1 # if t0 < 100, j to while
    
    mv a0, sp
    jal mystery_function_short

    lw ra, 200(sp)
    addi sp, sp, 204
    ret


.align 2
.globl fill_array_char
fill_array_char:
    addi sp, sp, -104
    sw ra, 100(sp)
    mv t0, sp  # t0 is the position counter
    li t1, 0  # t1 is the counter (0 to 99)
    li t2, 100
    while2:
        sb t1, 0(t0)

        addi t0, t0, 1
        addi t1, t1, 1
        blt t1, t2, while2 # if t0 < 100, j to while
    
    mv a0, sp
    jal mystery_function_char

    lw ra, 100(sp)
    addi sp, sp, 104
    ret