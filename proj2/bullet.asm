.include "constants.asm"
.include "macros.asm"

# =================================================================================================
# Bullet
# =================================================================================================

# void bullet_new(x: a0, y: a1, angle: a2)
.globl bullet_new
bullet_new:
enter s0, s1, s2, s3
    move s0, a0
    move s1, a1
    move s2, a2

    li a0, TYPE_BULLET
    jal Object_new

    li t0, BULLET_LIFE
    sw t0, Bullet_frame(v0)

    beq v0, 0, _end_new_bullet
    move s3, v0
    sw s0, Object_x(v0)
    sw s1, Object_y(v0)

_end_new_bullet:
 
    li a0, BULLET_THRUST
    #in s2 is the angle so move that shit
    move a1, s2
    jal to_cartesian

    #inside v0 is the velocity 
    sw v0, Object_vx(s3)
    sw v1, Object_vy(s3)

leave s0, s1, s2, s3

# ------------------------------------------------------------------------------

.globl bullet_update
bullet_update:
enter s0, s1, s2
    #so the arguemnt bullet is prolly(SHOULD BE) in a0
    move s0, a0
    lw t0, Bullet_frame(s0)
    sub t0, t0, 1
    sw t0, Bullet_frame(s0)

    bne t0, 0, _update_else #Branch if t0 is NOT equal to 
    
    move a0, s0
    jal Object_delete

    j end_update
    
    _update_else:
        jal Object_accumulate_velocity

        move a0, s0
        jal Object_wrap_position
    
    end_update:
leave s0, s1, s2

# ------------------------------------------------------------------------------

.globl bullet_draw
bullet_draw:
enter s0, s1, s2
    #the bullet in a0
    move s0, a0

    lw a0, Object_x(a0)
    srl a0, a0, 8

    #move a0, s0
    lw a1, Object_y(s0)
    srl a1, a1, 8
    
    li a2, COLOR_RED
    jal display_set_pixel

leave s0, s1, s2