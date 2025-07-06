################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
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
red_virus_pos:        .word   0
yellow_virus_pos:     .word   0
blue_virus_pos:       .word   0
red:                .word   0xff0000
yellow:             .word   0xffff00
blue:               .word   0x00ffff
white:              .word   0xffffff
black:              .word   0x000000
grey:               .word   0x808080
rose:               .word   0xffc5cb
pill1_list:         .space  400 # store all pill pos if necessary
pill2_list:         .space  400 # store all pill pos if necessary
pill_grid1:         .word 16
pill_grid2:         .word 18
pill_grid3:         .word 20
pill_grid4:         .word 22


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
    # s5 timer
    # s6 score
    lw $t0, displayaddress # $t0 = base address for display
    li $t1, 0x000000
    .eqv color $t1
    li $t4, 0 # x pill 1 
    li $t5, 0 # y pill 1
    li $t6, 0 # x pill 2
    li $t7, 0 # y pill 2
    li $s5, 30 # gravity counter
    li $s6, 1 # score counter, actual score = score -1
    .eqv x_pill1 $t4
    .eqv y_pill1 $t5
    .eqv x_pill2 $t6
    .eqv y_pill2 $t7
    .eqv gravity_counter $s5
    .eqv score $s6
    .eqv x $a0
    .eqv y $a1
    .eqv x_max $a2
    .eqv y_max $a3
    # NEVER TOUCH THESE
    # thus $t8 - $t9 are now free
    jal draw_scene
    jal pill_shift
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
    sub gravity_counter,  gravity_counter, score # as score increase, gravity counter dercrease faster, thus the pill falls faster
    #
    
    #
    ble gravity_counter, 0, fall
    li 	$v0, 32
	li 	$a0, 16
	syscall # update 60 time 1 sec
    j game_loop
    

fall:
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $t0 on the stack
    li gravity_counter, 30
    jal respond_to_S
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
        addi $sp, $sp, -4       
        sw $t0, 0($sp)            
        addi $sp, $sp, -4      
        sw $a0, 0($sp)            
        addi $sp, $sp, -4     
        sw $a1, 0($sp)            
        addi $sp, $sp, -4         
        sw $a2, 0($sp)           
        addi $sp, $sp, -4        
        sw $ra, 0($sp)          
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
        lw $ra, 0($sp)             
        addi $sp, $sp, 4         
        lw $a2, 0($sp)          
        addi $sp, $sp, 4         
        lw $a1, 0($sp)         
        addi $sp, $sp, 4         
        lw $a0, 0($sp)            
        addi $sp, $sp, 4            
        lw $t0, 0($sp)           
        addi $sp, $sp, 4         

    addi $a1, $a1, 1            # move to the next row to draw
    addi $t0, $t0, 1            # increment the row variable by 1
    # if row number < max row
        beq $t0, $a3, row_end       # when the last line has been drawn, break out of the line-drawing loop
        j row_start     # jump to the start of the line-drawing section
    # else:
        row_end:
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
        addi $t2, $t2, 4            # Move the current location to the next pixel
        # if t2 == t3
            beq $t2, $t3, line_end      # Break out of the loop when $t2 == $t3
            j line_start
    # End the loop
    line_end:
    # Return to calling program
jr $ra


# iterate across pill panel, if position is black get pill from next position and loop back
pill_shift:
#
    addi $sp, $sp, -4  
    sw $ra, 0($sp)
    addi $sp, $sp, -4  
    sw $a0, 0($sp)
    addi $sp, $sp, -4  
    sw $a1, 0($sp)
    addi $sp, $sp, -4  
    sw $a2, 0($sp)
    addi $sp, $sp, -4  
    sw $a3, 0($sp)
#
# pill grid 1 get from pill grid 2, pill grid 2 get from 3, 3 get from 4, if 4 is black then re iterate again
start_shift:
shift_gird1:
lw $a0, pill_grid1
li $a1 , 4
jal fetch_color
bne color, 0x000000, shift_grid2 # if grid 1 has pill go next
lw $a0, pill_grid1
li $a1 , 4
jal get_pill_up
jal get_pill_down

shift_grid2:
lw $a0, pill_grid2
li $a1 , 4
jal fetch_color
bne color, 0x000000, shift_grid3 # if grid 2 has pill go next
lw $a0, pill_grid2
li $a1 , 4
jal get_pill_up
jal get_pill_down

shift_grid3:
lw $a0, pill_grid3
li $a1 , 4
jal fetch_color
bne color, 0x000000, paint_grid4 # if grid 3 has pill go next
lw $a0, pill_grid3
li $a1 , 4
jal get_pill_up
jal get_pill_down

paint_grid4:
lw $a0, pill_grid4
li $a1 , 4
jal fetch_color
bne color, 0x000000, shift_end
lw $a0, pill_grid4
li $a1 , 4
jal gird4_draw_pill
j start_shift # jump if a pill is needed to be drawn on the last slot
shift_end:
#
    lw $a3, 0($sp)
    addi $sp, $sp, 4 
    lw $a2, 0($sp)
    addi $sp, $sp, 4 
    lw $a1, 0($sp)
    addi $sp, $sp, 4 
    lw $a0, 0($sp)
    addi $sp, $sp, 4 
    lw $ra, 0($sp)
    addi $sp, $sp, 4 
# 
jr $ra

# $a0 x coord
# $a1, y coord
fetch_color:
    lw $t0, displayaddress      # $t0 = base address for display
    sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $a0 by 4)
    sll $a1, $a1, 7             # Calculate the Y offset to add to $t0 (multiply $a1 by 128)
    add $t2, $t0, $a1           # Add the Y offset to $t0, store the result in $t2
    add $t2, $t2, $a0           # Add the X offset to $t2 ($t2 now is the location of the place to fetch color)
    lw color, 0($t2)              # fetch color
    jr $ra
    
# $a0 current pos
# a0 + 2 is the next grid
get_pill_up:
#
    addi $sp, $sp, -4  
    sw $ra, 0($sp)
    addi $sp, $sp, -4  
    sw $a0, 0($sp)
    addi $sp, $sp, -4  
    sw $a1, 0($sp)
    addi $sp, $sp, -4  
    sw $a2, 0($sp)
    addi $sp, $sp, -4  
    sw $a3, 0($sp)
#
li $a1, 4
li $a2, 1
li $a3, 1

#
    addi $sp, $sp, -4  
    sw $a0, 0($sp)
    addi $sp, $sp, -4  
    sw $a1, 0($sp)
#
addi $a0, $a0, 2
jal fetch_color
#
    lw $a1, 0($sp)
    addi $sp, $sp, 4
    lw $a0, 0($sp)
    addi $sp, $sp, 4
#
jal draw_rect

li $a1, 4
li $a2, 1
li $a3, 1
#
    addi $sp, $sp, -4 
    sw $a0, 0($sp) 
#
addi $a0, $a0, 2
lw color, black
jal draw_rect
#
    lw $a0, 0($sp)
    addi $sp, $sp, 4
#

#
    lw $a3, 0($sp)
    addi $sp, $sp, 4 
    lw $a2, 0($sp)
    addi $sp, $sp, 4 
    lw $a1, 0($sp)
    addi $sp, $sp, 4 
    lw $a0, 0($sp)
    addi $sp, $sp, 4 
    lw $ra, 0($sp)
    addi $sp, $sp, 4 
#
jr $ra

get_pill_down:
#
    addi $sp, $sp, -4  
    sw $ra, 0($sp)
    addi $sp, $sp, -4  
    sw $a0, 0($sp)
    addi $sp, $sp, -4  
    sw $a1, 0($sp)
    addi $sp, $sp, -4  
    sw $a2, 0($sp)
    addi $sp, $sp, -4  
    sw $a3, 0($sp)
#
li $a1, 5
li $a2, 1
li $a3, 1
#
    addi $sp, $sp, -4  
    sw $a0, 0($sp)
    addi $sp, $sp, -4  
    sw $a1, 0($sp)
#
addi $a0, $a0, 2
jal fetch_color
#
    lw $a1, 0($sp)
    addi $sp, $sp, 4
    lw $a0, 0($sp)
    addi $sp, $sp, 4
#
jal draw_rect
li $a1, 5
li $a2, 1
li $a3, 1
#
    addi $sp, $sp, -4  
    sw $a0, 0($sp)
#
addi $a0, $a0, 2
lw color, black
jal draw_rect
#
    lw $a0, 0($sp)
    addi $sp, $sp, 4
#

#
    lw $a3, 0($sp)
    addi $sp, $sp, 4 
    lw $a2, 0($sp)
    addi $sp, $sp, 4 
    lw $a1, 0($sp)
    addi $sp, $sp, 4 
    lw $a0, 0($sp)
    addi $sp, $sp, 4 
    lw $ra, 0($sp)
    addi $sp, $sp, 4 
#
jr $ra


gird4_draw_pill:
#
    addi $sp, $sp, -4  
    sw $ra, 0($sp)
    addi $sp, $sp, -4  
    sw $a0, 0($sp)
    addi $sp, $sp, -4  
    sw $a1, 0($sp)
    addi $sp, $sp, -4  
    sw $a2, 0($sp)
    addi $sp, $sp, -4  
    sw $a3, 0($sp)
#

    addi $a2, $zero, 1      
    addi $a3, $zero, 1 
    jal set_random_color
    addi $a0, $zero, 22
    addi $a1, $zero, 4
    jal draw_rect
    jal set_random_color
    addi $a0, $zero, 22
    addi $a1, $zero, 5
    jal draw_rect
#
    lw $a3, 0($sp)
    addi $sp, $sp, 4 
    lw $a2, 0($sp)
    addi $sp, $sp, 4 
    lw $a1, 0($sp)
    addi $sp, $sp, 4 
    lw $a0, 0($sp)
    addi $sp, $sp, 4 
    lw $ra, 0($sp)
    addi $sp, $sp, 4 
#   
    jr $ra



# generate a random pill
# s0 pill1 x
# s1 pill1 y
# s2 pill2 x
# s2 pill2 y
draw_pill:
#
    addi $sp, $sp, -4  
    sw $ra, 0($sp)
    addi $sp, $sp, -4  
    sw $a0, 0($sp)
    addi $sp, $sp, -4  
    sw $a1, 0($sp)
    addi $sp, $sp, -4  
    sw $a2, 0($sp)
    addi $sp, $sp, -4  
    sw $a3, 0($sp)
#

    addi $a2, $zero, 1      
    addi $a3, $zero, 1 
    li $s0, 10
    li $s1, 6
    li $s2, 10
    li $s3, 7
    jal collision_checker
    beq $s4, 1 respond_to_Q
    li $a0, 16
    li $a1, 4
    jal fetch_color
    li $a0, 10
    li $a1, 6
    jal draw_rect
    
    li $a0, 16
    li $a1, 4
    lw color black
    jal draw_rect
    
    li x_pill1, 10
    li y_pill1, 6
    
    li $a0, 16
    li $a1, 5
    jal fetch_color
    
    li $a0, 10
    li $a1, 7
    li x_pill2 10
    li y_pill2 7
    jal draw_rect
    
    li $a0, 16
    li $a1, 5
    lw color black
    jal draw_rect
    jal pill_shift
    
#
    lw $a3, 0($sp)
    addi $sp, $sp, 4 
    lw $a2, 0($sp)
    addi $sp, $sp, 4 
    lw $a1, 0($sp)
    addi $sp, $sp, 4 
    lw $a0, 0($sp)
    addi $sp, $sp, 4 
    lw $ra, 0($sp)
    addi $sp, $sp, 4 
#   
    jr $ra



#  $a0 = X coordinate for start of the scan 
#  $a1 = Y coordinate for start of the scan
#  $a2 = wdith of the rectangle to scan
#  $a3 = height of the rectangle to scan
#  $t0 = the current row being scanned
#  $t8 = is there cancel indicator, i.e number of same colors in row col
# area expected to be scanned: (3,9) -> (17, 30), i.e 18, 32 in scan
cancel_checker:
#
        addi $sp, $sp, -4
        sw $t0, 0($sp)
        addi $sp, $sp, -4      
        sw $a0, 0($sp)          
        addi $sp, $sp, -4        
        sw $a1, 0($sp)            
        addi $sp, $sp, -4        
        sw $a2, 0($sp)          
        addi $sp, $sp, -4       
        sw $a3, 0($sp)           
        addi $sp, $sp, -4          
        sw $ra, 0($sp)           
#
        addi x, $zero, 3 
        addi y, $zero, 9
        addi x_max, $zero, 18    
        addi y_max, $zero, 31  
jal scan_by_row # scan the playabe area via row

        addi x, $zero, 3 
        addi y, $zero, 9
        addi x_max, $zero, 18    
        addi y_max, $zero, 31 
jal scan_by_col # scan the playable area via colum
#
        lw $ra, 0($sp)            
        addi $sp, $sp, 4        
        lw $a3, 0($sp)           
        addi $sp, $sp, 4        
        lw $a2, 0($sp)          
        addi $sp, $sp, 4        
        lw $a1, 0($sp)           
        addi $sp, $sp, 4      
        lw $a0, 0($sp)           
        addi $sp, $sp, 4         
        lw $t0, 0($sp)
        addi $sp, $sp, 4
#
jr $ra
        
scan_by_row:
#
        addi $sp, $sp, -4
        sw $t0, 0($sp)
        addi $sp, $sp, -4       
        sw $a0, 0($sp)           
        addi $sp, $sp, -4        
        sw $a1, 0($sp)           
        addi $sp, $sp, -4       
        sw $a2, 0($sp)            
        addi $sp, $sp, -4         
        sw $a3, 0($sp)            
        addi $sp, $sp, -4          
        sw $ra, 0($sp)           
#       
        jal scan_row_line
#
        lw $ra, 0($sp)           
        addi $sp, $sp, 4          
        lw $a3, 0($sp)              
        addi $sp, $sp, 4         
        lw $a2, 0($sp)            
        addi $sp, $sp, 4        
        lw $a1, 0($sp)      
        addi $sp, $sp, 4          
        lw $a0, 0($sp)       
        addi $sp, $sp, 4        
        lw $t0, 0($sp)
        addi $sp, $sp, 4
#
        addi y, y, 1
        beq  y, y_max, all_row_scanned
        j scan_by_row
    all_row_scanned:
        jr $ra

scan_row_line: # add x + 1 each time, when x meet width, change row
#
        addi $sp, $sp, -4
        sw $a0, 0($sp)            
        addi $sp, $sp, -4       
        sw $a1, 0($sp)            
        addi $sp, $sp, -4
        sw $ra, 0($sp) 
#
    jal fetch_color
#       
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        lw $a1, 0($sp)             
        addi $sp, $sp, 4            
        lw $a0, 0($sp)              
        addi $sp, $sp, 4            
#
bne color, 0x000000 row_find_color # if color is not black, go check if the pixel after it is still the same color 
row_find_complete:
addi x, x, 1
beq x, x_max, row_line_scanned 
j scan_row_line
    row_line_scanned:
        jr $ra

row_find_color:
#
    addi $sp, $sp, -4 # save initial pos
    sw $a0, 0($sp)              
    addi $sp, $sp, -4           
    sw $a1, 0($sp)              
    addi $sp, $sp, -4
    sw $ra, 0($sp)
#
    addi $t9, color, 0
    li $t8, 0
    same_color_row_count: # count how many pixel after this pixel has same color
    addi $t8, $t8, 1
    addi x, x, 1
    #
        addi $sp, $sp, -4 # save the changed a0 and a1
        sw $a0, 0($sp)   
        addi $sp, $sp, -4
        sw $a1, 0($sp)
    #
    jal fetch_color
    #
        lw $a1, 0($sp)          # load the changed a0 and a1
        addi $sp, $sp, 4            
        lw $a0, 0($sp)              
        addi $sp, $sp, 4 
    #
    beq color, $t9, same_color_row_count
#       
        lw $ra, 0($sp)
        addi $sp, $sp 4
        lw $a1, 0($sp)             # load initial pos
        addi $sp, $sp, 4            
        lw $a0, 0($sp)              
        addi $sp, $sp, 4            
#
    bge $t8, 4, erase_row
    j row_find_complete
    
erase_row:
#   
    addi $sp, $sp, -4
    sw $a2, 0($sp)              
    addi $sp, $sp, -4           
    sw $a3, 0($sp)              
    addi $sp, $sp, -4
    sw $ra, 0($sp) 
#   
    jal check_virus_row
    add x_max, $t8, $zero
    li $a3, 1
    lw color, black
    jal draw_rect
#
    lw $ra, 0($sp) # load initial pos
    addi $sp, $sp, 4
    lw $a3, 0($sp)             
    addi $sp, $sp, 4            
    lw $a2, 0($sp)              
    addi $sp, $sp, 4  
#
    
jr $ra

check_virus_row:
#
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    addi $sp, $sp, -4
    sw $a1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)
#
        loop_erased_row:

        lw $t0, displayaddress      # $t0 = base address for display
        sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $a0 by 4)
        sll $a1, $a1, 7             # Calculate the Y offset to add to $t0 (multiply $a1 by 128)
        add $t2, $t0, $a1           # Add the Y offset to $t0, store the result in $t2
        add $t2, $t2, $a0           # Add the X offset to $t2 ($t2 now is the location of the place to fetch color)
        
        lw $t4 red_virus_pos
        beq $t2, $t4, red_row_done
        lw $t4 yellow_virus_pos
        beq $t2 $t4, yellow_row_done
        lw $t4 blue_virus_pos
        beq $t2 $t4, blue_row_done
        
        srl $a0, $a0, 2
        srl $a1, $a1, 7
        
        addi $a0, $a0, 1
        beq $a0, $a2 virus_compare_complete_row
        j loop_erased_row
    virus_compare_complete_row:
#   
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $a1, 0($sp) 
    addi $sp, $sp, 4 
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    lw $ra, 0($sp)
    addi $sp, $sp, 4
#
jr $ra

red_row_done:
    jal red_virus_done
    j virus_compare_complete_row
    
yellow_row_done:
    jal yellow_virus_done
    j virus_compare_complete_row
    
blue_row_done:
    jal blue_virus_done
    j virus_compare_complete_row

scan_by_col:
#
        addi $sp, $sp, -4
        sw $t0, 0($sp)
        addi $sp, $sp, -4       
        sw $a0, 0($sp)           
        addi $sp, $sp, -4        
        sw $a1, 0($sp)           
        addi $sp, $sp, -4       
        sw $a2, 0($sp)            
        addi $sp, $sp, -4         
        sw $a3, 0($sp)            
        addi $sp, $sp, -4          
        sw $ra, 0($sp)           
#       
        jal scan_col_line
#
        lw $ra, 0($sp)           
        addi $sp, $sp, 4          
        lw $a3, 0($sp)              
        addi $sp, $sp, 4         
        lw $a2, 0($sp)            
        addi $sp, $sp, 4        
        lw $a1, 0($sp)      
        addi $sp, $sp, 4          
        lw $a0, 0($sp)       
        addi $sp, $sp, 4        
        lw $t0, 0($sp)
        addi $sp, $sp, 4
#
        addi x, x, 1
        beq  x, x_max, all_col_scanned
        j scan_by_col
    all_col_scanned:
        jr $ra


scan_col_line:
#
        addi $sp, $sp, -4
        sw $a0, 0($sp)            
        addi $sp, $sp, -4       
        sw $a1, 0($sp)            
        addi $sp, $sp, -4
        sw $ra, 0($sp) 
#
    jal fetch_color
#       
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        lw $a1, 0($sp)             
        addi $sp, $sp, 4            
        lw $a0, 0($sp)              
        addi $sp, $sp, 4            
#
bne color, 0x000000 col_find_color # if color is not black, go check if the pixel after it is still the same color 
col_find_complete:
addi y, y, 1
beq y, y_max, col_line_scanned 
j scan_col_line
    col_line_scanned:
        jr $ra
    
col_find_color:
#
    addi $sp, $sp, -4 # save initial pos
    sw $a0, 0($sp)              
    addi $sp, $sp, -4           
    sw $a1, 0($sp)              
    addi $sp, $sp, -4
    sw $ra, 0($sp)
#
    addi $t9, color, 0
    li $t8, 0
    same_color_col_count: # count how many pixel after this pixel has same color
    addi $t8, $t8, 1
    addi y, y, 1
    #
        addi $sp, $sp, -4 # save the changed a0 and a1
        sw $a0, 0($sp)   
        addi $sp, $sp, -4
        sw $a1, 0($sp)
    #
    jal fetch_color
    #
        lw $a1, 0($sp)          # load the changed a0 and a1
        addi $sp, $sp, 4            
        lw $a0, 0($sp)              
        addi $sp, $sp, 4 
    #
    beq color, $t9, same_color_col_count
#       
        lw $ra, 0($sp)
        addi $sp, $sp 4
        lw $a1, 0($sp)             # load initial pos
        addi $sp, $sp, 4            
        lw $a0, 0($sp)              
        addi $sp, $sp, 4            
#
    bge $t8, 4, erase_col
    j col_find_complete
    
erase_col:
#   
    addi $sp, $sp, -4
    sw $a2, 0($sp)              
    addi $sp, $sp, -4           
    sw $a3, 0($sp)              
    addi $sp, $sp, -4
    sw $ra, 0($sp) 
#   
    jal check_virus_col
    add y_max, $t8, $zero
    li x_max, 1
    lw color, black
    jal draw_rect
#
    lw $ra, 0($sp) # load initial pos
    addi $sp, $sp, 4
    lw $a3, 0($sp)             
    addi $sp, $sp, 4            
    lw $a2, 0($sp)              
    addi $sp, $sp, 4  
#
    
jr $ra


check_virus_col:
#
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    addi $sp, $sp, -4
    sw $a1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)
#

        loop_erased_col:
        
        lw $t0, displayaddress      # $t0 = base address for display
        sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $a0 by 4)
        sll $a1, $a1, 7             # Calculate the Y offset to add to $t0 (multiply $a1 by 128)
        add $t2, $t0, $a1           # Add the Y offset to $t0, store the result in $t2
        add $t2, $t2, $a0           # Add the X offset to $t2 ($t2 now is the location of the place to fetch color)
        
        lw $t4 red_virus_pos
        beq $t2, $t4, red_col_done
        lw $t4 yellow_virus_pos
        beq $t2 $t4, yellow_col_done
        lw $t4 blue_virus_pos
        beq $t2 $t4, blue_col_done
        
        srl $a0, $a0, 2
        srl $a1, $a1, 7
        
        addi $a1, $a1, 1
        beq $a1, $a3 virus_compare_complete_col
        j loop_erased_col
        
    virus_compare_complete_col:
#   
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $a1, 0($sp) 
    addi $sp, $sp, 4 
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    lw $ra, 0($sp)
    addi $sp, $sp, 4
#
jr $ra

red_col_done:
    jal red_virus_done
    j virus_compare_complete_col
    
yellow_col_done:
    jal yellow_virus_done
    j virus_compare_complete_col
    
blue_col_done:
    jal blue_virus_done
    j virus_compare_complete_col
    
    
keyboard_input:
    lw $a0, 4($t0) # Load second word from keyboard
    beq $a0, 119, respond_to_W
    beq $a0, 97, respond_to_A
    beq $a0, 115, respond_to_S
    beq $a0, 100, respond_to_D
    beq $a0, 0x71, respond_to_Q
    jr $ra

respond_to_S:
    #
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp) 
    #
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    jal fetch_color
    addi $t8, color, 0
    add $a0, x_pill2, $zero
    add $a1, y_pill2, $zero
    jal fetch_color
    addi $t9, color, 0
    # fetch color at initial spot
    
    # remove color from initial pos
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    lw color, black
    jal draw_rect
    add $a0, x_pill2, $zero
    add $a1, y_pill2, $zero
    jal draw_rect
    #
    
    # change coordinate from both coordinates store them in temp are check collision
    addi $s0, x_pill1, 0
    addi $s1, y_pill1, 1
    addi $s2, x_pill2, 0
    addi $s3, y_pill2, 1
    jal collision_checker
    #
    beq $s4, 1, do_nothing # if collision do nothing
    beq $s4, 2, over_S # if nothing done end event S
    addi x_pill1, $s0, 0
    addi y_pill1, $s1, 0
    addi x_pill2, $s2, 0
    addi y_pill2, $s3, 0
    
    # subtract coordinate from both coordinates
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    addi color, $t8, 0
    jal draw_rect
    
    add $a0, x_pill2, $zero
    add $a1, y_pill2, $zero
    add color, $t9, 0
    jal draw_rect
    #
    # load stuff
    lw $ra, 0($sp)
    addi $sp, $sp, 4 
    #
    jr $ra
    
    over_S:
        # load stuff
        #  $a0 = X coordinate for start of the scan 
        #  $a1 = Y coordinate for start of the scan
        #  $a2 = wdith of the rectangle to scan
        #  $a3 = height of the rectangle to scan 
        #  $t0 = the current row being scanned
        jal cancel_checker
        jal draw_pill
        lw $ra, 0($sp)
        addi $sp, $sp, 4 
#
    cancel_finished:
    jr $ra
    
respond_to_A:
    #
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp) 
    #
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    jal fetch_color
    addi $t8, color, 0
    add $a0, x_pill2, $zero
    add $a1, y_pill2, $zero
    jal fetch_color
    addi $t9, color, 0
    # chech color at initial spot
    
    # remove color from initial pos
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    lw color, black
    jal draw_rect
    add $a0, x_pill2, $zero
    add $a1, y_pill2, $zero
    jal draw_rect
    #
    # subtract coordinate from both coordinates
    subi $s0, x_pill1, 1
    addi $s1, y_pill1, 0
    subi $s2, x_pill2, 1
    addi $s3, y_pill2, 0
    jal collision_checker
    #
    beq $s4, 1, do_nothing # if s4 is 1, i.e indicates there is a color on new path
    beq $s4, 2, over_A # if s4 is 2, i.e do_nothing is done, its over
    addi x_pill1, $s0, 0
    addi y_pill1, $s1, 0
    addi x_pill2, $s2, 0
    addi y_pill2, $s3, 0
    
    # 
    #draw the 2 new pos or less
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    addi color, $t8, 0
    jal draw_rect
    
    add $a0, x_pill2, $zero
    add $a1, y_pill2, $zero
    add color, $t9, 0
    jal draw_rect
    over_A:
    # load stuff
    lw $ra, 0($sp)
    addi $sp, $sp, 4 
    #
    jr $ra

    
respond_to_D: # move both x coord 1 by adding 1
    #
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp) 
    #
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    jal fetch_color
    addi $t8, color, 0
    add $a0, x_pill2, $zero
    add $a1, y_pill2, $zero
    jal fetch_color
    addi $t9, color, 0
    # fetch color at initial spot
    
    # remove color from initial pos
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    lw color, black
    jal draw_rect
    add $a0, x_pill2, $zero
    add $a1, y_pill2, $zero
    jal draw_rect
    #
    
    # change coordinate from both coordinates store them in temp are check collision
    addi $s0, x_pill1, 1
    addi $s1, y_pill1, 0
    addi $s2, x_pill2, 1
    addi $s3, y_pill2, 0
    jal collision_checker
    #
    beq $s4, 1, do_nothing
    beq $s4, 2, over_D
    addi x_pill1, $s0, 0
    addi y_pill1, $s1, 0
    addi x_pill2, $s2, 0
    addi y_pill2, $s3, 0
    
    # 
    #draw the 2 new pos or less
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    addi color, $t8, 0
    jal draw_rect
    
    add $a0, x_pill2, $zero
    add $a1, y_pill2, $zero
    add color, $t9, 0
    jal draw_rect
    #
    over_D:
    # beg blah blah donothingA
    # load stuff
    lw $ra, 0($sp)
    addi $sp, $sp, 4 
    #
    jr $ra
    
respond_to_Q:
	li $v0, 10                      # Quit gracefully
	syscall

respond_to_W:
    #
    addi $sp, $sp, -4           # store ra
    sw $ra, 0($sp) 
    #
        #
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    jal fetch_color
    addi $t8, color, 0
    add $a0, x_pill2, $zero
    add $a1, y_pill2, $zero
    jal fetch_color
    addi $t9, color, 0
    # fetch color at initial spot
    
    # remove color from initial pos
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    lw color, black
    jal draw_rect
    add $a0, x_pill2, $zero
    add $a1, y_pill2, $zero
    jal draw_rect
    #
    # beg blah blah donothing
    beq x_pill1, x_pill2, rotate_case_1 # if pill is vertical
    beq y_pill1, y_pill2, rotate_case_2 # if pill is horizontal
    #
    rotation_done:
    #
    lw $ra, 0($sp) # load ra
    addi $sp, $sp, 4 
    #
    jr $ra


rotate_case_1: # dont change pill 2 coordinate at all, change pill 1 y coorinate to pill2 y and and x to pill 2 x + 1 
    
    addi $s0, x_pill2, 1
    addi $s1, y_pill2, 0
    addi $s2, x_pill1, 0
    addi $s3, y_pill2, 0
    
    jal collision_checker
    #
    beq $s4, 1, do_nothing
    beq $s4, 2 rotation_done
    addi x_pill1, $s0, 0
    addi y_pill1, $s1, 0
    addi x_pill2, $s2, 0
    addi y_pill2, $s3, 0
    
    
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    addi color, $t8, 0
    jal draw_rect
    
    add $a0, x_pill2, $zero
    add $a1, y_pill2, $zero
    add color, $t9, 0
    jal draw_rect

    j rotation_done

rotate_case_2: # change pill 2 to x pos of pill 1 and y - 1 pill 1, then switch pill1 and pill 2
    
    addi $s0, x_pill1, 0
    addi $s1, y_pill1, 0
    addi $s2, x_pill1, 0
    addi $s3, y_pill1, 1
    
    jal collision_checker
    #
    beq $s4, 1, do_nothing
    beq $s4, 2 rotation_done
    
    addi x_pill1, $s0, 0
    addi y_pill1, $s1, 0
    addi x_pill2, $s2, 0
    addi y_pill2, $s3, 0
    
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    addi color, $t8, 0
    jal draw_rect
    
    add $a0, x_pill2, $zero
    add $a1, y_pill2, $zero
    add color, $t9, 0
    jal draw_rect
    
    # replace pill1 and pill2
    addi $s0, x_pill2, 0
    addi $s1, y_pill2, 0
    addi x_pill2, x_pill1, 0
    addi, y_pill2, y_pill1, 0
    addi, x_pill1, $s0, 0
    addi, y_pill1, $s1, 0
    
    j rotation_done
    
    
do_nothing:
    #
    addi $sp, $sp, -4           # store ra
    sw $ra, 0($sp) 
    #
    add $a0, x_pill1, $zero
    add $a1, y_pill1, $zero
    addi color, $t8, 0
    jal draw_rect
    
    add $a0, x_pill2, $zero
    add $a1, y_pill2, $zero
    add color, $t9, 0
    jal draw_rect
    # draw the pill back to its initial position
    li $s4, 2  # so it dont loop infinitely
    #
    lw $ra, 0($sp) # load ra
    addi $sp, $sp, 4 
    #
    jr $ra
    
    
    
    # $s0, temo x pos
    # $s1, temp y pos
collision_checker: # check collision by checking if the new position has color or not
    #
    addi $sp, $sp, -4           # store ra
    sw $ra, 0($sp) 
    #
    
    li $s4, 0 
    add $a0, $s0, $zero # check coordinate for pill 1 x
    add $a1, $s1, $zero # check coordinate for pill 1 y
    jal fetch_color
bne color, 0x000000, nope # is pill 1 gonna get drawed on another pixel?
    add $a0, $s2, $zero # check coordinate for pill 2 x
    add $a1, $s3, $zero # check coordinate for pill 2 y
    jal fetch_color
bne color, 0x000000, nope # is pill 1 gonna get drawed on another pixel?

    yep: # if both are black
        #
        lw $ra, 0($sp) # load ra
        addi $sp, $sp, 4 
        #
        jr $ra
    nope: # if at leat
        #
        lw $ra, 0($sp) # load ra
        addi $sp, $sp, 4 
        #
        addi $s4, $s4, 1
        jr $ra
        
        
# $a0, x coord
# $a1, y coord
point_has_color:
    #
    addi $sp, $sp, -4           # store ra
    sw $ra, 0($sp) 
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    addi $sp, $sp, -4
    sw $a1, 0($sp)
    #
jal fetch_color
bne color, 0x000000, pixel_exists
        #
        lw $a1, 0($sp) # load ra
        addi $sp, $sp, 4 
        lw $a0, 0($sp)
        addi $sp, $sp 4
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        #
        jr $ra
    pixel_exists:
        addi $s4, $s4, 1
        #
        lw $a1, 0($sp) # load ra
        addi $sp, $sp, 4 
        lw $a0, 0($sp)
        addi $sp, $sp 4
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        #
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

set_random_location:
#
    addi $sp, $sp, -4       
    sw $a2, 0($sp)
#
    li $v0, 42
    li $a0, 0
    li $a1, 15
    syscall
    addi $a2, $a0, 0
    li $a0, 0
    li $a1, 5
    syscall
    addi $a1, $a0, 25
    addi $a0, $a2, 3
#
    lw $a2, 0($sp)
    addi $sp, $sp, 4
#
    jr $ra
    
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
        # this is the coordinate for the playable area
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
        
    draw_virus_art:
        addi $a0, $zero, 21         # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 10         # Set the Y coordinate for the top left corner of the rectangle (in pixels)  
        addi $a2, $zero, 1      
        addi $a3, $zero, 1
        lw color, red
            jal draw_rect
        addi $a0, $zero, 22         # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 11         # Set the Y coordinate for the top left corner of the rectangle (in pixels)  4
            jal draw_rect
        addi $a0, $zero, 20         # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 11         # Set the Y coordinate for the top left corner of the rectangle (in pixels)  4
            jal draw_rect
            # draw art of red virus
        addi $a0, $zero, 25          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 10         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
        lw color, yellow
            jal draw_rect
        addi $a0, $zero, 24          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 11         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
            jal draw_rect
        addi $a0, $zero, 26          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 11         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
            jal draw_rect   
            # draw are of yellow virus
        addi $a0, $zero, 29          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 10         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
        lw color, blue
            jal draw_rect
        addi $a0, $zero, 28          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 11         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
            jal draw_rect
        addi $a0, $zero, 30          # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 11         # Set the Y coordinate for the top left corner of the rectangle (in pixels)
            jal draw_rect
    draw_mario:
        addi $a0, $zero, 24         
        addi $a1, $zero, 15          
        addi $a2, $zero, 2
        addi $a3, $zero, 1
        lw color, white
            jal draw_rect
        addi $a0, $zero, 23         
        addi $a1, $zero, 16          
        addi $a2, $zero, 5
        addi $a3, $zero, 1
            jal draw_rect
        addi $a0, $zero, 23         
        addi $a1, $zero, 17          
        addi $a2, $zero, 5
        addi $a3, $zero, 5
        lw color, rose
            jal draw_rect
        addi $a0, $zero, 22         
        addi $a1, $zero, 19          
        addi $a2, $zero, 1
        addi $a3, $zero, 2
        lw color, rose
            jal draw_rect
        addi $a0, $zero, 24         
        addi $a1, $zero, 18         
        addi $a2, $zero, 1
        addi $a3, $zero, 1
        lw color, white
            jal draw_rect
        addi $a0, $zero, 26        
        addi $a1, $zero, 18         
        addi $a2, $zero, 1
        addi $a3, $zero, 1
            jal draw_rect
        addi $a0, $zero, 24        
        addi $a1, $zero, 21         
        addi $a2, $zero, 3
        addi $a3, $zero, 1
        lw color, black
            jal draw_rect
        addi $a0, $zero, 23        
        addi $a1, $zero, 17         
        addi $a2, $zero, 1
        addi $a3, $zero, 2
            jal draw_rect
        addi $a0, $zero, 24        
        addi $a1, $zero, 17         
        addi $a2, $zero, 4
        addi $a3, $zero, 1
        lw color, grey
            jal draw_rect
        addi $a0, $zero, 27        
        addi $a1, $zero, 17         
        addi $a2, $zero, 1
        addi $a3, $zero, 4
        lw color, grey
            jal draw_rect       
            
        addi $a0, $zero, 22        
        addi $a1, $zero, 22         
        addi $a2, $zero, 7
        addi $a3, $zero, 5
        lw color, white
            jal draw_rect
        addi $a0, $zero, 24        
        addi $a1, $zero, 22         
        addi $a2, $zero, 3
        addi $a3, $zero, 2
        lw color, grey
            jal draw_rect
        addi $a0, $zero, 25        
        addi $a1, $zero, 24         
        addi $a2, $zero, 1
        addi $a3, $zero, 1
            jal draw_rect      
        addi $a0, $zero, 21        
        addi $a1, $zero, 29         
        addi $a2, $zero, 3
        addi $a3, $zero, 2
        lw color, grey
            jal draw_rect
        addi $a0, $zero, 27        
        addi $a1, $zero, 29         
        addi $a2, $zero, 3
        addi $a3, $zero, 2
            jal draw_rect
        addi $a0, $zero, 22        
        addi $a1, $zero, 28         
        addi $a2, $zero, 2
        addi $a3, $zero, 1
        lw color, white
            jal draw_rect   
        addi $a0, $zero, 27        
        addi $a1, $zero, 28         
        addi $a2, $zero, 2
        addi $a3, $zero, 1
            jal draw_rect       
        addi $a0, $zero, 27        
        addi $a1, $zero, 29         
        addi $a2, $zero, 2
        addi $a3, $zero, 1
        lw color, black
            jal draw_rect
        addi $a0, $zero, 22        
        addi $a1, $zero, 29         
        addi $a2, $zero, 2
        addi $a3, $zero, 1
            jal draw_rect        
        
    draw_score_initial:
        addi $a0, $zero, 26        
        addi $a1, $zero, 3         
        addi $a2, $zero, 3
        addi $a3, $zero, 5
        lw color, white
            jal draw_rect
        addi $a0, $zero, 27        
        addi $a1, $zero, 4        
        addi $a2, $zero, 1
        addi $a3, $zero, 3
        lw color, black
            jal draw_rect    
       addi $a2, $zero, 1      
       addi $a3, $zero, 1
    draw_virus:
        do_red_again:
        li $s4, 0
        jal set_random_location
        jal point_has_color
        bne $s4, 0, do_red_again
        lw color, red
        lw $t0, displayaddress      # $t0 = base address for display
        sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $a0 by 4)
        sll $a1, $a1, 7             # Calculate the Y offset to add to $t0 (multiply $a1 by 128)
        add $t2, $t0, $a1           # Add the Y offset to $t0, store the result in $t2
        add $t2, $t2, $a0           # Add the X offset to $t2 ($t2 now is the location of the place to fetch color)
        sw $t2, red_virus_pos
        srl $a0, $a0, 2
        srl $a1, $a1, 7
            jal draw_rect
        do_yellow_again:
        li $s4, 0
        jal set_random_location
        jal point_has_color
        bne $s4, 0, do_yellow_again # check if random location already has color
        
        lw color, yellow
        lw $t0, displayaddress      # $t0 = base address for display
        sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $a0 by 4)
        sll $a1, $a1, 7             # Calculate the Y offset to add to $t0 (multiply $a1 by 128)
        add $t2, $t0, $a1           # Add the Y offset to $t0, store the result in $t2
        add $t2, $t2, $a0           # Add the X offset to $t2 ($t2 now is the location of the place to fetch color)
        sw $t2, yellow_virus_pos
        srl $a0, $a0, 2
        srl $a1, $a1, 7
            jal draw_rect
            
        do_blue_again:
        li $s4, 0
        jal set_random_location
        jal point_has_color
        bne $s4, 0, do_blue_again # check if random location already has color
        
        lw color, blue
        lw $t0, displayaddress      # $t0 = base address for display
        sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $a0 by 4)
        sll $a1, $a1, 7             # Calculate the Y offset to add to $t0 (multiply $a1 by 128)
        add $t2, $t0, $a1           # Add the Y offset to $t0, store the result in $t2
        add $t2, $t2, $a0           # Add the X offset to $t2 ($t2 now is the location of the place to fetch color)
        sw $t2, blue_virus_pos
        srl $a0, $a0, 2
        srl $a1, $a1, 7
            jal draw_rect
            
#
        lw $ra, 0($sp)
        addi $sp, $sp, 4
#
        jr $ra
        
score_up:
    addi score, score, 1
    beq score, 2, draw_one
    beq score, 3, draw_two
    beq score, 4, draw_three
    draw_complete:
    jr $ra
    
draw_one:
#
        addi $sp, $sp, -4
        sw $ra, 0($sp)
#
    addi $a0, $zero, 26        
    addi $a1, $zero, 3         
    addi $a2, $zero, 3
    addi $a3, $zero, 5
    lw color, black
        jal draw_rect
    addi $a0, $zero, 27        
    addi $a1, $zero, 3        
    addi $a2, $zero, 1
    addi $a3, $zero, 5
    lw color, white
            jal draw_rect  
#
        lw $ra, 0($sp)
        addi $sp, $sp, 4
#
    j draw_complete

draw_two: 
#
        addi $sp, $sp, -4
        sw $ra, 0($sp)
#
    addi $a0, $zero, 26        
    addi $a1, $zero, 3         
    addi $a2, $zero, 3
    addi $a3, $zero, 5
    lw color, black
        jal draw_rect
    addi $a0, $zero, 26        
    addi $a1, $zero, 3        
    addi $a2, $zero, 3
    addi $a3, $zero, 1
    lw color, white
            jal draw_rect  
    addi $a0, $zero, 28        
    addi $a1, $zero, 3        
    addi $a2, $zero, 1
    addi $a3, $zero, 3
            jal draw_rect  
    addi $a0, $zero, 26        
    addi $a1, $zero, 5        
    addi $a2, $zero, 3
    addi $a3, $zero, 1
            jal draw_rect  
    addi $a0, $zero, 26        
    addi $a1, $zero, 5        
    addi $a2, $zero, 1
    addi $a3, $zero, 3
    lw color, white
            jal draw_rect  
    addi $a0, $zero, 26        
    addi $a1, $zero, 7        
    addi $a2, $zero, 3
    addi $a3, $zero, 1
    lw color, white
            jal draw_rect  
#
        lw $ra, 0($sp)
        addi $sp, $sp, 4
#
    j draw_complete

draw_three:
#
        addi $sp, $sp, -4
        sw $ra, 0($sp)
#
    addi $a0, $zero, 26        
    addi $a1, $zero, 3         
    addi $a2, $zero, 3
    addi $a3, $zero, 5
    lw color, black
        jal draw_rect
    addi $a0, $zero, 28        
    addi $a1, $zero, 3        
    addi $a2, $zero, 1
    addi $a3, $zero, 5
    lw color, white
            jal draw_rect  
    addi $a0, $zero, 26        
    addi $a1, $zero, 7        
    addi $a2, $zero, 3
    addi $a3, $zero, 1
    lw color, white
            jal draw_rect  
    addi $a0, $zero, 26        
    addi $a1, $zero, 5        
    addi $a2, $zero, 3
    addi $a3, $zero, 1
            jal draw_rect  
    addi $a0, $zero, 26        
    addi $a1, $zero, 3        
    addi $a2, $zero, 3
    addi $a3, $zero, 1
    lw color, white 
            jal draw_rect
#
        lw $ra, 0($sp)
        addi $sp, $sp, 4
#
    j draw_complete


red_virus_done:
#
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        addi $sp, $sp, -4  
        sw $a0, 0($sp)            
        addi $sp, $sp, -4     
        sw $a1, 0($sp)            
        addi $sp, $sp, -4         
        sw $a2, 0($sp)     
        addi $sp, $sp, -4
        sw $a3, 0($sp) 
#
        addi $a0, $zero, 21         # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 10         # Set the Y coordinate for the top left corner of the rectangle (in pixels)  
        addi $a2, $zero, 1
        addi $a3, $zero, 1
        lw color, black
            jal draw_rect
        addi $a0, $zero, 22         # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 11         # Set the Y coordinate for the top left corner of the rectangle (in pixels)  4
        addi $a2, $zero, 1
        addi $a3, $zero, 1
            jal draw_rect
        addi $a0, $zero, 20         # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 11         # Set the Y coordinate for the top left corner of the rectangle (in pixels)  4
        addi $a2, $zero, 1
        addi $a3, $zero, 1
            jal draw_rect
        jal score_up
#
        lw $a3, 0($sp)
        addi $sp, $sp, 4
        lw $a2, 0($sp)
        addi $sp, $sp, 4
        lw $a1, 0($sp)
        addi $sp, $sp, 4
        lw $a0, 0($sp)
        addi $sp, $sp, 4
        lw $ra, 0($sp)
        addi $sp, $sp, 4
#
        jr $ra

yellow_virus_done:
#
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        addi $sp, $sp, -4  
        sw $a0, 0($sp)            
        addi $sp, $sp, -4     
        sw $a1, 0($sp)            
        addi $sp, $sp, -4         
        sw $a2, 0($sp)     
        addi $sp, $sp, -4
        sw $a3, 0($sp) 
#
        addi $a0, $zero, 25         # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 10         # Set the Y coordinate for the top left corner of the rectangle (in pixels)  
        addi $a2, $zero, 1
        addi $a3, $zero, 1
        lw color, black
            jal draw_rect
        addi $a0, $zero, 24         # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 11         # Set the Y coordinate for the top left corner of the rectangle (in pixels)  4
        addi $a2, $zero, 1
        addi $a3, $zero, 1
            jal draw_rect
        addi $a0, $zero, 26         # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 11         # Set the Y coordinate for the top left corner of the rectangle (in pixels)  4
        addi $a2, $zero, 1
        addi $a3, $zero, 1
            jal draw_rect
        jal score_up
#
        lw $a3, 0($sp)
        addi $sp, $sp, 4
        lw $a2, 0($sp)
        addi $sp, $sp, 4
        lw $a1, 0($sp)
        addi $sp, $sp, 4
        lw $a0, 0($sp)
        addi $sp, $sp, 4
        lw $ra, 0($sp)
        addi $sp, $sp, 4
#
        jr $ra

blue_virus_done:
#
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        addi $sp, $sp, -4  
        sw $a0, 0($sp)            
        addi $sp, $sp, -4     
        sw $a1, 0($sp)            
        addi $sp, $sp, -4         
        sw $a2, 0($sp)     
        addi $sp, $sp, -4
        sw $a3, 0($sp) 
#
        addi $a0, $zero, 29         # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 10         # Set the Y coordinate for the top left corner of the rectangle (in pixels)  
        addi $a2, $zero, 1
        addi $a3, $zero, 1
        lw color, black
            jal draw_rect
        addi $a0, $zero, 28         # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 11         # Set the Y coordinate for the top left corner of the rectangle (in pixels)  4
        addi $a2, $zero, 1
        addi $a3, $zero, 1
            jal draw_rect
        addi $a0, $zero, 30         # Set the X coordinate for the top left corner of the rectangle (in pixels)
        addi $a1, $zero, 11         # Set the Y coordinate for the top left corner of the rectangle (in pixels)  4
        addi $a2, $zero, 1
        addi $a3, $zero, 1
            jal draw_rect
        jal score_up
#
        lw $a3, 0($sp)
        addi $sp, $sp, 4
        lw $a2, 0($sp)
        addi $sp, $sp, 4
        lw $a1, 0($sp)
        addi $sp, $sp, 4
        lw $a0, 0($sp)
        addi $sp, $sp, 4
        lw $ra, 0($sp)
        addi $sp, $sp, 4
#
        jr $ra
