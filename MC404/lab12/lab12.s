.data
str: .asciz "4\n"
operators: .asciz "244 + 67\n"
.bss
input: .skip 100  # buffer
reverse_buffer: .skip 100
number_buffer: .skip 16
.text



/*
Parses the C-string str interpreting its content as an integral number, which
is returned as a value of type int.
The function first discards as many whitespace characters (as in isspace) as
necessary until the first non-whitespace character is found. Then, starting
from this character, takes an optional initial plus or minus sign followed
by as many base-10 digits as possible, and interprets them as a numerical value.
The string can contain additional characters after those that form the integral
number, which are ignored and have no effect on the behavior of this function.
*/
atoi:
    # a0 = beginning of the string buffer (terminated by '\0')
    # t0 = result
    # t1 = current character (converted to decimal)
    # t3 = is_negative


    # Ignore "0"s and "+" sign
    loop1:
        lb t1, 0(a0)
        li t6, '0'
        beq t1, t6, is_zero # if the first character is '0', ignore it
        j test_plus

        is_zero:
        addi a0, a0, 1
        j loop1

        test_plus:
        li t6, '+'
        beq t1, t6, is_plus # if the first character is '+', ignore it
        j end_loop11

        is_plus:
        addi a0, a0, 1
        j loop1

    end_loop11: 

    # .if the current character is 0, return 0
    li t6, 0
    beq t1, t6, is_abs_zero # if the first character is '0', return 0
    j is_not_abs_zero
    is_abs_zero:
    li a0, 0
    ret

    is_not_abs_zero:
    # Discover if the number is negative
    li t2, 0
    lb t1, 0(a0)
    li t3, 0
    li t6, '-'
    beq t1, t6, num_is_negative # if the first character is '-', the number is negative

    j num_is_positive
    num_is_negative:
    addi a0, a0, 1
    li t3, 1

    num_is_positive:
    lb t1, 0(a0)
    addi t1, t1, -48
    # Now, t1 already contains the decimal value of the first character
    
    li t0, 0
    add t0, t0, t1 # t0 = t1
    li t6, '\n'
    lb t1, 1(a0)
    beq t1, t6, end # if the string has only one character, return
    li t6, ' '
    beq t1, t6, end # if the string has only one character, return
    li t2, 10 # t2 = 10
    mul t0, t0, t2 # t0 = t0*10

    lb t1, 1(a0) # read the second character
    addi t1, t1, -48 # convert to decimal
    add t0, t0, t1  # t0 = t0+t1
    li t6, '\n'
    lb t1, 2(a0)
    beq t1, t6, end # if the string has only two characters, return
    li t6, ' '
    beq t1, t6, end # if the string has only two characters, return
    mul t0, t0, t2 # t0 = t0*10

    # read the third character
    lb t1, 2(a0)
    addi t1, t1, -48
    add t0, t0, t1
    li t6, '\n'
    lb t1, 3(a0)
    beq t1, t6, end
    li t6, ' '
    beq t1, t6, end
    mul t0, t0, t2

    # read the fourth character
    lb t1, 3(a0)
    addi t1, t1, -48
    add t0, t0, t1
    li t6, '\n'
    lb t1, 4(a0)
    beq t1, t6, end
    li t6, ' '
    beq t1, t6, end
    mul t0, t0, t2

    # read the fifth character
    lb t1, 4(a0)
    addi t1, t1, -48
    add t0, t0, t1

    end:
    li t6, 0
    beq t3, t6, end_2 # if the number is positive, return
    neg t0, t0 # if the number is negative, negate it

    end_2:
    # Now, t0 contains the decimal value of the string

    mv a0, t0
    test_atoi:
    ret


/*
Converts an integer value to a null-terminated string using the specified base 
and stores the result in the array given by str parameter.

If base is 10 and value is negative, the resulting string is preceded with a 
minus sign (-). With any other base, value is always considered unsigned.

str should be an array long enough to contain any possible value: 
(sizeof(int)*8+1) for radix=2, i.e. 17 bytes in 16-bits platforms and 33 in 32-bits 
platforms.
*/
itoa:
    test_itoa:
    # a0 = value to be converted to a string
    # a1 = address of the buffer where the null-terminated string will be stored
    # a2 = numerical base (10 or 16)

    addi sp, sp, -16   # Create space on the stack for temporary variables
    sw ra, 12(sp)    # Save return address
    sw s0, 8(sp) # Save s0 (we'll use it for base)
    sw a0, 4(sp)     # Save the original value of a0 (value to be converted)

    mv s0, a2   # Move base into s0
    li t0, 0   # t0 will store the sign (0 = positive)
    li t1, 10   # Load base 10 for comparison
    bne s0, t1, convert  # If base is not 10, skip the negative check

    bltz a0, handle_negative  # If a0 is negative, handle the negative case
    j convert   # Otherwise, continue to convert

    handle_negative:
        li t0, 1    # Set the sign flag to 1 (indicates negative)
        neg a0, a0  # Negate the value to make it positive

    convert:
        addi a1, a1, 8  # Move buffer pointer to the end of the string (prepare for null-termination)
        li t4, '\n' # Load the newline character
        sb t4, 0(a1)   # Add newline to the end of the string

    convert_loop:
        remu t2, a0, s0 # Get remainder (digit) a0 % base
        bne s0, t1, digit_base_10  # If base is 10, handle digits 0-9
        addi t2, t2, '0' # Convert remainder to ASCII for 0-9
        j store_digit

    digit_base_10:
        li t3, 10 # Load 10 for comparison
        blt t2, t3, digit_0_9 # If digit is 0-9, convert it to ASCII
        addi t2, t2, 'A'-10 # Convert remainder to ASCII for A-F (base 16)
        j store_digit

    digit_0_9:
        addi t2, t2, '0' # Convert digit to ASCII

    store_digit:
        addi a1, a1, -1 # Move buffer pointer to store next digit
        sb t2, 0(a1) # Store the ASCII character in the buffer
        divu a0, a0, s0 # Divide value by the base
        bnez a0, convert_loop # If a0 is not zero, continue converting

        beqz t0, done # If the number was positive, skip adding the minus sign
        addi a1, a1, -1 # Move buffer pointer to add minus sign
        li t2, '-' # Load the minus sign
        sb t2, 0(a1) # Store the minus sign

    done:
        mv      a0, a1                 # Return the address of the resulting string
        lw      ra, 12(sp)             # Restore return address
        lw      s0, 8(sp)              # Restore s0
        addi    sp, sp, 16             # Deallocate stack space
        test_itoa_end:
        ret                             # Return from function




exit:
    # a0 = code
    li a7, 93 # syscall exit (93)
    ecall

# receive the string at a0 and write it 
inverted_puts:
    # a0: address of the buffer to write from
    # t0: current position in the buffer

    addi sp, sp, -16 # create space on the stack for temporary variables
    sw ra, 12(sp) # save return address
    
    # go to the \n character
    mv t0, a0
    inverted_puts_loop:
        lb t1, 0(t0) # t1 = buffer[t0]
        li t6, '\n'
        beq t1, t6, end3 # if t1 == '\n', end3
        addi t0, t0, 1 # t0 = t0 + 1
        j inverted_puts_loop # repeat

    end3:
    # t0 contains the position of the newline character
    # write the string in reverse order
    la t1, reverse_buffer # t1 = address of the reverse buffer
    mv t2, t0 # t2 = t0
    inverted_puts_loop2:
        addi t0, t0, -1 # t0 = t0 - 1
        lb t3, 0(t0) # t3 = buffer[t0]
        sb t3, 0(t1) # write the byte to the reverse buffer

        beq t0, a0, end4 # if t0 == a0, end4 - we have written the whole string
        addi t1, t1, 1 # t1 = t1 + 1
        j inverted_puts_loop2 # repeat

    end4:
    # add a newline character to the reverse buffer
    li t6, '\n'

    sb t6, 1(t1) # write the newline character to the reverse buffer

    # write the reverse buffer
    la a0, reverse_buffer # address of the buffer
    jal ra, puts

    lw ra, 12(sp) # restore return address
    addi sp, sp, 16 # deallocate stack space
    ret


puts:
    # a0: address of the buffer to write from
    # t0: current position in the buffer
    # t1: write trigger position
    # t2: write byte position

    mv t0, a0
    la t1, WRITE_ADDRESS # t1 = address of the write register
    la t2, BYTE_TO_WRITE_ADDRESS # t2 = address of the byte to write register

    loop_write_byte:
        # 1. read the byte from the buffer
        lb t3, 0(t0) # t3 = buffer[t0]
        # 2. write the byte to the write register
        sb t3, 0(t2) # write the byte to the write register
        # 3. trigger the write
        li t4, 1 # t4 = 1 (write trigger)
        sb t4, 0(t1) # trigger the write
        # 4. wait until the write is completed
        write_byte_loop:
            lb t4, 0(t1) # t4 = byte written
            bnez t4, write_byte_loop # wait until write byte is ready (if t4 != 0, the writing hasnt been completed)
        
        # 5. check if the byte is '\n'
        lb t3, 0(t0) # t3 = buffer[t0]
        li t6, '\n'
        beq t3, t6, end1 # if t3 == '\n', end1

        # 6. increment the position in the buffer
        addi t0, t0, 1 # t0 = t0 + 1

        j loop_write_byte # repeat
    

    end1:

    ret
    
gets:
    # a0: address of the beggining of the buffer
    # t0: current character
    # t1: index of the character
    # t3: address of the current character of the buffer
    test_gets:
    mv t3, a0
    li t1, 0 # index of the character

    loopx:
        la t6, READ_ADDRESS # t6 = address of the read register
        la t5, BYTE_READ_ADDRESS # t5 = address of the byte read register
        li t4, 1 # t4 = 1 (read trigger)
        sb t4, 0(t6) # trigger the read
        read_byte_loop:
            # .if the reading is complete, base+0x02 = 0
            lb t4, 0(t6) # t4 = byte read
            bnez t4, read_byte_loop # wait until read byte is ready (if t4 != 0, the reading is not possible)
        
        lb t4, 0(t5) # t4 = byte read
        # write this byte to the buffer
        sb t4, 0(t3) # store the byte in the buffer


        # Now we have the character of index t1 in the buffer

        lb t0, 0(t3) # t0 = buffer[t1]
        li t6, '\n'
        beq t0, t6, end2 # if t0 == '\n', end2
        addi t1, t1, 1 # t1 = t1 + 1
        addi t3, t3, 1 # t3 = t3 + 1
        j loopx # repeat
    end2:
    # t1 contains the index of the last character (ex: "hi!\n" -> 3)
    # replace the newline character with the null character

    test_gets_end:
    ret

# receives at a0 the string that represents an algebraic expression ex: "21 + 13\n" and returns the result ex: "34\n"
parse_and_compute_expression:
    # a0: address of the buffer that contains the expression
    # t0: pointer to the operator
    # t1: pointer to the new line character
    addi sp, sp, -32 # create space on the stack for temporary variables
    sw ra, 28(sp) # save return address
    sw a0, 24(sp) # save a0

    # 1. set t0 to the address of the operator
    mv t0, a0
    li t1, ' '
    loop_space:
        lb t2, 0(t0) # t2 = buffer[t0]
        addi t0, t0, 1 # t0 = t0 + 1
        bne t2, t1, loop_space # if t2 == ' ', loop_space

    # 2. set t1 to the address of the newline character
    li t2, '\n'
    mv t1, t0
    loop_newline:
        lb t3, 0(t1) # t3 = buffer[t1]
        beq t3, t2, end_loop_newline # if t3 == '\n', end_loop_newline
        addi t1, t1, 1 # t1 = t1 + 1
        j loop_newline
    end_loop_newline:

    sw t1, 20(sp) # save the address of the newline character
    sw t0, 16(sp) # save the address of the operator

    # 3. convert the first number to an integer
    jal ra, atoi
    mv t2, a0 # t2 = first number
    sw t2, 12(sp) # save the first number

    bbbbbbbbbbbbbbbbbbbbbbbbbbbb:
    # 4. convert the second number to an integer
    lw t0, 16(sp) # restore 
    mv a0, t0 # a0 = address of the operator
    addi a0, a0, 2 # a0 = a0 + 2
    jal ra, atoi
    mv t3, a0 # t3 = second number

    lw t2, 12(sp) # restore the first number
    lw t0, 16(sp) # restore the address of the operator
    lw t1, 20(sp) # restore the address of the newline character

    # 5. compute the result
    lb t4, 0(t0) # t4 = operator
    li t5, '+' # t5 = '+'
    beq t4, t5, add_numbers # if t4 == '+', add_numbers
    li t5, '-' # t5 = '-'
    beq t4, t5, sub_numbers # if t4 == '-', sub_numbers
    li t5, '*' # t5 = '*'
    beq t4, t5, mul_numbers # if t4 == '*', mul_numbers
    li t5, '/' # t5 = '/'
    beq t4, t5, div_numbers # if t4 == '/', div_numbers

    add_numbers:
    add t2, t2, t3 # t2 = t2 + t3
    j end_parse_and_compute_expression

    sub_numbers:
    sub t2, t2, t3 # t2 = t2 - t3
    j end_parse_and_compute_expression

    mul_numbers:
    mul t2, t2, t3 # t2 = t2 * t3
    j end_parse_and_compute_expression

    div_numbers:
    div t2, t2, t3 # t2 = t2 / t3
    j end_parse_and_compute_expression

    end_parse_and_compute_expression:
    mv a0, t2 # a0 = t2
    lw ra, 28(sp) # restore return address
    addi sp, sp, 32 # deallocate stack space
    ret


/*
base+0x00	byte	Storing “1” triggers the serial port to write (to the stdout) the byte stored at base+0x01. The register is set to 0 when writing is completed.
base+0x01	byte	Byte to be written. ID
base+0x02	byte	Storing “1” triggers the serial port to read (from the stdin) a byte and store it at base+0x03. The register is set to 0 when reading is completed.
base+0x03	byte	Byte read. Null when stdin is empty.*/

.set BASE_ADDRESS, 0xFFFF0100
.set WRITE_ADDRESS, 0xFFFF0100 + 0x00
.set BYTE_TO_WRITE_ADDRESS, 0xFFFF0100 + 0x01
.set READ_ADDRESS, 0xFFFF0100 + 0x02
.set BYTE_READ_ADDRESS, 0xFFFF0100 + 0x03

.globl _start
_start:
    /*
    operations:
    1: read a string and write it back to Serial Port 
    2: read a string and write it back to Serial Port in reverse order
    3: read a number in decimal representation and write it back in hexadecimal representation.
    4: read a string that represents an algebraic expression, compute the expression and write the result to Serial Port. 
    Operator can be + (add) , - (sub), * (mul) or / (div)
    */

    // Read 1 byte from the standard input to find out the operation
    la a0, input # address of the buffer
    jal ra, gets


    teste:
    // Check if the operation is '1' (read a string and write it back to Serial Port)
    li t0, '1'
    la t1, input
    lb t1, 0(t1)
    bne t0, t1, is_not_op_1  # if the operation is not '1', jump to is_not_op_1
    //is_op_1:
        // Read a string from the standard input
        la a0, input # address of the buffer
        jal ra, gets

        // Write the string to the standard output
        la a0, input # address of the buffer
        jal ra, puts
        j end_of_program
    
    is_not_op_1:
    // Check if the operation is '2' (read a string and write it back to Serial Port in reverse order)
    li t0, '2'
    la t1, input
    lb t1, 0(t1)
    bne t0, t1, is_not_op_2  # if the operation is not '2', jump to is_not_op_2
    //is_op_2:
        // Read a string from the standard input
        la a0, input # address of the buffer
        jal ra, gets

        // Write the string to the standard output
        la a0, input # address of the buffer
        jal ra, inverted_puts
        j end_of_program
    
    is_not_op_2:
    // Check if the operation is '3' (read a number in decimal representation and write it back in hexadecimal representation)
    li t0, '3'
    la t1, input
    lb t1, 0(t1)
    bne t0, t1, is_not_op_3  # if the operation is not '3', jump to is_not_op_3
    //is_op_3:
        // Read a number from the standard input
        la a0, input # address of the buffer
        jal ra, gets

        // Convert the number to an integer
        jal ra, atoi

        // Convert the integer to a hexadecimal string
        la a1, number_buffer # address of the buffer
        li a2, 16 # base 16
        jal ra, itoa

        // Write the hexadecimal string to the standard output
        jal ra, puts
        j end_of_program

    is_not_op_3:
    // Check if the operation is '4' (read a string that represents an algebraic expression, compute the expression and write the result to Serial Port. Operator can be + (add) , - (sub), * (mul) or / (div))
    li t0, '4'
    la t1, input
    lb t1, 0(t1)
    bne t0, t1, is_not_op_4  # if the operation is not '4', jump to is_not_op_4
    //is_op_4:
        // Read an algebraic expression from the standard input
        la a0, input # address of the buffer
        jal ra, gets # ex: a0 = "21 + 13\n"

        // Parse the expression and compute the result
        jal ra, parse_and_compute_expression

        aaaaaaaaaaaaaaaaaaaaaaaaaaaaa:

        // Convert the result to a string
        la a1, number_buffer # address of the buffer
        li a2, 10 # base 10
        jal ra, itoa

        // Write the result to the standard output
        jal ra, puts
        j end_of_program


    is_not_op_4:

    end_of_program:
    jal ra, exit