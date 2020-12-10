 # Sushruti Bansod
 #SDB88
  .include "lab5_include.asm"
 .data

 dot_x:     .word 32,40,20
 dot_y:     .word 32,20,50

 other_dot1:       .word 1
 other_dot2:        .word 2
 current_dot:     .word 0
 frame_counter:    .word 0
 last_frame_time:  .word 0
 .text

 .globl main
 main:   ###############################################  START OF MAIN  #####################################################
     # here is where you would put any initialization stuff that
     # needs to happen *before* the game begins.
 _main_loop:

     #check_input()
     jal check_input
    
     jal draw_dots
     # display_update_and_clear()
     jal display_update_and_clear
     
     # wait_for_next_frame(16)
     jal wait_for_next_frame

     
     j _main_loop
    #################################################  END OF MAIN  ###############################################################


check_input: ######################################  START OF CHECK INPUT  ###################################################
push ra
push s0

  jal input_get_keys #vo has the KEY

_check_B:
    and t0, v0, KEY_B
    beq t0, 0, _check_left

    lw  t0, current_dot
    add t0, t0, 1
    sw  t0, current_dot
  
_check_left: 
    lw s0, current_dot
  and t0, v0, KEY_L  #left pressed
  beq t0, 0, _check_right
  
  la t1, dot_x
  mul t2, s0, 4
  add t1, t1, t2
  lw t3, (t1)
  sub t3, t3, 1
  sw t3, (t1)

_check_right:
lw s0, current_dot
  and t0, v0, KEY_R  #right pressed
  beq t0, 0, _check_down
 
  la t1, dot_x
  mul t2, s0, 4
  add t1, t1, t2
  lw t3, (t1)
  add t3, t3, 1
  sw t3, (t1)

_check_down:
lw s0, current_dot
  and t0, v0, KEY_D  #down pressed
  beq t0, 0, _check_up

  la t1, dot_y
  mul t2, s0, 4
  add t1, t1, t2
  lw t3, (t1)
  add t3, t3, 1
  sw t3, (t1) 

_check_up:
lw s0, current_dot
  and t0, v0, KEY_U  #up pressed
  beq t0, 0, end_check_input
   
  la t1, dot_y
  mul t2, s0, 4
  add t1, t1, t2
  lw t3, (t1)
  sub t3, t3, 1
  sw t3, (t1) 


end_check_input:

lw  t1, dot_x
lw  t2, dot_y

and   t1, t1, 63
and   t2, t2, 63

sw  t1, dot_x
sw  t2, dot_y

pop s0
pop ra
jr ra
###########################################################  END OF CHECK INPUT  #############################################

draw_dots:  ######################################  START OF DRAW DOT  ########################################################
push ra
push s0
push s1
#a0 has dotx
#a1 has doty
#a2 has the color

lw  s0, current_dot  #this is the index
li  s1, 0

    draw_dots_loop:
        beq s1, 3, end_draw
        
        la  t0, dot_x
        mul t1, s1, 4
        add t0, t0, t1
        lw  a0, (t0)

        la  t0, dot_y
        mul t1, s1, 4
        add t0, t0, t1
        lw  a1, (t0)

        beq s0, s1, set_color
        
        li a2, COLOR_WHITE
        jal display_set_pixel

        add s1, s1, 1
        j draw_dots_loop
        
        set_color:
        li a2, COLOR_BLUE
        jal display_set_pixel

        add s1, s1, 1
        j draw_dots_loop
    end_draw:
pop s1
pop s0
pop ra
jr ra
###########################################################  END OF DRAW DOT  ################################################