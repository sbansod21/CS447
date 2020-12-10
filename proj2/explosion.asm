.include "constants.asm"
.include "macros.asm"

# =================================================================================================
# Explosions
# =================================================================================================

# void explosion_new(x, y)
.globl explosion_new
explosion_new:
enter s0, s1, s2
    move s0, a0
    move s1, a1
   
    li a0, TYPE_EXPLOSION
    jal Object_new

    beq v0, 0, _end_new_explosion
    move s2, v0
    sw s0, Object_x(s2)
    sw s1, Object_y(s2)

    li t0, EXPLOSION_HW
    li t1, EXPLOSION_HH

    sw t0, Object_hw(s2)
    sw t1, Object_hh(s2)

    li t0, EXPLOSION_ANIM_DELAY
    sw t0, Explosion_timer(s2)

    li t0, 0
    sw t0, Explosion_frame(s2)
    
    _end_new_explosion:

leave s0, s1, s2

# ------------------------------------------------------------------------------

.globl explosion_update
explosion_update:
enter s0
    move s0, a0
    lw t0, Explosion_timer(a0)
    sub t0, t0, 1
    sw t0, Explosion_timer(a0)

    bne t0, 0, _end_exp_update
    
    li t1, EXPLOSION_ANIM_DELAY
    sw t1, Explosion_timer(a0)

    lw t2, Explosion_frame(a0)
    add t2, t2, 1
    sw t2, Explosion_frame(a0)

    blt t2, 6, _end_exp_update
   
    move a0, s0
	jal Object_delete

_end_exp_update:
leave s0

# ------------------------------------------------------------------------------

.globl explosion_draw
explosion_draw:
enter s0
    move s0, a0
    #in a0 is the explosion
    
    # Addy + size*index
    la t0, spr_explosion_frames #addy
    lw t1, Explosion_frame(s0)
    mul t1, t1, 4
    add t2, t1, t0
    lw t2, (t2)    
    move a1, t2
    jal Object_blit_5x5_trans

leave s0