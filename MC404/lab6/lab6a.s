.bss
input_address: .skip 20  # buffer

.text
.globl _start


read:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_address #  buffer to write the data
    li a2, 20  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall
    ret


write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, input_address       # buffer
    li a2, 20           # size
    li a7, 64           # syscall write (64)
    ecall
    ret

string_to_decimal:
    # a0 = address of the string
    # t0 = result
    # t1 = current character (converted to decimal)
    lb t1, 0(a0)
    addi t1, t1, -48
    # Now, t1 already contains the decimal value of the first character
    
    li t0, 0
    add t0, t0, t1 # t0 = t1
    # a0 = a0*10
    li t2, 10 # t1 = 10
    mul t0, t0, t2 # a0 = a0*10

    lb t1, 1(a0) # read the second character
    addi t1, t1, -48 # convert to decimal
    add t0, t0, t1  # t0 = t0+t1
    mul t0, t0, t2 # t0 = t0*10

    # read the third character
    lb t1, 2(a0)
    addi t1, t1, -48
    add t0, t0, t1
    mul t0, t0, t2

    # read the fourth character
    lb t1, 3(a0)
    addi t1, t1, -48
    add t0, t0, t1

    # Now, t0 contains the decimal value of the string
    ret


# Calculates the sqrt and returns at t0
calculate_sqrt:
    #t0 = number (y) and final result
    #t1 = 10
    #t2 = counter
    #t3 = 2
    #t4 = k
    #t5 = y/k
    #t6 = k + y/k
    li t1, 10
    li t2, 0
    li t3, 2
    div t4, t0, t3 # t4 = t0/t3 (k = y/2)
    # k' = (k + (y/k)) / 2 --> iterate 10 times
    loop:
        div t5, t0, t4 # t5 = y/k
        add t6, t4, t5 # t6 = k + y/k
        div t4, t6, t3 # t4 = (k + y/k) / 2
        addi t2, t2, 1
        bne t2, t1, loop # If t2 != 10, repeat the loop
    # Now, t4 contains the sqrt of t0
    mv t0, t4

    ret

overwrite_sqrt:
    # a0 = original address of the string
    # a1 = address of the current byte
    # t0 = sqrt of the input
    # t1 = current digit
    # t2 = 10
    li t2, 10
    mv a1, a0
    addi a1, a1, 3 # a1 = address of the last digit
    rem t1, t0, t2 # t1 = t0 % 10
    div t0, t0, t2 # t0 = t0 / 10
    addi t1, t1, 48 # convert to ASCII
    sb t1, 0(a1) # overwrite the last digit
    addi a1, a1, -1

    rem t1, t0, t2 # t1 = t0 % 10
    div t0, t0, t2 # t0 = t0 / 10
    addi t1, t1, 48 # convert to ASCII
    sb t1, 0(a1) # overwrite the third digit
    addi a1, a1, -1

    rem t1, t0, t2 # t1 = t0 % 10
    div t0, t0, t2 # t0 = t0 / 10
    addi t1, t1, 48 # convert to ASCII
    sb t1, 0(a1) # overwrite the second digit
    addi a1, a1, -1

    rem t1, t0, t2 # t1 = t0 % 10
    addi t1, t1, 48 # convert to ASCII
    sb t1, 0(a1) # overwrite the first digit

    ret


_start:
    jal ra, read
    la a0, input_address

    jal ra, string_to_decimal
    jal ra, calculate_sqrt
    # Now, t0 contains the sqrt of the input
    jal ra, overwrite_sqrt

    addi a0, a0, 5
    jal ra, string_to_decimal
    jal ra, calculate_sqrt
    jal ra, overwrite_sqrt

    addi a0, a0, 5
    jal ra, string_to_decimal
    jal ra, calculate_sqrt
    jal ra, overwrite_sqrt

    addi a0, a0, 5
    jal ra, string_to_decimal
    jal ra, calculate_sqrt
    jal ra, overwrite_sqrt


    jal ra, write
    li a0, 0
    li a7, 93
    ecall