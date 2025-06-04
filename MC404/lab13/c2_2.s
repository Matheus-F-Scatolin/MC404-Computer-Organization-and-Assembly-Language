.text

.align 2
.globl middle_value_int
middle_value_int:
    # a0 = *array
    # a1 = int n
    li t0, 2
    div a1, a1, t0
    li t0, 4
    mul a1, a1, t0
    add a0, a0, a1 # correct position
    lw a0, 0(a0)
    ret

.align 2
.globl middle_value_short
middle_value_short:
    # a0 = *array
    # a1 = int n
    li t0, 2
    div a1, a1, t0
    li t0, 2
    mul a1, a1, t0
    add a0, a0, a1 # correct position
    lw a0, 0(a0)
    ret

.align 2
.globl middle_value_char
middle_value_char:
    # a0 = *array
    # a1 = int n
    li t0, 2
    div a1, a1, t0
    li t0, 2
    add a0, a0, a1 # correct position
    lw a0, 0(a0)
    ret

.align 2
.globl value_matrix
value_matrix:
    # a0 = int matrix[12][42]
    # a1 = int r
    # a2 = int c
    # pos = r*42 + c
    li t0, 42
    mul a1, a1, t0
    add a1, a1, a2
    li t0, 4
    mul a1, a1, t0
    add a0, a0, a1
    lw a0, 0(a0)

    ret