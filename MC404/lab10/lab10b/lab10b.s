/*
typedef struct Node {
    int val;
    struct Node *left, *right;
} Node;

int recursive_tree_search(Node *root_node, int val);
void puts ( const char *str );
char *gets ( char *str );
int atoi (const char *str);
char *itoa ( int value, char *str, int base );
void exit(int code);
*/
.bss
output_address: .skip 100  # buffer
number_buffer: .skip 16
.text

# Receives the size of the buffer in a2 and the buffer address in a1
write:
    li a0, 1            # file descriptor = 1 (stdout)
    li a7, 64           # syscall write (64)
    ecall
    ret

// The following code is the implementation of the recursive_tree_search function
.globl recursive_tree_search
/*
Searches for a value in a binary tree using a recursive approach.
Returns the depth of the node containing the value if found, 0 otherwise.
*/
recursive_tree_search:
    # a0: address of the root node
    # a1: value to search
    # t0: current node address
    # t1: value of the current node
    # t2: left child node address
    # t3: right child node address

    # If the current node is NULL, return 0
    beqz a0, end_search # if a0 == 0, return 0

    mv t0, a0 # t0 = a0 (current node address)
    # Load the value of the current node
    lw t1, 0(t0) # t1 = Node->val
    # If the value is found, return 1
    beq t1, a1, found_value # if t1 == a1, return 1

    j value_not_in_current_node
    found_value:
    li a0, 1 # return 1
    j end_search

    value_not_in_current_node:
    # save return address
    addi sp, sp, -16
    sw ra, 12(sp)
    sw a0, 0(sp) # save the current node address
    # Recursively search the left child
    lw t2, 4(t0) # t2 = Node->left
    mv a0, t2 # a0 = t2
    # a1 = value to search
    jal ra, recursive_tree_search

    # If the value is found in the left child, return 1 + depth
    beqz a0, search_right_child # if a0 == 0, search the right child
    lw ra, 12(sp)
    addi sp, sp, 16
    addi a0, a0, 1 # return 1 + depth
    j end_search

    search_right_child:
    # Recursively search the right child
    lw t0, 0(sp) # t0 = current node address
    lw t3, 8(t0) # t3 = Node->right
    mv a0, t3 # a0 = t3
    # a1 = value to search
    jal ra, recursive_tree_search

    # If the value is found in the right child, return 1 + depth
    beqz a0, not_found # if a0 == 0, return 0

    # If the value is found in the right child, return 1 + depth
    addi a0, a0, 1 # return 1 + depth
    lw ra, 12(sp)
    addi sp, sp, 16
    j end_search


    not_found:
    # The value was not found in the current node or its children
    li a0, 0
    lw ra, 12(sp)
    addi sp, sp, 16
    j end_search

    end_search:
    ret

// The following code is the implementation of the puts function
.globl puts
/*
Writes the C string pointed by a0 to the standard output (stdout) and appends a newline character ('\n').
*/
puts:
    # a0: address of the string
    # t0: character
    # t1: index of the character
    # t2: address of the character
    # t3: output_buffer
    # t4: current position of the buffer
    li t1, 0
    la t3, output_address
    addi sp, sp, -16
    sw ra, 12(sp)
    loop:
        add t2, a0, t1 # t2 = str + t1
        lb t0, 0(t2) # t0 = str[t1]
        beqz t0, end1 # if t0 == 0, end1
        add t4, t1, t3 # t4 = t1 + t3
        sb t0, 0(t4) # output_buffer[t1] = t0
        addi t1, t1, 1 # t1 = t1 + 1
        j loop # repeat
    end1:
    # t1 contains the index of the last character (ex: "hi!\0" -> 3)
    # Write the string to the output
    # addi t4, t1, 1 # t4 = t1 + 1
    mv t4, t1
    li t5, '\n'
    add t4, t4, t3 # t4 = t4 + t3
    sb t5, 0(t4) # output_buffer[t4] = '\n'

    mv a1, t3 # address of the buffer
    addi a2, t1, 1 # size of the buffer
    jal ra, write
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

// The following code is the implementation of the gets function
.globl gets
/* Reads characters from the standard input (stdin) and stores them as a C string 
into str until a newline character or the end-of-file is reached.
The newline character, if found, is not copied into str.
A terminating null character is automatically appended after the characters copied to str.*/
gets:
    # a0: address of the beggining of the buffer
    # t0: current character
    # t1: index of the character
    # t2: address of the beginning of the buffer
    # t3: address of the current character of the buffer
    test_gets:

    mv t2, a0
    mv t3, a0
    li t1, 0 # index of the character
    loopx:
        li a0, 0 # file descriptor = 0 (stdin)
        mv a1, t3 # address of the current character
        li a2, 1 # size of the buffer
        li a7, 63 # syscall read (63)
        ecall
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
    sb zero, 0(t3) # buffer[t1] = 0

    mv a0, t2 # a0 = address of the buffer
    test_gets_end:
    ret
//

// The following code is the implementation of the atoi function
.globl atoi
/*
Parses the C-string str interpreting its content as an integral number, which
is returned as a value of type int.
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
    li t6, 0
    lb t1, 1(a0)
    beq t1, t6, end # if the string has only one character, return
    li t2, 10 # t2 = 10
    mul t0, t0, t2 # t0 = t0*10

    lb t1, 1(a0) # read the second character
    addi t1, t1, -48 # convert to decimal
    add t0, t0, t1  # t0 = t0+t1
    li t6, 0
    lb t1, 2(a0)
    beq t1, t6, end # if the string has only two characters, return
    mul t0, t0, t2 # t0 = t0*10

    # read the third character
    lb t1, 2(a0)
    addi t1, t1, -48
    add t0, t0, t1
    li t6, 0
    lb t1, 3(a0)
    beq t1, t6, end
    mul t0, t0, t2

    # read the fourth character
    lb t1, 3(a0)
    addi t1, t1, -48
    add t0, t0, t1
    li t6, 0
    lb t1, 4(a0)
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

//

// The following code is the implementation of the itoa function
.globl itoa
/*
Converts an integer value to a null-terminated string using the specified base 
and stores the result in the array given by str parameter.
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
        sb zero, 0(a1)   # Add null terminator to the end of the string

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
//

// The following code is the implementation of the exit function
.globl exit
exit:
    # a0 = code
    li a7, 93 # syscall exit (93)
    ecall