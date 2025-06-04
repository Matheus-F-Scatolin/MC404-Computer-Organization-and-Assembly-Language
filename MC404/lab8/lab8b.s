.data
input_file:    .asciz "image.pgm"    # PGM file path
buffer:        .space 262159            # Buffer for reading the file

.text
.globl _start

# Apply the following filter:
# -1 -1 -1
# -1  8 -1
# -1 -1 -1
# Return the result in s1
apply_filter:
    # s8 = x-coordinate
    # s7 = y-coordinate
    # s4 = width
    # s5 = height
    # s6 = buffer pointer (to the current position)
    # s3 = buffer pointer (to the beginning of pixel data)
    # s1 = filter result accumulator
    # t3 = temporary register always used to store 1

    # If the pixel is on the border, return 0
    li s1, 0            # initialize filter result accumulator

    li t0, 0            # initialize x = 0
    beq s8, t0, end_apply_filter  # if x = 0, return 0
    li t3, 1            # initialize 1
    sub t0, s4, t3       # width - 1
    beq s8, t0, end_apply_filter  # if x = width - 1, return 0

    li t0, 0            # initialize y = 0
    beq s7, t0, end_apply_filter  # if y = 0, return 0
    li t3, 1            # initialize 1
    sub t0, s5, t3        # height - 1
    beq s7, t0, end_apply_filter  # if y = height - 1, return 0

    # Apply the filter:
    # upper-left pixel: position = (y-1)*width + (x-1)
    sub t0, s7, t3        # t0 = y - 1
    mul t1, t0, s4       # t1 = (y - 1) * width
    sub t0, s8, t3        # t0 = x - 1
    add t1, t1, t0       # t1 = (y - 1) * width + (x - 1)
    add t1, t1, s3      # t1 = buffer pointer to the upper-left pixel
    lbu t2, 0(t1)        # load upper-left pixel value
    sub s1, s1, t2       # subtract from accumulator

    # upper pixel: position = (y-1)*width + x
    sub t0, s7, t3        # t0 = y - 1
    mul t1, t0, s4       # t1 = (y - 1) * width
    add t1, t1, s8       # t1 = (y - 1) * width + x
    add t1, t1, s3      # t1 = buffer pointer to the upper pixel
    lbu t2, 0(t1)        # load upper pixel value
    sub s1, s1, t2       # subtract from accumulator

    # upper-right pixel: position = (y-1)*width + (x+1)
    sub t0, s7, t3        # t0 = y - 1
    mul t1, t0, s4       # t1 = (y - 1) * width
    addi t0, s8, 1        # t0 = x + 1
    add t1, t1, t0       # t1 = (y - 1) * width + (x + 1)
    add t1, t1, s3      # t1 = buffer pointer to the upper-right pixel
    lbu t2, 0(t1)        # load upper-right pixel value
    sub s1, s1, t2       # subtract from accumulator

    # left pixel: position = y*width + (x-1)
    mul t1, s7, s4       # t1 = y * width
    sub t0, s8, t3        # t0 = x - 1
    add t1, t1, t0       # t1 = y * width + (x - 1)
    add t1, t1, s3      # t1 = buffer pointer to the left pixel
    lbu t2, 0(t1)        # load left pixel value
    sub s1, s1, t2       # subtract from accumulator

    # right pixel: position = y*width + (x+1)
    mul t1, s7, s4       # t1 = y * width
    addi t0, s8, 1        # t0 = x + 1
    add t1, t1, t0       # t1 = y * width + (x + 1)
    add t1, t1, s3      # t1 = buffer pointer to the right pixel
    lbu t2, 0(t1)        # load right pixel value
    sub s1, s1, t2       # subtract from accumulator

    # lower-left pixel: position = (y+1)*width + (x-1)
    addi t0, s7, 1        # t0 = y + 1
    mul t1, t0, s4       # t1 = (y + 1) * width
    sub t0, s8, t3        # t0 = x - 1
    add t1, t1, t0       # t1 = (y + 1) * width + (x - 1)
    add t1, t1, s3      # t1 = buffer pointer to the lower-left pixel
    lbu t2, 0(t1)        # load lower-left pixel value
    sub s1, s1, t2       # subtract from accumulator

    # lower pixel: position = (y+1)*width + x
    addi t0, s7, 1        # t0 = y + 1
    mul t1, t0, s4       # t1 = (y + 1) * width
    add t1, t1, s8       # t1 = (y + 1) * width + x
    add t1, t1, s3      # t1 = buffer pointer to the lower pixel
    lbu t2, 0(t1)        # load lower pixel value
    sub s1, s1, t2       # subtract from accumulator

    # lower-right pixel: position = (y+1)*width + (x+1)
    addi t0, s7, 1        # t0 = y + 1
    mul t1, t0, s4       # t1 = (y + 1) * width
    addi t0, s8, 1        # t0 = x + 1
    add t1, t1, t0       # t1 = (y + 1) * width + (x + 1)
    add t1, t1, s3      # t1 = buffer pointer to the lower-right pixel
    lbu t2, 0(t1)        # load lower-right pixel value
    sub s1, s1, t2       # subtract from accumulator

    # Multiply the center pixel by 8 and add to the accumulator
    li t0, 8            # initialize 8
    mul t1, s7, s4       # t1 = y * width
    add t1, t1, s8       # t1 = y * width + x
    add t1, t1, s3      # t1 = buffer pointer to the center pixel
    lbu t2, 0(t1)        # load center pixel value
    mul t2, t2, t0       # multiply by 8
    add s1, s1, t2       # add to accumulator

    # If the result in s1 is negative, set s1 to 0 and return 0
    li t0, 0            # initialize 0
    ble t0, s1, test_greater_than_255  # if s1 >= 0, continue
    li s1, 0            # set s1 to 0
    j end_apply_filter

    test_greater_than_255:
    # If the result in s1 is bigger than 255, set s1 to 255
    li t0, 255          # initialize 255
    blt s1, t0, end_apply_filter # if s1 <= 255, continue
    li s1, 255           # set s1 to 255
    j end_apply_filter

    end_apply_filter:
    ret



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

    parse_pixels:
    addi s11, s11, 5      # skip the "\n255\n" part (since Maxval is always 255)
    # Now, s11 points to the first pixel value
    mv s3, s11           # store the buffer pointer (to the beginning of pixel data) in s3

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
    
    
    
    jal apply_filter    # apply filter to the pixel
    # Now, the color is in s1


    # Set RGB color: R = G = B = pixel value, Alpha = 255
    li s2, 0xFF        # initialize color to 0xFF (Alpha channel)
    slli s1, s1, 8      # shift grayscale value to the left by 8 bits
    or s2, s2, s1       # set blue channel

    slli s1, s1, 8      # shift grayscale value to the left by 8 bits
    or s2, s2, s1       # set green channel

    slli s1, s1, 8      # shift grayscale value to the left by 8 bits
    or s2, s2, s1       # set red channel
    

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