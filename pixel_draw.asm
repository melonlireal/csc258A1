.data
displayaddress:     .word       0x10008000
capsule_x:          .word       0
capsule_y:          .word       0
# ...

.text
# ...
lw $t0, displayaddress # $t0 = base address for display
li $t2, 0x00ff00 # $t2 = green
li $t3, 0x0000ff # $t4 = blue
li $t1, 0xff0000 # $t1 = red
add $t4, $t1, $t2  # add $t1 and $t2 to make yellow
add $t5, $t2, $t3 # $the better blue
add $t6, $t4, $t3  # add $t4 and $t3 to make white
li $t7, 0x000000 # t7 is default black
########################################################################
###  Everything above this line was provided in the project handout  ###
########################################################################

# Experimenting with pixels and pixel colours
sw $t4, 0( $t0 ) # paint the third unit on the first row yellow
sw $t1, 4( $t0 ) # paint the fourth unit on the first row red
sw $t5, 8( $t0 ) # paint the fourth unit on the first row cyan
sw $t6, 12( $t0 ) # paint the fifth unit on the first row white

# Set up the parameters for the rectangle drawing function
addi $a0, $zero, 4          # Set the X coordinate for the top left corner of the rectangle (in pixels)
addi $a1, $zero, 4         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
addi $a2, $zero, 18          # Set the width of the rectangle (in pixels)
addi $a3, $zero, 24          # Set the height of the rectangle (in pixels)
jal draw_bottle


li $v0, 10                  # exit the program gracefully
syscall                     # (so it doesn't continue into the draw_rect function again)


# draw the bottle at a fixed size
draw_bottle:
    addi $a0, $zero, 2          # Set the X coordinate for the top left corner of the rectangle (in pixels)
    addi $a1, $zero, 6         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
    addi $a2, $zero, 17          # Set the width of the rectangle (in pixels)
    addi $a3, $zero, 24          # Set the height of the rectangle (in pixels)
    add $t7, $t4, $t3
        jal draw_rect
    addi $a0, $zero, 3          # Set the X coordinate for the top left corner of the rectangle (in pixels)
    addi $a1, $zero, 7         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
    addi $a2, $zero, 15         # Set the width of the rectangle (in pixels)
    addi $a3, $zero, 22          # Set the height of the rectangle (in pixels)
    li $t7, 0x000000
        jal draw_rect
    addi $a0, $zero, 9
    addi $a1, $zero, 6
    addi $a2, $zero, 3      
    addi $a3, $zero, 1     
        jal draw_rect
        add $t7, $t4, $t3
    addi $a0, $zero, 8
    addi $a1, $zero, 3
    addi $a2, $zero, 1         
    addi $a3, $zero, 3      
        jal draw_rect
    addi $a0, $zero, 12
    addi $a1, $zero, 3
    addi $a2, $zero, 1      
    addi $a3, $zero, 3       
        jal draw_rect
    
    jr $ra

# generate a random pill    
draw_pill:
    

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
        jal draw_line               # call the draw_line function

# restore all the registers that were stored on the stack
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
beq $t0, $a3, row_end       # when the last line has been drawn, break out of the line-drawing loop
j row_start                 # jump to the start of the line-drawing section
row_end:
jr $ra                      # return to the calling program

#
#  The line drawing function
#
#  $a0 = X coordinate for start of the line
#  $a1 = Y coordinate for start of the line
#  $a2 = length of the line
#  
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
    sw $t7, 0($t2)              # Draw a yellow pixel at the current location in the bitmap
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
