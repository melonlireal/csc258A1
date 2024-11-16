draw_rect:
    add $t0, $zero, $zero # creates a variable that contains the raw we already draw
    rows_start:# for each row call draw line
        jal draw_line 
        addi $a2, $a2, 128# move to next line
        addi $t0, $t0, 1# increase row counter
        #if all line draw
            beq $t0, $a3, rows_end# if all line draw, break loop
        #else get back to the start
            j rows_start
    rows_end:
        #bruh


draw_line: