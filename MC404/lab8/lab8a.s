.data
input_file:    .asciz "image.pgm"    # PGM file path
buffer:        .space 262159            # Buffer for reading the file

.text
.globl _start


_start:
    # Step 1: Open the image file (image.pgm)
    la a0, input_file   # load file path address
    li a1, 0            # flags = 0 (O_RDONLY)
    li a2, 0            # mode = 0 (not needed for read)
    li a7, 1024         # syscall number for open
    ecall
    mv s0, a0           # store the file descriptor in s0

    # Step 2: Read and parse the PGM header
    #"P5\n<width> <height>\n255\n"
    mv a0, s0           # file descriptor
    la a1, buffer       # buffer to store the file content
    li a2, 262159          # number of bytes to read
    li a7, 63           # syscall number for read
    ecall
    
    # Parsing the PGM header (assume "P5\n<width> <height>\n255\n" format)
    # Skipping the "P5\n" part
    la s11, buffer
    addi s11, s11, 3      # skip "P5\n"
    
    # Step 3: Read width
    li t1, 0            # initialize width accumulator
    parse_width:
        lb t2, 0(s11)        # load byte from buffer
        li s10, 32         # ASCII 32 is space
        beq t2, s10, parse_height  # if space (ASCII 32), move to height
        li s10, 48         # ASCII 48 is 0
        sub t2, t2, s10      # convert ASCII to integer
        li s10, 10         # ASCII 10 is newline
        mul t1, t1, s10      # multiply current width by 10
        add t1, t1, t2      # add digit
        addi s11, s11, 1      # move to next byte
        j parse_width    

    parse_height:
    addi s11, s11, 1      # skip the space character
    # Now, s11 points to the first digit of height
    
    # Step 4: Read height
    li t3, 0            # initialize height accumulator
    parse_height_loop:
        lb t2, 0(s11)        # load byte from buffer
        li s10, 10         # ASCII 10 is newline
        beq t2, s10, parse_pixels  # if newline (ASCII 10), move to pixel data
        li s10, 48         # ASCII 48 is 0
        sub t2, t2, s10      # convert ASCII to integer
        li s10, 10         # ASCII 10 is newline
        mul t3, t3, s10      # multiply current height by 10
        add t3, t3, t2      # add digit
        addi s11, s11, 1      # move to next byte
        j parse_height_loop

    # Now, s11 points to the first pixel value

    parse_pixels:
    addi s11, s11, 5      # skip the "\n255\n" part (since Maxval is always 255)
    # Now, s11 points to the first pixel value

    # Store width and height in a0 and a1
    mv a0, t1           # width in a0
    mv a1, t3           # height in a1

    # Step 5: Set canvas size
    li a7, 2201         # syscall number for setCanvasSize
    ecall

    # Step 6: Read pixel data and display on canvas
    mv s4, a0           # store width in s4
    mv s5, a1           # store height in s5

    # Prepare to read pixels from the buffer
    mv s6, s11      # s6 points to the beginning of pixel data

    # Draw pixels on canvas
    li s7, 0            # y-coordinate (row)

    draw_rows:
    li s8, 0            # x-coordinate (column)
    draw_columns:
    lbu s9, 0(s6)        # load one byte (grayscale value)
    
    # Set RGB color: R = G = B = pixel value, Alpha = 255
    li s2, 0xFF        # initialize color to 0xFF (Alpha channel)
    slli s9, s9, 8      # shift grayscale value to the left by 8 bits
    or s2, s2, s9       # set blue channel

    slli s9, s9, 8      # shift grayscale value to the left by 8 bits
    or s2, s2, s9       # set green channel

    slli s9, s9, 8      # shift grayscale value to the left by 8 bits
    or s2, s2, s9       # set red channel
    
    # Draw pixel on canvas
    mv a0, s8           # set x-coordinate in a0
    mv a1, s7           # set y-coordinate in a1
    mv a2, s2           # set color in a2
    li a7, 2200         # syscall number for setPixel
    ecall
    
    # Move to the next pixel
    addi s6, s6, 1      # increment buffer pointer (next pixel)
    addi s8, s8, 1      # increment x-coordinate
    blt s8, s4, draw_columns  # if x < width, continue drawing columns

    # Move to the next row
    addi s7, s7, 1      # increment y-coordinate
    blt s7, s5, draw_rows    # if y < height, continue drawing rows

    # Step 7: Close the file
    mv a0, s0           # file descriptor in a0
    li a7, 57           # syscall number for close
    ecall

    # End program
    li a7, 93           # syscall number for exit
    ecall