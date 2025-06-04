.globl _start
.set BASE_ADDRESS, 0xFFFF0100

brake:
    li t0, BASE_ADDRESS # t0 = base address
    li t1, 0x21 # t1 = offset
    add t1, t0, t1 # t1 = base address + offset
    li t2, 0 # t2 = 1
    sb t2, (t1) # Sets the engine direction to forward

    li t1, 0x22  # offset to the wheel
    add t1, t0, t1 # t1 = base address + offset
    li t2, 1
    sb t2, (t1) # Sets the brake
    ret


read_x_coord: # returns x at t2
    lp:
    li t0, BASE_ADDRESS # t0 = base address
    li t1, 0x10 # t1 = offset
    add t1, t0, t1 # t1 = base address + offset
    lw t2, (t1) # t2 = x coordinate

    lb t3, (t0)
    beqz t3, end_func # if the reading is completed, exit

    j lp

    end_func:
    ret


_start:
    /*
    base = 0xFFFF0100
    base+0x21	byte	Sets the engine direction.
    1: forward.
    0: off.
    -1: backward.
    */

    
    li t0, BASE_ADDRESS # t0 = base address
    li t1, 0x21 # t1 = offset
    add t1, t0, t1 # t1 = base address + offset
    li t2, 1 # t2 = 1
    sb t2, (t1) # Sets the engine direction to forward

    li t1, 0x20  # offset to the wheel 
    add t1, t0, t1 # t1 = base address + offset
    li t2, -15 # t2 = angle of the wheel (negative value is to the left)
    sb t2, (t1) # Sets the wheel angle to -50


    /*
    base+0x00	byte	Storing “1” triggers the GPS device to start reading the coordinates and rotation of the car. The register is set to 0 when the reading is completed.
    */

    # target: x: 74.3, z: -16.5
    # x < 130: brake
    loop:
    # check x coordinate
    addi t1, t0, 0x00 # t1 = base address + offset
    li t2, 1 # t2 = 1
    sb t2, (t1) # Starts reading the coordinates and rotation of the car

    jal read_x_coord # reads x coordinate
    li t3, 82 # t3 = target x coordinate
    blt t2, t3, exit # if x coordinate is less than 74, exit

    li t3, 133 # t3 = brake x coordinate
    blt t2, t3, brake_func
    j loop

    brake_func:
    jal ra, brake
    j loop



exit:
    # Exit the program
    li a0, 0
    li a7, 93
    ecall