.include "constants.asm"
.include "macros.asm"

# =================================================================================================
# Rocks
# =================================================================================================

.globl rocks_count
rocks_count:
enter
	la t0, objects
	li t1, 0
	li v0, 0

	_rocks_count_loop:
		lw t2, Object_type(t0)
		beq t2, TYPE_ROCK_L, _rocks_count_yes
		beq t2, TYPE_ROCK_M, _rocks_count_yes
		bne t2, TYPE_ROCK_S, _rocks_count_continue
		_rocks_count_yes:
			inc v0
	_rocks_count_continue:
	add t0, t0, Object_sizeof
	inc t1
	blt t1, MAX_OBJECTS, _rocks_count_loop
leave

# ------------------------------------------------------------------------------

# void rocks_init(int num_rocks)
.globl rocks_init
rocks_init:
enter s0, s1, s2, s3
 	li  s0, 0
	move s1, a0
	
	#for(int i = 0, i < a0, i++)
	init_loop:
    	bge s0, s1, init_break
	
		#(random(0x2000) + 0x3000) % 0x4000
		
		#getting a random x coordinate
		li a0,0x2000
		jal random
		#in v0 is the random thing
		add t0, v0, 0x3000
		rem t0, t0, 0x4000
		move s2, t0  #this is the x coordinate 

		#getting a random y coordinate
		li a0,0x2000
		jal random
		#in v0 is the random thing
		add t0, v0, 0x3000
		rem t0, t0, 0x4000
		
		move a1, t0  #this is the y coordinate 
		move a0, s2
		li a2, TYPE_ROCK_L
		jal rock_new

		add s0, s0, 1
		j init_loop
	init_break:
leave s0, s1, s2, s3

# ------------------------------------------------------------------------------

# void rock_new(x, y, type)
rock_new:
enter s0, s1, s2, s3
	move s0, a0
    move s1, a1
    move s2, a2
	move a0, a2

	beq a2, TYPE_ROCK_L, _large_rock
	
	beq a2, TYPE_ROCK_M, _med_rock

	beq a2, TYPE_ROCK_S, _smol_rock
	#Imma put nothing here cuz it will always be L or M or S
	_large_rock:
		jal Object_new
		move s3, v0
		beq v0, 0, _end_new_rock
		
		li t0, ROCK_L_HW
		li t1, ROCK_L_HH
		
		li t3, ROCK_VEL
		
		j _create_rock
	_med_rock:
		jal Object_new
		move s3, v0
		beq v0, 0, _end_new_rock

		li t0, ROCK_M_HW
		li t1, ROCK_M_HH
		
		li t3, ROCK_VEL
		mul t3, t3, 4
		j _create_rock
	_smol_rock:
		jal Object_new
		move s3, v0
		beq v0, 0, _end_new_rock

		li t0, ROCK_S_HW
		li t1, ROCK_S_HH
		
		li t3, ROCK_VEL
		mul t3, t3, 12
		
		j _create_rock
	_create_rock:

		sw t0, Object_hw(s3)
		sw t1, Object_hh(s3)

	#we want to get a rand angle for a0 so lets get that
	li a0, 360
	jal random
	move a1, v0
	move a0, t3
    jal to_cartesian

    #inside v0 is the velocity 
    sw v0, Object_vx(s3)
    sw v1, Object_vy(s3)

	sw s0, Object_x(s3)
    sw s1, Object_y(s3)


_end_new_rock:
leave s0, s1, s2, s3

# ------------------------------------------------------------------------------

.globl rock_update
rock_update:
enter s0
 	move s0, a0
	 jal Object_accumulate_velocity

    move a0, s0
	jal Object_wrap_position

	move a0, s0
	jal rock_collide_with_bullets
	#should I be jal-ing here or just jumping

leave s0

# ------------------------------------------------------------------------------

rock_collide_with_bullets:
enter s0, s1, s2, s3
#a0 has the rock
	move s2, a0
	la s0, objects
	li s1, 0

	_colide_loop:
		move a0, s0
		
		lw t0, Object_type(s0)
		li t1, TYPE_BULLET

		bne t0, t1, _next_bullet #if the object that is coliding is a bullet
			move a0, s2
			lw a1, Object_x(s0)
			lw a2, Object_y(s0)

			jal Object_contains_point

			beq v0, 0, _next_bullet
				jal rock_get_hit
				move a0, s0
				jal Object_delete
				j end_collide_loop	

	_next_bullet:
	add s0, s0, Object_sizeof
	inc s1
	blt s1, MAX_OBJECTS, _colide_loop

	end_collide_loop:
leave s0, s1, s2, s3


# ------------------------------------------------------------------------------

rock_get_hit:
enter s0
	move s0, a0
	lw t0, Object_type(s0)

	beq t0, TYPE_ROCK_L, _large_hit
	
	beq t0, TYPE_ROCK_M, _medium_hit

	j _end_get_hit

	_large_hit:
		
		lw a0, Object_x(s0)
		lw a1, Object_y(s0)
		li a2, TYPE_ROCK_M
		jal rock_new
		lw a0, Object_x(s0)
		lw a1, Object_y(s0)
		li a2, TYPE_ROCK_M
		jal rock_new
		j _end_get_hit

	_medium_hit:
		
		lw a0, Object_x(s0)
		lw a1, Object_y(s0)
		li a2, TYPE_ROCK_S
		jal rock_new
		lw a0, Object_x(s0)
		lw a1, Object_y(s0)
		li a2, TYPE_ROCK_S
		jal rock_new

_end_get_hit:
	lw a0, Object_x(s0)
	lw a1, Object_y(s0)
	jal explosion_new
	
	move a0, s0
	jal Object_delete
leave s0

# ------------------------------------------------------------------------------

.globl rock_collide_l
rock_collide_l:
enter
	jal rock_get_hit

	li a0, 3
	jal player_damage
leave

# ------------------------------------------------------------------------------

.globl rock_collide_m
rock_collide_m:
enter
	jal rock_get_hit

	li a0, 2
	jal player_damage
leave

# ------------------------------------------------------------------------------

.globl rock_collide_s
rock_collide_s:
enter
	jal rock_get_hit

	li a0, 1
	jal player_damage
leave

# ------------------------------------------------------------------------------

.globl rock_draw_l
rock_draw_l:
enter s0
#so the argument rock is in a0
	move s0, a0
	
	la a1, spr_rock_l
	jal Object_blit_5x5_trans

leave s0

# ------------------------------------------------------------------------------

.globl rock_draw_m
rock_draw_m:
enter s0
	move s0, a0
	
	la a1, spr_rock_m
	jal Object_blit_5x5_trans
leave s0

# ------------------------------------------------------------------------------

.globl rock_draw_s
rock_draw_s:
enter s0
	move s0, a0
	
	la a1, spr_rock_s
	jal Object_blit_5x5_trans

leave s0