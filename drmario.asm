################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Dongqi(Hans) Li, 1010133561
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       2
# - Unit height in pixels:      2
# - Display width in pixels:    64
# - Display height in pixels:   64
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################
    .data
displayaddress:     .word       0x10008000
capsule_x:          .word       0
capsule_y:          .word       0

##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
.text
# ...

	
	.globl main

    # Run the game.
main:
    # red 0xff0000
    # yellow  0xffff00
    # cyan(better blue) 0x00ffff
    # white 0xffffff
    # black 0x000000
    lw $t0, displayaddress # $t0 = base address for display
    li $t1, 0xff0000
    li $t2, 0xffff00
    li $t3, 0x00ffff
    li $t4, 0xffffff
    li $t5, 0x000000
    li $t6, 0x000000

    # this t7, t8 and t9 are now free
    jal draw_scene
    # Initialize the game
    
    
game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    collision_checker:
    
    cancel_checker:
    
    j game_loop
    
    
    
    
draw_scene:
    draw_bottle:
        addi $a0, $zero, 2          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 8         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
        addi $a2, $zero, 17          # Set the width of the rectangle (in pixels)
        addi $a3, $zero, 24          # Set the height of the rectangle (in pixels)
        add $t6, $t4, $zero
            jal draw_rect
            
        addi $a0, $zero, 3 
        addi $a1, $zero, 9    
        addi $a2, $zero, 15    
        addi $a3, $zero, 22         
        add $t6, $t5, $zero # erase the center and lid by drawing it black
            jal draw_rect
        addi $a0, $zero, 9
        addi $a1, $zero, 8
        addi $a2, $zero, 3      
        addi $a3, $zero, 1     
            jal draw_rect
            
        addi $a0, $zero, 8
        addi $a1, $zero, 5
        addi $a2, $zero, 1         
        addi $a3, $zero, 3   
        add $t6, $t4, $zero # draw the 2 pointing out in white
            jal draw_rect
        addi $a0, $zero, 12
        addi $a1, $zero, 5
        addi $a2, $zero, 1      
        addi $a3, $zero, 3       
            jal draw_rect
    draw_virus_art:
        addi $a0, $zero, 1          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 2         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
        add $t6, $t1, $zero
            jal draw_dot
        addi $a0, $zero, 3          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 2         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
        add $t6, $t2, $zero
            jal draw_dot
        addi $a0, $zero, 5          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 2         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
        add $t6, $t3, $zero
            jal draw_dot
jr $ra
    
#  The rectangle drawing function
#
#  $a0 = X coordinate for start of the line
#  $a1 = Y coordinate for start of the line
#  $a2 = wdith of the rectangle 
#  $a3 = height of the rectangle 
#  $t0 = the current row being drawn 
draw_rect:
    add $t0, $zero, $zero       # create a loop variable with an iniital value of 0
    row_start:
        # Use the stack to store all registers that will be overwritten by draw_line
        addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
        sw $t0, 0($sp)              # store $t0 on the stack
        addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
        sw $a0, 0($sp)              # store $a0 on the stack
        addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
        sw $a1, 0($sp)              # store $a1 on the stack
        addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
        sw $a2, 0($sp)              # store $a2 on the stack
        addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
        sw $ra, 0($sp)              # store $ra on the stack
        addi $sp, $sp, -4
        sw $t1, 0($sp)
        addi $sp, $sp, -4
        sw $t2, 0($sp)
        jal draw_line               # call the draw_line function
        
# restore all the registers that were stored on the stack
        lw $t2, 0($sp)
        addi $sp, $sp, 4 
        lw $t1, 0($sp)
        addi $sp, $sp, 4 
        lw $ra, 0($sp)              # restore $ra from the stack
        addi $sp, $sp, 4            # move the stack pointer to the new top element
        lw $a2, 0($sp)              # restore $a2 from the stack
        addi $sp, $sp, 4            # move the stack pointer to the new top element
        lw $a1, 0($sp)              # restore $a1 from the stack
        addi $sp, $sp, 4            # move the stack pointer to the new top element
        lw $a0, 0($sp)              # restore $a0 from the stack
        addi $sp, $sp, 4            # move the stack pointer to the new top element
        lw $t0, 0($sp)              # restore $t0 from the stack
        addi $sp, $sp, 4            # move the stack pointer to the new top element

    addi $a1, $a1, 1            # move to the next row to draw
    addi $t0, $t0, 1            # increment the row variable by 1
    # if row number < max row
        beq $t0, $a3, row_end       # when the last line has been drawn, break out of the line-drawing loop
        j row_start     # jump to the start of the line-drawing section
    # else:
        row_end:
    lw $t0, displayaddress
jr $ra                      # return to the calling program

#
#  The line drawing function
#
#  $a0 = X coordinate for start of the line
#  $a1 = Y coordinate for start of the line
#  $a2 = length of the line
#  
draw_dot:
    lw $t0, displayaddress      # $t0 = base address for display
    sll $a1, $a1, 7             # Calculate the Y offset to add to $t0 (multiply $a1 by 128)
    sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $a0 by 4)
    add $t7, $t0, $a1           # Add the Y offset to $t0, store the result in $t2
    add $t7, $t7, $a0           # Add the X offset to $t2 ($t2 now has the starting location of the line in bitmap memory)
    sw $t6, 0($t7)              # Draw the pixel at location
jr $ra

draw_line:
    lw $t0, displayaddress      # $t0 = base address for display
    sll $a1, $a1, 7             # Calculate the Y offset to add to $t0 (multiply $a1 by 128)
    sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $a0 by 4)
    add $t2, $t0, $a1           # Add the Y offset to $t0, store the result in $t2
    add $t2, $t2, $a0           # Add the X offset to $t2 ($t2 now has the starting location of the line in bitmap memory)
    # Calculate the final point in the line (start point + length x 4)
    sll $a2, $a2, 2             # Multiply the length by 4
    add $t3, $t2, $a2           # Calculate the address of the final point in the line, store result in $t3.
    # Start the loop
    line_start:
        sw $t6, 0($t2)              # Draw the pixel at location
        # while current pixel has not reached end
        # Loop until the current pixel has reached the final point in the line
        addi $t2, $t2, 4            # Move the current location to the next pixel
        # if t2 == t3
            beq $t2, $t3, line_end      # Break out of the loop when $t2 == $t3
            j line_start
    # End the loop
    line_end:
    # Return to calling program
jr $ra

draw_pill:
jr $ra

draw_virus:
jr $ra

draw_score:

    jr $ra
# generate a random pill