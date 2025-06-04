.text

.align 2
.globl swap_int
swap_int:
    # 0(a0) = int *a
    # 0(a1) = int *b
    lw t0, 0(a0)  # t0 = a
    lw t1, 0(a1)  # t1 = b
    sw t0, 0(a1)
    sw t1, 0(a0)

    li a0, 0
    ret


.align 2
.globl swap_short
swap_short:
    # 0(a0) = int *a
    # 0(a1) = int *b
    lh t0, 0(a0)  # t0 = a
    lh t1, 0(a1)  # t1 = b
    sh t0, 0(a1)
    sh t1, 0(a0)

    li a0, 0
    ret


.align 2
.globl swap_char
swap_char:
    # 0(a0) = int *a
    # 0(a1) = int *b
    lb t0, 0(a0)  # t0 = a
    lb t1, 0(a1)  # t1 = b
    sb t0, 0(a1)
    sb t1, 0(a0)

    li a0, 0
    ret