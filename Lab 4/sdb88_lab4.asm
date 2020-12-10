#Sushruti Bansod
#sdb88

.eqv DISPLAY_CTRL  0xFFFF0000
.eqv DISPLAY_KEYS  0xFFFF0004
.eqv DISPLAY_BASE  0xFFFF0008
.eqv COLOR_BLACK   0
.eqv COLOR_RED     1
.eqv COLOR_ORANGE  2
.eqv COLOR_YELLOW  3
.eqv COLOR_GREEN   4
.eqv COLOR_BLUE    5
.eqv COLOR_MAGENTA 6
.eqv COLOR_WHITE   7

.globl main
main:
    # clear display
    sw  zero, DISPLAY_CTRL

    # vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

    	li	a0,5
    	li	a1, 5
    	li	a2, 10
    	li	a3, 3
	jal draw_rectangle
	
	
	li	a0,0
    	li	a1, 10
    	li	a2, 64
    	li	a3, 5
	jal draw_rectangle
	
	
	li	a0,54
    	li	a1, 54
    	li	a2, 10
    	li	a3, 10
	jal draw_rectangle

    # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    # update display
    sw  zero, DISPLAY_CTRL

    # exit()
    li  v0, 10
    syscall

# ----------------------------------------------------------------------------------

# draw_horiz_line(x: a0, y: a1, length: a2, color: a3)
draw_horiz_line:
    mul a1, a1, 64 # y *= 64
    li  t0, DISPLAY_BASE
    add t0, t0, a1
    add t0, t0, a0 # t0 = DISPLAY_BASE + y*64 + x

    # decrement length until it reaches 0
    # for(; a2 > 0; a2--) {
_draw_horiz_line_loop:
    ble a2, 0, _draw_horiz_line_break

        sb a3, (t0)   # *t0 = color
        add t0, t0, 1 # t0++ (move to next pixel)

    # }
    sub a2, a2, 1
    j _draw_horiz_line_loop

_draw_horiz_line_break:
    jr  ra

# ----------------------------------------------------------------------------------

draw_rectangle:
	#5 pushes
	push ra
	push s0
	push s1
	push s2
	push s3
#draw_rectangle(x: a0, y: a1, length: a2, HEIGHT: a3)
#we know the color is red (1)
#so we have to copy a3 into a diff variable and then call horizline
	
	#4 moves
	move		s0, a0	#in s0 is the starting point x
	move		s1, a1	#in s1 is the starting point y
	move		s2, a2	#in s2 is the LEngth of each line
	move		s3, a3	#in s3 in the HEIGHT of the rectangle
	
	
	draw_rect_loop:
		move		a0, s0
		move		a1, s1
		move		a2, s2
		li		a3, COLOR_RED
	
  		# draw_horiz_line(5, 5, 10, COLOR_RED)
    		jal draw_horiz_line
    		
    		add	s1, s1, 1		#y++
    		sub	s3, s3, 1		#height--
    		
    		blt		s3, 0, draw_rect_loop_exit
    		j draw_rect_loop
    	
    	draw_rect_loop_exit:
    	#5 more pushes
	pop s3
	pop s2
	pop s1
	pop s0
	pop ra	
    jr  ra
