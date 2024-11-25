 ##############################################################################
# Example: Keyboard Input
#
# This file demonstrates how to read the keyboard to check if the keyboard
# key q was pressed.
##############################################################################
    .data
ADDR_KBRD:
    .word 0xffff0000
    .text
	.globl main

main:
	li 		$v0, 32
	li 		$a0, 500
	syscall # sleep for 0.5 sec

    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    li $v0, 1
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    j main

keyboard_input:                     # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed

    li $v0, 1                       # ask system to print $a0
    syscall

    j main

respond_to_Q:
	li $v0, 10                      # Quit gracefully
	syscall
