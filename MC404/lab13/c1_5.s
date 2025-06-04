.text

.globl operation
operation:
    # a0 = a
    # a1 = b
    # a2 = c
    # a3 = d
    # a4 = e
    # a5 = f
    # a6 = g
    # a7 = h
    # 0(sp) = i
    # 4(sp) = j
    # 8(sp) = k
    # 12(sp) = l
    # 16(sp) = m
    # 20(sp) = n    
    addi sp, sp, -32
    sw ra, 28(sp)
    sw fp, 24(sp)
    addi fp, sp, 32

    
    #switch a and n
    mv t0, a0
    lw t1, 20(fp)
    mv a0, t1
    sw t0, 20(sp)

    #switch b and m
    mv t0, a1
    lw t1, 16(fp)
    mv a1, t1
    sw t0, 16(sp)

    # switch c and l
    mv t0, a2
    lw t1, 12(fp)
    mv a2, t1
    sw t0, 12(sp)

    # switch d and k
    mv t0, a3
    lw t1, 8(fp)
    mv a3, t1
    sw t0, 8(sp)

    # switch e and j
    mv t0, a4
    lw t1, 4(fp)
    mv a4, t1
    sw t0, 4(sp)

    # switch f and i
    mv t0, a5
    lw t1, 0(fp)
    mv a5, t1
    sw t0, 0(sp)

    # switch g and h
    mv t0, a6
    mv a6, a7
    mv a7, t0


    jal mystery_function

    lw ra, 28(sp)
    lw fp, 24(sp)
    addi sp, sp, 32

    ret