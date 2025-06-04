.bss
input_address1: .skip 5  # buffer
input_address2: .skip 8  # buffer
input_address3: .skip 2  # buffer

.text
.globl _start

# set a2 = number of bytes to be read (5 or 8)
# set a1 = address of the buffer (input_address1 or input_address2)
read:
    li a0, 0  # file descriptor = 0 (stdin)
    li a7, 63 # syscall read (63)
    ecall
    ret

# set a2 = number of bytes to be written (5 or 8 or 2)
# set a1 = address of the buffer (input_address1 or input_address2 or input_address3)
write:
    li a0, 1            # file descriptor = 1 (stdout)
    li a7, 64           # syscall write (64)
    ecall
    ret

# reads a string stored in input_address1 in this format: "0101\n" and stores d1->s2, d2->s4, d3->s5, d4->s6
read_4_bytes:
    la a1, input_address1
    lb t1, 0(a1)
    addi t1, t1, -48
    mv s2, t1

    lb t1, 1(a1)
    addi t1, t1, -48
    mv s4, t1

    lb t1, 2(a1)
    addi t1, t1, -48
    mv s5, t1

    lb t1, 3(a1)
    addi t1, t1, -48
    mv s6, t1
    ret

# Calculates p1, p2 and p3 according to hamming 7 4 code. p1->s0, p2->s1, p3->s3
calculate_ps:
    # p1 = d1 + d2 + d4 (+ means xor)
    xor s0, s2, s4
    xor s0, s0, s6

    # p2 = d1 + d3 + d4
    xor s1, s2, s5
    xor s1, s1, s6

    # p3 = d2 + d3 + d4
    xor s3, s4, s5
    xor s3, s3, s6

    ret

_start:
    la a1, input_address1
    li a2, 5
    jal ra, read
    # Now, the number is stored in input_address1

    jal ra, read_4_bytes
    # Now, the bytes are stored in s2, s4, s5, s6

    jal ra, calculate_ps
    # Now, the parity bits are stored in s0, s1, s3

    # Write the full number in the format: "p1p2d1p3d2d3d4\n" in input_address2
    la a1, input_address2
    mv t0, s0
    addi t0, t0, 48
    sb t0, 0(a1)

    mv t0, s1
    addi t0, t0, 48
    sb t0, 1(a1)

    mv t0, s2
    addi t0, t0, 48
    sb t0, 2(a1)

    mv t0, s3
    addi t0, t0, 48
    sb t0, 3(a1)

    mv t0, s4
    addi t0, t0, 48
    sb t0, 4(a1)

    mv t0, s5
    addi t0, t0, 48
    sb t0, 5(a1)

    mv t0, s6
    addi t0, t0, 48
    sb t0, 6(a1)

    li t0, '\n' # t0 <- '\n'
    sb t0, 7(a1) # '\n' is stored in the last byte

    #write the number stored in input_address2
    la a1, input_address2
    li a2, 8
    jal ra, write

    # Now, we receive a new number in input_address2 in the format "00110011\n"
    # We need to check if there is any error in the received number

    # Read the number
    la a1, input_address2
    li a2, 8
    jal ra, read

    # Now, the number is stored in input_address2. We have to store each byte in s0, s1, ...
    la a1, input_address2
    lb s0, 0(a1)
    lb s1, 1(a1)
    lb s2, 2(a1)
    lb s3, 3(a1)
    lb s4, 4(a1)
    lb s5, 5(a1)
    lb s6, 6(a1)

    # Write d1d2d3d4 in input_address1
    la a1, input_address1
    mv t0, s2
    sb t0, 0(a1)

    mv t0, s4
    sb t0, 1(a1)

    mv t0, s5
    sb t0, 2(a1)

    mv t0, s6
    sb t0, 3(a1)

    li t0, '\n' # t0 <- '\n'
    sb t0, 4(a1) # '\n' is stored in the last byte

    # Write the number stored in input_address1
    la a1, input_address1
    li a2, 5
    jal ra, write


    # Calculate the parity bits
    # .if p1 + d1 + d2 + d4 = 0, there is no error (+ means xor)
    xor t0, s0, s2
    xor t0, t0, s4
    xor t0, t0, s6
    bnez t0, error

    # .if p2 + d1 + d3 + d4 = 0, there is no error
    li t0, 0
    xor t0, s1, s2
    xor t0, t0, s5
    xor t0, t0, s6
    bnez t0, error

    # .if p3 + d2 + d3 + d4 = 0, there is no error
    li t0, 0
    xor t0, s3, s4
    xor t0, t0, s5
    xor t0, t0, s6
    bnez t0, error

    j no_error

    error:
    # Write "1\n" in input_address3
    la a1, input_address3
    li t0, '1'
    sb t0, 0(a1)
    li t0, '\n'
    sb t0, 1(a1)

    la a1, input_address3
    li a2, 2
    jal ra, write

    j exit
    
    no_error:
    # Write "0\n" in input_address3
    la a1, input_address3
    li t0, '0'
    sb t0, 0(a1)
    li t0, '\n'
    sb t0, 1(a1)

    la a1, input_address3
    li a2, 2
    jal ra, write
    
    exit:
    li a0, 0
    li a7, 93
    ecall