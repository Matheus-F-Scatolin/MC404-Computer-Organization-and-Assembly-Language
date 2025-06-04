.bss 
program_stack: .skip 1024
end_of_program_stack: // The end of the stack (allocated right after the end of the 1024 bytes of program_stack)
isr_stack: .skip 16
end_of_isr_stack: // The end of the stack (allocated right after the end of the 16 bytes of isr_stack)
x_coord: .skip 4


.text
.set BASE_ADDRESS, 0xFFFF0100
.align 4

int_handler:
    ###### Syscall and Interrupts handler ######
    # save context
    csrrw sp, mscratch, sp  # Save the stack pointer
    addi sp, sp, -32        # Allocate space for the context

    sw t0, 0(sp) 
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    sw t4, 16(sp)


    # <= Implement your syscall handler here
    li t0, 10
    beq a7, t0, syscall_set_engine_and_steering
    li t0, 15
    beq a7, t0, syscall_get_position

    int_handler_end:
    # restore context
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    lw t4, 16(sp)

    addi sp, sp, 32
    csrrw sp, mscratch, sp  # Restore the stack pointer

    csrr t0, mepc  # load return address (address of
                    # the instruction that invoked the syscall)
    addi t0, t0, 4 # adds 4 to the return address (to return after ecall)
    csrw mepc, t0  # stores the return address back on mepc
    mret           # Recover remaining context (pc <- mepc)


syscall_set_engine_and_steering:
    # Set the engine direction 
    li t0, BASE_ADDRESS # t0 = base address
    li t1, 0x21 # t1 = offset
    add t1, t0, t1 # t1 = base address + offset
    sb a0, (t1) # Sets the engine direction according to a0

    # Set the wheel angle
    li t1, 0x20  # offset to the wheel
    add t1, t0, t1 # t1 = base address + offset
    sb a1, (t1) # Sets the wheel angle according to a1

    j int_handler_end


syscall_get_position:
    li t0, BASE_ADDRESS # t0 = base address
    li t2, 1 # t2 = 1
    sb t2, (t0) # Starts reading the coordinates and rotation of the car

    lp:
    li t1, 0x10 # t1 = offset
    add t1, t0, t1 # t1 = base address + offset
    lw t3, (t1) # t3 = x coordinate

    lb t4, (t0)
    beqz t4, end_func # if the reading is completed, exit

    j lp

    end_func:
    sw t3, (a0) # Stores the x coordinate in the address pointed by a0
    j int_handler_end


.globl _start
_start:
    // Set the stack pointer
    la sp, end_of_program_stack
    la t0, end_of_isr_stack
    csrw mscratch, t0  // Save the stack pointer in the mscratch register


    la t0, int_handler  # Load the address of the routine that will handle interrupts
    csrw mtvec, t0      # (and syscalls) on the register MTVEC to set
                        # the interrupt array.

    // Enable global interrupts
    csrr t1, mstatus  // Load the status register
    ori t1, t1, 0x8  // Set the MIE bit
    csrw mstatus, t1  // Store the status register

    // change to user mode and jump to user_main
    csrr t1, mstatus # Update the mstatus.MPP
    li t2, ~0x1800 # field (bits 11 and 12)
    and t1, t1, t2 # with value 00 (U-mode)
    csrw mstatus, t1
    la t0, user_main # Loads the user software
    csrw mepc, t0 # entry point into mepc
    mret # PC <= MEPC; mode <= MPP;


/*
syscall_get_position
Code: 15	a0: address of the variable that will store the value of x position.
a1: address of the variable that will store the value of y position.
a2: address of the variable that will store the value of z position.	-	Read the car's approximate position using the GPS device.
*/
.globl control_logic
control_logic:
    # implement your control logic here, using only the defined syscalls
    # Sets the engine direction to forward and left wheel angle to -15
    li a0, 1
    li a1, -16
    li a7, 10
    ecall
    
    loop:
    # check x coordinate
    la a0, x_coord # a0 = address of x_coord
    li a7, 15 # syscall_get_position
    ecall

    li t3, 82 # t3 = target x coordinate
    la a0, x_coord # a0 = address of x_coord
    lw t2, 0(a0) # t2 = x coordinate
    blt t2, t3, exit # if x coordinate is less than 74, exit

    #li t3, 133 # t3 = brake x coordinate
    #blt t2, t3, brake_func
    j loop



exit:
