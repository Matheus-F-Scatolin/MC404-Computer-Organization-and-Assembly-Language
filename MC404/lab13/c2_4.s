.text

.align 2
.globl node_op
node_op:
    # a0 = *node
    # t0 = node->a
    lw t0, 0(a0)
    lb t1, 4(a0)
    lb t2, 5(a0)
    lh t3, 6(a0)

    mv a0, t0
    add a0, a0, t1
    sub a0, a0, t2
    add a0, a0, t3

    ret
