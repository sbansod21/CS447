#sdb88
#Sushruti Bansod

.include "macros.asm"

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

.data
.eqv VOLUME 100
.eqv LENGTH 3000


instrument: 	.word 0

recorded_notes: .byte  -1:1024

recorded_times: .word 250:1024

# maps from ASCII to MIDI note numbers, or -1 if invalid.
key_to_note_table: .byte
	-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
	-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
	-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 60 -1 -1 -1
	75 -1 61 63 -1 66 68 70 -1 73 -1 -1 -1 -1 -1 -1
	-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
	-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
	-1 -1 55 52 51 64 -1 54 56 72 58 -1 -1 59 57 74
	76 60 65 49 67 71 53 62 50 69 48 -1 -1 -1 -1 -1

demo_notes: .byte
	67 67 64 67 69 67 64 64 62 64 62
	67 67 64 67 69 67 64 62 62 64 62 60
	60 60 64 67 72 69 69 72 69 67
	67 67 64 67 69 67 64 62 64 65 64 62 60
	-1

demo_times: .word
	250 250 250 250 250 250 500 250 750 250 750
	250 250 250 250 250 250 500 375 125 250 250 1000
	375 125 250 250 1000 375 125 250 250 1000
	250 250 250 250 250 250 500 250 125 125 250 250 1000
	0


.text
.globl main
main:

	 _main_loop: #declare the begining and the end first and then the code

		println_str " "
		println_str "What would you like to do? "
		print_str "[k]eyboard, [d]emo, [r]ecord, [p]lay, [q]uit:"

		#reads the input
		li		v0, 12
		syscall
		
		move		t0, v0

		#checks what the input is
		beq 	t0, 'q', _case_quit #if user presses Q then quit
		beq 	t0, 'k', _case_keyboard #keyboard
		beq 	t0, 'd', _case_demo #Demo
		beq 	t0, 'r', _case_record #record
		beq 	t0, 'p', _case_play #play
		
		println_str "\nHUh?!? I dont get it!"
		j _main_loop				# jump t _main_loop
		

	_case_keyboard:
		jal keyboard
		j _main_loop
	
	_case_demo:
		jal demo
		j _main_loop
	
	_case_play:
		 jal play
		 j _main_loop
	
	_case_record:
		jal record
		 j _main_loop
	
	_case_quit:
		
		println_str " "
		println_str "\nGoodbye!"
		li	v0, 10
		syscall
# -----------------------------------------------END OF MAIN----------------------------------------------------#

# -----------------------------------------------KEYBOARD-------------------------------------------------------#
keyboard:			
	push ra
		println_str "\nPlay notes with letters and numbers, '`' to change instrument, ENTER to stop."
		print_str"Current Instrument:"
		lw	t0, instrument
		add	a0, t0, 1
		print_int a0
		println_str "\n"
		li	t0, 0
	keyboard_loop:

		li	a0, 0
		li	v0, 12	#reads a char from the user, NO need to press enter AFTER
		syscall
		
		move a0, v0	#moved the read CHAR into a0 so we can look and use it as an ARGUMENT
		
		beq a0, '`', _change_instrument		#goes to the change instrument method
		beq	a0, '\n', keyboard_loop_exit	#exits the loop like a good person

		#since i will need translate note for other methods, imma make it a func
		jal translate_note
		move a0, v0
		beq a0, -1, keyboard_loop

		jal play_note			#goes to the play note method with the char that we read in a0 as an ARGUMENT	
		j keyboard_loop			#loops forever until the user presses enter
		
		# -----------------------------------------------
 	 	_change_instrument:
  
 			println_str "\n"
 			print_str "Enter instrument number (1..128):"
  		
  			read_int a0		#reads the int that the user wants to change as their instrument
  	
	  		sub	v0, v0, 1		#subtracts 1 from it for god knows what reason
	
 		 	blt	v0, 0, _change_instrument		#if the number that the user entered is less than 0 
 			bgt	v0, 128, _change_instrument		#or greater than 128 then calls the same function so they can enter a diff number
  	
  			sw v0, instrument 					#stores that num into memory for the instrument
 			j   keyboard_loop
 		# -----------------------------------------------
	keyboard_loop_exit:
		pop ra
		jr ra	
 
#-----------------------------------------------END OF KEYBOARD----------------------------------------------------#
 
# int translate_note(int ascii: a0)
	translate_note:
		#a0 has the ascii note in it 
		blt	a0, 0, _invalid_ascii
		bgt	a0, 127, _invalid_ascii
	
		# if(a0 >= 0 && a0 <= 127)
		la	t0, key_to_note_table
		add	a0, a0, t0	#A + bi
		lb  v0, (a0)
		j _translate_note_exit

	_invalid_ascii: # else!
 		println_str "Invalid Input"
 		li v0, -1

	_translate_note_exit:
		jr ra
 
#-----------------------------------------------START OF DEMO----------------------------------------------------#
demo:
	push ra
	println_str " "
	println_str "\nThis is a DEMO"
	
	la	a0, demo_notes
	la	a1, demo_times
	jal	play_song
	
	pop ra
	jr ra
#-----------------------------------------------END OF DEMO------------------------------------------------------#

 
#-----------------------------------------------START OF RECORD----------------------------------------------------#
record:				
	push ra
	push s0
	push s1
	push s2

	la	s0, recorded_notes #notes
	la	s1, recorded_times #pauses
	
	println_str "\nPlay when ready. Hit ENTER to finish"
	li	s2, 0
	
	record_loop:
		li	a0, 0
		li	v0, 12	#reads a char from the user, NO need to press enter AFTER
		syscall
		
		move a0, v0	#moved the read CHAR into a0 so we can look and use it as an ARGUMENT
	
		beq	a0, '\n', record_loop_exit	#exits the loop like a good person

		jal translate_note
		move a0, v0
		beq a0, -1, record_loop

		add	t1, s0, s2
		sb	a0, (t1)
		jal play_note			#goes to the play note method with the char that we read in a0 as an ARGUMENT	


		#saves the TIME
		li	v0,30
		syscall   #in v0 is the time when the note is played so like lets store that shit

		mul	t2, s2, 4		# index times 4
		add	t2, t2, s1		# that plus the address
		sw	v0, (t2)
		#------

		add s2, s2, 1
		j record_loop			#loops forever until the user presses enter
		
	record_loop_exit:
		li	t2, -1
		add	t1, s0, s2
		sb t2, (t1)

		li	v0,30
		syscall   #in v0 is the time when the note is played so like lets store that shit

		mul	t2, s2, 4		# index times 4
		add	t2, t2, s1		# that plus the address
		sw	v0, (t2)

		li	s2, 0 #loop variable
		
		times_loop:
			add	t3, s0, s2	#calculates the note
			lb	t3, (t3)
			beq t3, -1, times_loop_exit #while(note!= -1)
		
			# now here is where you go back to the beginnings of the arrays
			# and while note != -1, times[i] = times[i + 1] - times[i]

			#times[i+1]
			add	s3, s2, 1		#i + 1
			mul	t4, s3, 4		# index times 4
			add	t4, t4, s1		# that plus the address
			lw	t4, (t4)

			#times[i]
			mul	t5, s2, 4		# index times 4
			add	t5, t5, s1		# that plus the address
			lw	t5, (t5)

			sub t6, t4, t5	 #times[i + 1] - times[i]
			
			mul	t7, s2, 4		# index times 4
			add	t7, t7, s1		# that plus the address
			sw  t6, (t7)

			add	s2, s2, 1	#i++
			j times_loop
		times_loop_exit:


			pop s2
			pop s1
			pop	s0
			pop ra
			jr ra	
 j _main_loop

#-----------------------------------------------END OF RECORD----------------------------------------------------#

 
 
#-----------------------------------------------START OF PLAY----------------------------------------------------#
play:				
	println_str " "
	println_str "\nPlaying.."

	la	a0, recorded_notes #notes
	la	a1, recorded_times #pauses
	
	jal play_song
	
 j _main_loop
#-----------------------------------------------END OF PLAY----------------------------------------------------#



# -----------------------------------------------PLAY NOTE
play_note:
	#a0 is the note that I wanna play!
	
	li a1, LENGTH# 2 second
	li a3, VOLUME # normal volume
	lw a2, instrument # grand piano
	li v0, 31
	syscall
	
	jr ra
 # -----------------------------------------------PLAY NOTE
 
 
 
# -----------------------------------------------PLAY SONG
play_song:
 	#a0 has ADDRESS of the notes array 
	 #a1 has the ADDRESS of the times array.
 	push ra
 	push s0
 	push s1
	push s2
	push s3
 	#copy into s registers
 	move		s0, a0 #notes
 	move		s1, a1 #pauses
 	li	t0, 0
		
		play_song_loop:
			li a0, 0
			
			add	t1, t0, s0	#A + bi
	 		lb	a0, (t1)
			beq	a0, -1, end_play_song_loop
			jal play_note
			
			li a0, 0		#the value needs to be in a0, so im clean it
			mul t2, t0, 4
			add	t2, t2, s1	#A + bi
			lw	a0, (t2)
			
			li	v0, 32
			syscall

	 		add	t0, t0, 1
	 		j	play_song_loop
		end_play_song_loop:
	pop s3
	pop s2
	pop s1
	pop s0
	pop ra
	jr ra
# -----------------------------------------------PLAY SONG

