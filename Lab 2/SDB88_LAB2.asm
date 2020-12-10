# Sushruti Bansod	
# SDB88


.eqv INPUT_SIZE 3 #so I can use this 


# THIS MACRO WILL OVERWRITE WHATEVER IS IN THE a0 AND v0 REGISTERS.
.macro print_str %str
	.data #this means we are declarin Variables
	
		print_str_message: .asciiz %str
		
	.text #this means we are writing code
		la	a0, print_str_message
		li	v0, 4
		syscall
.end_macro
		
.data #this means we are declarin Variables
	
	display: .word 0
	input: .space INPUT_SIZE

.text #this means we are writing code
.globl main
main:
	
	 print_str "Hello!\n"
	print_str "Welcome to CALCY THE CALCULATOR!/n"
	
	    _main_loop: #declare the begining and the end first and then the code
	
		lw		a0, display
		li		v0, 1
		syscall
		
		print_str "\nOperation (=,+,-,*,/,c,q): "
		
		
		la 		a0, input 
		li 		a1, INPUT_SIZE
		li		v0, 8
		syscall
		
		lb 		t0, input
#so we need to save the value in the variable display, and also use it to DISPLAY
		
		beq 	t0, 'q', _quit
		
		beq 	t0, 'c', _clear
		
		print_str "Value:"
		li		v0, 5
		syscall
		
		move		s0, v0
		
		
		beq	t0, '+', _add
		
		beq	t0, '-', _sub
		
		beq	t0, '*', _mul
		
		beq	t0, '/', _divide
		
		beq t0, '=', _equals
		
		
		print_str "\nHUh?!? "
		
     	 j _main_loop
     	 
     	 ###############################methods################################
 
 _quit:
 
 print_str "\n GoodBye! "
     li v0, 10
     syscall
		

_clear:

	li	t0, 0
	sw	display, t0

	j _main_loop

_add:
	#s0 has the num they want to add
	lw		t0, display
	add		t1, t0, s0
	
	sw		t1, display
	j _main_loop
_sub:

	lw		t0, display
	sub		t1, t0, s0
	
	sw		t1, display

	j _main_loop
_mul:

	lw		t0, display
	mul		t1, t0, s0
	
	sw		t1, display

	j _main_loop
_divide:
	
	beq		s0, 0, _divzero
	
	lw		t0, display
	div		t1, t0, s0
	
	sw		t1, display

	j _main_loop

_equals:
#i dont understnad exactly what the equals method is supposed to do

		sw	s0, display
		j	_main_loop


_divzero:

print_str "CANT DIVIDE BY ZERO \n"

j _main_loop

