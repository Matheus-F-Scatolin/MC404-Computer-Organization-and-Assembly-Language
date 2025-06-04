.bss
input_address1: .skip 12 # buffer1
input_address2: .skip 20 # buffer2

.text
.globl _start

#read the number of bytes indicated by a2 from the file descriptor indicated by a0 and store them in the buffer pointed by a1
read:
    li a0, 0 # file descriptor = 0 (stdin)
    li a7, 63 # syscall read (63)
    ecall
    ret

# write the number of bytes indicated by a2 from the buffer pointed by a1 to the file descriptor indicated by a0
write:
    li a0, 1 # file descriptor = 1 (stdout)
    li a7, 64 # syscall write (64)
    ecall
    ret

# Converts a string to a decimal number and returns at t0. Parameters: a0 = address of the start of the string. reads 4 bytes
string_to_decimal:
    # a0 = address of the string
    # t0 = result
    # t1 = current character (converted to decimal)
    teste_func:
    li t0, 0
    lb t1, 0(a0)
    addi t1, t1, -48
    # Now, t1 already contains the decimal value of the first character
    
    add t0, t0, t1 # t0 = t1
    # t0 = t0*10
    li t2, 10 # t1 = 10
    mul t0, t0, t2 # t0 = t0*10

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


# Converts a string to a decimal number and returns at t0. Parameters: a0 = address of the start of the string. reads 4 bytes
signed_string_to_decimal:
    # a0 = address of the string
    # t0 = result (will store the final number)
    # t1 = current character (converted to decimal)
    # t2 = is_a_negative_number (0 if false, 1 if true)
    
    lb t1, 0(a0)          # Load the first character (sign)
    li t2, 0              # Default: positive number

    li t3, 43             # ASCII for '+'
    beq t1, t3, skip_sign # If the sign is '+', skip the sign handling

    li t3, 45             # ASCII for '-'
    beq t1, t3, set_negative # If the sign is '-', set t2 to indicate negative

    j start_conversion     # Jump to conversion if no sign (if it's already a number)

    set_negative:
        li t2, 1              # Set t2 to indicate negative
        j skip_sign

    skip_sign:
        addi a0, a0, 1       # Skip the sign (move to the first digit)

    start_conversion:
        li t0, 0          # Initialize t0 to hold the result

        # Read the first digit
        lb t1, 0(a0)        # Load the first digit
        addi t1, t1, -48      # Convert character to decimal
        add t0, t0, t1      # Add to result

        # Continue with the rest of the digits
        li t3, 10          # Multiplier for base 10

        lb t1, 1(a0)        # Read the second character
        addi t1, t1, -48      # Convert to decimal
        mul t0, t0, t3       # Multiply result by 10
        add t0, t0, t1       # Add the second digit

        lb t1, 2(a0)        # Read the third character
        addi t1, t1, -48      # Convert to decimal
        mul t0, t0, t3      # Multiply result by 10
        add t0, t0, t1      # Add the third digit

        lb t1, 3(a0)       # Read the fourth character
        addi t1, t1, -48      # Convert to decimal
        mul t0, t0, t3     # Multiply result by 10
        add t0, t0, t1      # Add the fourth digit

    # Check if the number is negative
    beqz t2, positive_num # If t2 == 0 (positive), skip negation
    neg t0, t0            # Negate the number if it's negative

    positive_num:
    ret                   # Return, with t0 containing the final result



# Calculates the sqrt and returns at t0
calculate_sqrt:
    #t0 = number (y) and final result
    #t1 = 21
    #t2 = counter
    #t3 = 2
    #t4 = k
    #t5 = y/k
    #t6 = k + y/k
    li t1, 21
    li t2, 0
    li t3, 2
    div t4, t0, t3 # t4 = t0/t3 (k = y/2)
    # k' = (k + (y/k)) / 2 --> iterate 21 times
    loop:
    div t5, t0, t4 # t5 = y/k
    add t6, t4, t5 # t6 = k + y/k
    div t4, t6, t3 # t4 = (k + y/k) / 2
    addi t2, t2, 1
    bne t2, t1, loop # If t2 != 21, repeat the loop
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



# Converts 2 signed decimal numbers to a string in the format "-0088 +0016" and returns at a0. Parameters: t0 = decimal number 1, t1 = decimal number 2
decimal_to_string:
    # t0 = decimal number 1
    # t1 = decimal number 2 
    # a0 = address of the start of the string

    la a0, input_address1 # Address of the buffer
    # Convert first number t0 (signed) to string "-0088" part

    li t2, 0 # Reset t2 (temp register) for sign check
    blt t0, t2, neg_num1 # If t0 is negative, jump to neg_num1 label

    # t0 is positive or zero, add '+' sign
    li t2, '+'
    sb t2, 0(a0) # Store '+' sign
    j pos_num1 # Jump to handle positive number

    neg_num1:
    # t0 is negative, add '-' sign
    li t2, '-'
    sb t2, 0(a0) # Store '-' sign
    neg t0, t0 # Negate t0 to make it positive

    pos_num1:
    # Convert t0 (now positive) to 4-digit string
    li t2, 10 # Prepare divisor for extracting digits

    # Store the thousands place
    li t6, 1000 # Prepare divisor for extracting thousands digit
    div t3, t0, t6 # t3 = t0 / 1000 (extract thousands digit)
    addi t3, t3, 48 # Convert to ASCII
    sb t3, 1(a0) # Store digit in string
    rem t0, t0, t6 # t0 = t0 % 1000 (remove thousands digit)

    # Store the hundreds place
    li t6, 100 # Prepare divisor for extracting hundreds digit
    div t3, t0, t6 # t3 = t0 / 100 (extract hundreds digit)
    addi t3, t3, 48 # Convert to ASCII
    sb t3, 2(a0) # Store digit in string
    rem t0, t0, t6 # t0 = t0 % 100 (remove hundreds digit)

    # Store the tens place
    li t6, 10 # Prepare divisor for extracting tens digit
    div t3, t0, t6 # t3 = t0 / 10 (extract tens digit)
    addi t3, t3, 48 # Convert to ASCII
    sb t3, 3(a0) # Store digit in string
    rem t0, t0, t6 # t0 = t0 % 10 (remove tens digit)

    # Store the ones place
    addi t0, t0, 48 # Convert to ASCII
    sb t0, 4(a0) # Store digit in string

    # Add space between the two numbers
    li t2, ' '
    sb t2, 5(a0) # Store space


    # Convert second number t1 (signed) to string "+0016" part

    addi a0, a0, 6 # Move a0 to the next part of the string

    li t2, 0 # Reset t2 (temp register) for sign check
    blt t1, t2, neg_num2 # If t1 is negative, jump to neg_num2 label

    # t1 is positive or zero, add '+' sign
    li t2, '+'
    sb t2, 0(a0) # Store '+' sign
    j pos_num2 # Jump to handle positive number


    neg_num2:
    # t1 is negative, add '-' sign
    li t2, '-'
    sb t2, 0(a0) # Store '-' sign
    neg t1, t1 # Negate t1 to make it positive

    pos_num2:
    # Convert t1 (now positive) to 4-digit string
    li t2, 10 # Prepare divisor for extracting digits

    # Store the thousands place
    li t6, 1000 # Prepare divisor for extracting thousands digit
    div t3, t1, t6 # t3 = t1 / 1000 (extract thousands digit)
    addi t3, t3, 48 # Convert to ASCII
    sb t3, 1(a0) # Store digit in string
    rem t1, t1, t6 # t1 = t1 % 1000 (remove thousands digit)

    # Store the hundreds place
    li t6, 100 # Prepare divisor for extracting hundreds digit
    div t3, t1, t6 # t3 = t1 / 100 (extract hundreds digit)
    addi t3, t3, 48 # Convert to ASCII
    sb t3, 2(a0) # Store digit in string
    rem t1, t1, t6 # t1 = t1 % 100 (remove hundreds digit)

    # Store the tens place
    li t6, 10 # Prepare divisor for extracting tens digit
    div t3, t1, t6 # t3 = t1 / 10 (extract tens digit)
    addi t3, t3, 48 # Convert to ASCII
    sb t3, 3(a0) # Store digit in string
    rem t1, t1, t6 # t1 = t1 % 10 (remove tens digit)

    # Store the ones place
    addi t1, t1, 48 # Convert to ASCII
    sb t1, 4(a0) # Store digit in string

    # Add newline character at the end
    li t2, '\n'
    sb t2, 5(a0) # Store newline character

    ret



_start:
    li a2, 12 # Read 12 bytes and store in the 1st buffer
    la a1, input_address1 # Address of the buffer
    jal ra, read

    li a2, 20 # Read 20 bytes and store in the 2nd buffer
    la a1, input_address2 # Address of the buffer
    jal ra, read
    # Add the '\n' character at the end of the buffer
    li t0, '\n'
    la a1, input_address2
    addi a1, a1, 20
    sb t0, 0(a1)

    # Read the first string "+0700 -0100" (Yb and Xc)
    la a0, input_address1
    jal ra, signed_string_to_decimal
    mv s7, t0 # s7 = Yb

    la a0, input_address1
    addi a0, a0, 6
    jal ra, signed_string_to_decimal
    mv s8, t0 # s8 = Xc

    # Read the second string "2000 0000 2240 2300" (Ta, Tb, Tc and Tr)
    la a0, input_address2
    jal ra, string_to_decimal
    mv s0, t0 # s0 = Ta
    addi a0, a0, 5
    jal ra, string_to_decimal
    mv s1, t0 # s1 = Tb
    
    addi a0, a0, 5
    jal ra, string_to_decimal
    mv s2, t0 # s2 = Tc

    addi a0, a0, 5
    jal ra, string_to_decimal
    mv s3, t0 # s3 = Tr

    # CALCULATE Da (s4), Db (s5) and Dc (s6)
    # Da = (Tr - ta) * 3 / 10
    sub t0, s3, s0 # t0 = Tr - Ta
    li t1, 3
    mul t0, t0, t1 # t0 = (Tr - Ta) * 3
    li t1, 10
    div s4, t0, t1 # s4 = (Tr - Ta) * 3 / 10 = Da

    # Db = (Tr - tb) * 3 / 10
    sub t0, s3, s1 # t0 = Tr - Tb
    li t1, 3
    mul t0, t0, t1 # t0 = (Tr - Tb) * 3
    li t1, 10
    div s5, t0, t1 # s5 = (Tr - Tb) * 3 / 10 = Db

    # Dc = (Tr - tc) * 3 / 10
    sub t0, s3, s2 # t0 = Tr - Tc
    li t1, 3
    mul t0, t0, t1 # t0 = (Tr - Tc) * 3
    li t1, 10
    div s6, t0, t1 # s6 = (Tr - Tc) * 3 / 10 = Dc

    teste_distance:
    # CALCULATE Yc (s9) X AND Y:
    # Y = (Da² + Yb² - Db²) / (2*Yb)
    mul t0, s4, s4 # t0 = Da²
    mul t1, s5, s5 # t1 = Db²
    sub t0, t0, t1 # t0 = Da² - Db²
    mul t1, s7, s7 # t1 = Yb²
    add t0, t0, t1 # t0 = Da² - Db² + Yb²
    li t1, 2
    mul t1, s7, t1 # t1 = 2*Yb
    div s9, t0, t1 # s9 = (Da² + Yb² - Db²) / (2*Yb)

    # X = +- sqrt(Da² - Y²)
    mul t0, s4, s4 # t0 = Da²
    mul t1, s9, s9 # t1 = Y²
    sub t0, t0, t1 # t0 = Da² - Y²
    jal ra, calculate_sqrt # t0 = sqrt(Da² - Y²)
    mv s10, t0 # s10 = sqrt(Da² - Y²)

    teste_inicial2:
    # test if X is positive or negative with this eq: distance = (X - Xc)² + y² - Dc²
    # t5 = positive X distance
    sub t0, s10, s8 # t0 = X - Xc
    mul t0, t0, t0 # t0 = (X - Xc)²
    mul t1, s9, s9 # t1 = Y²
    # até aqui ta ok
    add t0, t0, t1 # t0 = (X - Xc)² + y²
    mul t1, s6, s6 # t1 = Dc²
    sub t0, t0, t1 # t0 = (X - Xc)² + y² - Dc²
    mv t5, t0 # t5 = positive X distance

    # t6 = negative X distance
    neg t2, s10 # t2 = -X
    sub t0, t2, s8 # t0 = -X - Xc
    mul t0, t0, t0 # t0 = (-X - Xc)²
    mul t1, s9, s9 # t1 = Y²
    add t0, t0, t1 # t0 = (-X - Xc)² + y²
    mul t1, s6, s6 # t1 = Dc²
    sub t0, t0, t1 # t0 = (-X - Xc)² + y² - Dc²
    mv t6, t0 # t6 = negative X distance

    # .if mod positive distance is less than mod negative distance, X is positive
    li t0, 0
    blt t0, t5, 1f # if positive distance is less than 0
    neg t5, t5 # t5 is negative (t5 = -X)
    1:
    li t0, 0
    blt t0, t6, 2f # if negative distance is less than 0
    neg t6, t6 # t6 is negative (t6 = -X)
    2:
    # .if positive distance is less than negative distance, X is positive
    blt t5, t6, positive # if positive distance is less than negative distance, X is positive
    neg s10, s10 # X is negative (s10 = -X)
    positive:

    # Write the result in this format: "-0088 +0016" (X and Y)
    mv t0, s10
    mv t1, s9
    teste_y:
    la a0, input_address1
    jal ra, decimal_to_string

    # Write the result
    la a1, input_address1
    li a2, 12
    jal ra, write



    li a0, 0
    li a7, 93
    ecall