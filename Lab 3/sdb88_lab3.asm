#sdb88
#Sushruti Bansod

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


# THIS MACRO WILL OVERWRITE WHATEVER IS IN THE a0 AND v0 REGISTERS.
.macro print_str %str
	.data #this means we are declarin Variables
	
		print_str_message: .asciiz %str
		
	.text #this means we are writing code
		la	a0, print_str_message
		li	v0, 4
		syscall
.end_macro

.globl main
main:

	li t0, 0x06050401
	sw t0, DISPLAY_BASE
	#sw zero, DISPLAY_CTRL
	
	jal draw_horiz_line
	
	sw zero, DISPLAY_CTRL
	
	jal draw_vert_line
	
	sw	zero, DISPLAY_CTRL
	
	
	li	a0, 30 # x1
 	li	a1, 15 # y1
 	li	a2, 50 # x2
 	li	a3, 25 # y2
	 jal draw_rectangle
	
	sw	zero, DISPLAY_CTRL
	
	# exit
	li v0, 10
	syscall


# -----------------------------------------
draw_horiz_line:

	li	t0, 0	# int i
	
	horizline_loop:
	beq	t0, 10, end_horizline_loop #i < 10

	li	t1, DISPLAY_BASE
	add	t1, t1,10
	add	t1, t1, t0
	
	li	t2, COLOR_BLUE
	sb	t2, (t1)
	
	add	t0, t0, 1
	j horizline_loop
	
	end_horizline_loop:
     jr ra
# -----------------------------------------

# -----------------------------------------
draw_vert_line:

	li	t0, 0	# int i
	li	t1, DISPLAY_BASE
	add	t1, t1, 20
	
	vertline_loop:
	beq	t0, 15, end_vertline_loop #i < 10
	
	li	t2, COLOR_ORANGE
	sb	t2, (t1)
	add	t1, t1, 64
	
	add	t0, t0, 1
	j vertline_loop
	
	end_vertline_loop:

	jr ra
# -----------------------------------------

# -----------------------------------------
draw_rectangle:

	#li	a0, 30 # x1
 	#li	a1, 15 # y1
 	#li	a2, 50 # x2
 	#li	a3, 25 # y2
 
 	li	t0, DISPLAY_BASE				
	mul	t1, a0, a2
	add	t0, t1, t0 			#In t0 is the display thing
	
	move 	s0,a0
	move		s2, a2
	
	sub	s1, a2, a0
	
 	y_loop:
 		beq	a3, a1, end_y_loop 	
	
		move 	a0,s0
		move		a2, s2
 		x_loop:
 			beq	a2, a0, end_x_loop 
 		
 			add	t0, t0, 1
 			li	t1, COLOR_WHITE
			sb	t1, (t0)
 		
 			add	a0, a0, 1	#i++
 			j	x_loop
 		end_x_loop:
 			
 			sub	t0, t0, s1
 			sb	t1, (t0)
 			
 			add	t0, t0, 64
 			add	a1, a1, 1	#i++
 		j	y_loop
 	end_y_loop:
	jr ra
# -----------------------------------------











