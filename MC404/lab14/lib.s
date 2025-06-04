.bss 
.globl _system_time
_system_time: .word 
program_stack: .skip 1024
end_of_program_stack: // The end of the stack (allocated right after the end of the 1024 bytes of program_stack)
isr_stack: .skip 16
end_of_isr_stack: // The end of the stack (allocated right after the end of the 16 bytes of isr_stack)


.text
.set BASE_GPT, 0xFFFF0100
.globl _start
/*
    The _start function is the entry point of the program. It initializes the stack, sets the interrupts, and calls the main function.
*/
_start:
    // Set the stack pointer
    la sp, end_of_program_stack
    la t0, end_of_isr_stack
    csrw mscratch, t0  // Save the stack pointer in the mscratch register

    // Set the main_isr as the interrupt handler
    la t0, main_isr   // Load the address of the main_isr
    csrw mtvec, t0  // Set the interrupt vector

    // Enable global interrupts
    csrr t1, mstatus  // Load the status register
    ori t1, t1, 0x8  // Set the MIE bit
    csrw mstatus, t1  // Store the status register

    // Enable the external interrupt
    csrr t1, mie  // Load the interrupt enable register
    li t0, 0x800
    or t1, t1, t0  // Set the MEIE bit
    csrw mie, t1  // Store the interrupt enable register

    // Set the first timer of 100ms
    li t0, 100
    li t1, BASE_GPT
    sw t0, 8(t1)

    // Call the main function
    jal ra, main


.align 2
main_isr:
    // Save the context
    csrrw sp, mscratch, sp  // Save the stack pointer
    addi sp, sp, -16  // Allocate space for the context
    sw ra, 0(sp)  // Save the return address
    sw t0, 4(sp)  // Save the channel
    sw t1, 8(sp)  // Save the instrument ID
    sw t2, 12(sp)  // Save the note 

    // Treat the interrupt (update the system time and set another 100ms timer)
    la t1, _system_time
    lw t0, (t1)
    addi t0, t0, 100
    sw t0, (t1)

    li t0, 100
    li t1, BASE_GPT
    sw t0, 8(t1)

    // Restore the context
    lw ra, 0(sp)  // Restore the return address
    lw t0, 4(sp)  // Restore the channel
    lw t1, 8(sp)  // Restore the instrument ID
    lw t2, 12(sp)  // Restore the note
    addi sp, sp, 16  // Deallocate the context
    csrrw sp, mscratch, sp  // Restore the stack pointer

    mret  // Return from the interrupt



.set BASE_MIDI, 0xFFFF0300
.globl play_note
/*  The play_note function is used to play a note on the MIDI synthesizer.
    The function takes in the channel, instrument, note, velocity, and duration as parameters.

    parameters:
        a0 - channel (byte): base+0x00
        a1 - instrument ID (short): base+0x02
        a2 - note (byte): base+0x04
        a3 - velocity (byte): base+0x05
        a4 - duration (short): base+0x06
*/
play_note:
    li t0, BASE_MIDI
    sh a1, 2(t0)  // Store the instrument ID
    sb a2, 4(t0)  // Store the note
    sb a3, 5(t0)  // Store the velocity
    sh a4, 6(t0)  // Store the duration
    sb a0, 0(t0)  // Store the channel

    ret