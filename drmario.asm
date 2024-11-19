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
displayaddress:     .word   0x10008000
capsule1_x:         .word   0
capsule1_y:         .word   0
capsule2_x:         .word   0
capsule2_y:         .word   0
red:                .word   0xff0000
yellow:             .word   0xffff00
blue:               .word   0x00ffff
white:              .word   0xffffff
black:              .word   0x000000

##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!

ADDR_KBRD:
    .word 0xffff0000
    .text
	.globl main

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
# ...


    # Run the game.
main:
    # red 0xff0000
    # yellow  0xffff00
    # cyan(better blue) 0x00ffff
    # white 0xffffff
    # black 0x000000
    lw $t0, displayaddress # $t0 = base address for display
    li $t1, 0x000000
    .eqv color $t1
    li $t4, 0 # x pill 1 
    li $t5, 0 # y pill 1
    li $t6, 0 # x pill 2
    li $t7, 0 # y pill 2
    .eqv x_pill1 $t4
    .eqv y_pill1 $t5
    .eqv x_pill2 $t6
    .eqv y_pill2 $t7
    # NEVER TOUCH THESE
    # thus $t2 - $t9 are now free
    jal draw_scene
    jal draw_pill
    # Initialize the game
    
    
    
game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep
    # 5. Go back to Step 1
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input # check if there is key input
    cancel_checker:
    
    li 	$v0, 32
	li 	$a0, 500
	syscall # sleep for 0.5 sec
    j game_loop
    
    
draw_scene:
    lw $t0 displayaddress
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp) 
    draw_bottle:
        addi $a0, $zero, 2          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 8         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
        addi $a2, $zero, 17          # Set the width of the rectangle (in pixels)
        addi $a3, $zero, 24          # Set the height of the rectangle (in pixels)
        lw color, white
            jal draw_rect
            
        addi $a0, $zero, 3 
        addi $a1, $zero, 9    
        addi $a2, $zero, 15    
        addi $a3, $zero, 22         
        lw color, black # erase the center and lid by drawing it black
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
        lw color, white # draw the 2 pointing out in white
            jal draw_rect
        addi $a0, $zero, 12
        addi $a1, $zero, 5
        addi $a2, $zero, 1      
        addi $a3, $zero, 3       
            jal draw_rect
        addi $a2, $zero, 1      
        addi $a3, $zero, 1
        
    draw_virus_art:
        addi $a0, $zero, 1          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 2         # Set the Y coordinate for the top left corner of the rectangle (in pixels)  
        lw color, red
            jal draw_rect
        addi $a0, $zero, 3          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 2         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
        lw color, yellow
            jal draw_rect
        addi $a0, $zero, 5          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 2         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
        lw color, blue
            jal draw_rect
            
    draw_virus:
        addi $a0, $zero, 10          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 25         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
        lw color, red
            jal draw_rect
        addi $a0, $zero, 8          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 20         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
        lw color, yellow
            jal draw_rect
        addi $a0, $zero, 5          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 22         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
        lw color, blue
            jal draw_rect
        lw $ra, 0($sp)
        addi $sp, $sp, 4 
        jr $ra
    
#  The rectangle drawing function
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

#  The line drawing function
#  $a0 = X coordinate for start of the line
#  $a1 = Y coordinate for start of the line
#  $a2 = length of the line
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
        sw color, 0($t2)              # Draw the pixel at location
        # while current pixel has not reached end
        # Loop until the current pixel has reached the final point in the line
        #####
        # addi $t4, $a1, 128
        # lw $t5, 0(t4)
        # if $t5 == 0x000000
        #####
        addi $t2, $t2, 4            # Move the current location to the next pixel
        # if t2 == t3
            beq $t2, $t3, line_end      # Break out of the loop when $t2 == $t3
            j line_start
    # End the loop
    line_end:
    # Return to calling program
jr $ra


# generate a random pill at t
# a0 x coord
# a1 y coord
# t5 color pill 
draw_pill:
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)
    jal set_random_color
    addi $a0, $zero, 10
    addi $a1, $zero, 6
    addi $a2, $zero, 1      
    addi $a3, $zero, 1 
    li x_pill1, 10
    li y_pill1, 6
    jal draw_rect
    jal set_random_color
    addi $a0, $zero, 10
    addi $a1, $zero, 7
    addi $a2, $zero, 1      
    addi $a3, $zero, 1 
    li x_pill2 10
    li y_pill2 7
    jal draw_rect
    lw $ra, 0($sp)
    addi $sp, $sp, 4 
    jr $ra
    
    
set_random_color:
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a0, 0($sp)
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a1, 0($sp)
    # store a0 and a1 before replacing them
    li $v0, 42
    li $a0, 0
    li $a1, 3
    syscall
    beq $a0, 0, set_red
    beq $a0, 1, set_yellow
    beq $a0, 2, set_blue
    # there are 3 color, 0 for red, 1 for yellow and 2 for blue
    set_red:
        lw color, red
        j end
    set_yellow:
        lw color, yellow
        j end
    set_blue:
        lw color, blue
        j end
    end:
        lw $a1, 0($sp)
        addi $sp, $sp, 4 
        lw $a0, 0($sp)
        addi $sp, $sp, 4 
    jr $ra
    
    
    #a0 x pos
    #a1 y pos
    #t0 display address

# do this by erasing current pos and redraw pill at new pos
# s0 curr x coord part1
# s1 curr y coord part1
# s2 curr x coord part2
# s3 curr y coord part2
# s4 part1 col
# s5 part2 col
move_pill:



keyboard_input:
    lw $a0, 4($t0) # Load second word from keyboard
    beq $a0, 119, respond_to_W
    beq $a0, 97, respond_to_A
    beq $a0, 115, respond_to_S
    beq $a0, 100, respond_to_D
    beq $a0, 0x71, respond_to_Q
    jr $ra

respond_to_W:
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp) 
    li $v0, 1
    syscall
    addi ,$a0 ,$t6,-1
    addi , $a1, $t7, -1
    # beg blah blah donothing
    lw $ra, 0($sp)
    addi $sp, $sp, 4 
    donothingW:
    jr $ra
    
respond_to_A:
    #
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp) 
    #
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    jal fetch_color
    # chech color at initial spot
    subi x_pill1, x_pill1, 1
    subi x_pill2, x_pill2, 1
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    jal fetch_color
    lw color, 0($t0)
    jal draw_rect
    # beg blah blah donothing
    
    # load stuff
    lw $ra, 0($sp)
    addi $sp, $sp, 4 
    #
    donothingA:
    jr $ra
    
respond_to_S:
    li $v0, 1
    syscall
    
    jr $ra
    donothingS:
    jr $ra
    
respond_to_D:
    li $v0, 1
    syscall
    
    jr $ra
    donothingD:
    jr $ra
    
respond_to_Q:
	li $v0, 10                      # Quit gracefully
	syscall
    
fetch_color:
    
    lw $t0, displayaddress      # $t0 = base address for display
    sll $a1, $a1, 7             # Calculate the Y offset to add to $t0 (multiply $a1 by 128)
    sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $a0 by 4)
    add $t2, $t0, $a1           # Add the Y offset to $t0, store the result in $t2
    add $t2, $t2, $a0           # Add the X offset to $t2 ($t2 now is the location of the place to fetch color)
    sw color, 0($t2)              # fetch color
    add $a0, color, $zero
    li $v0, 1
    syscall
    jr $ra
    
collision_checker: