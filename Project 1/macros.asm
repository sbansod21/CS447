
.macro print_str %str
	.data
	print_str_message: .asciiz %str
	.text
	la a0, print_str_message
	li v0, 4
	syscall
.end_macro

.macro println_str %str
	print_str %str
	li a0, '\n'
	li v0, 11
	syscall
.end_macro

.macro read_int %reg
	li v0, 5
	syscall
	move %reg, v0
.end_macro

.macro print_int %reg
	.text
	move a0, %reg
	li v0, 1
	syscall
.end_macro





