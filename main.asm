;**************************************
; FLAPPY BIRD
;**************************************
.65816

.include define.inc
.include registers.inc
.include macros.inc
.include var.asm
.include assets.asm

.org 808000
.base 0000

.include vectors.asm
.include clear.asm
.include dma.asm
.include joypad.asm
.include level.asm
.include object.asm
.include hud.asm
.include music.asm

MenuLoop:
    jsr @WaitNextVBlank

    ; jsr @CheckSpawnPillar
    ; jsr @WrapHorizontalOffset
    jsr @FlappyToOam

    lda @joy1_press
    bit #JOY_AL
    bne @start_game

    jmp @MenuLoop

start_game:
    ; random seed
    lda @frame_counter
    sta @next_rand
    eor #ff
    sta @next_rand+1

    inc @pillar_enable

MainLoop:
    jsr @WaitNextVBlank

    jsr @EncodeScore
    jsr @PutScore
    jsr @CheckSpawnPillar
    jsr @WrapHorizontalOffset

    jsr @ApplyPhysics
    jsr @FlappyToOam

    jsr @HandleInput

    jmp @MainLoop

WrapHorizontalOffset:
    .call M16
    jsr @WrapFlappyMX

    inc @horizontal_offset
    lda @horizontal_offset
    cmp #0200
    bcc @skip_wrap_horizontal_offset
    stz @horizontal_offset

skip_wrap_horizontal_offset:

    ; copy new column each time we scroll 8px
    bit #0007
    bne @skip_copy_column

    jsr @CopyColumn
skip_copy_column:
    .call M8
    rts

WrapFlappyMX:
    inc @flappy_mx
    lda @flappy_mx

    cmp #0230
    bcc @skip_wrap_flappy_mx
    stz @flappy_mx

skip_wrap_flappy_mx:
    rts

CheckSpawnPillar:
    lda @spawn_pillar_delay
    cmp #SPAWN_PILLAR_DELAY
    bcc @skip_spawn_pillar
    jsr @SpawnPillar
    rts

skip_spawn_pillar:
    inc @spawn_pillar_delay
    rts

ApplyPhysics:
    .call M16
    ; velocity += gravity
    inc @flappy_v

    ; position += velocity
    lda @flappy_y
    asl
    asl
    clc
    adc @flappy_v
    bpl @skip_keep_in_bound
    lda #0000
skip_keep_in_bound:
    lsr
    lsr
    sta @flappy_y
    .call M8

    jsr @CheckCollision

    rts

; Take center of flappy.
; check if on any non void tile -> Dead
; check if on score tile -> score up
CheckCollision:
    lda @flappy_y
    clc
    adc #08
    lsr
    lsr
    lsr

    sta M7A
    stz M7A

    lda #LEVEL_WIDTH8
    sta M7B

    .call M16
    lda @flappy_mx
    clc
    adc #FLAPPY_X16

    lsr
    lsr
    lsr

    clc
    adc MPYL

    tax
    .call M8

    lda @level_tiles,x
    cmp #0c
    beq @score_up

    cmp #f3
    beq @score_enable

    lda @level_tiles,x
    bne @DieLoop

    bra @exit_collision

score_up:
    lda @score_disable
    bne @exit_collision
    .call M16
    inc @score
    .call M8
    inc @score_disable
    bra @exit_collision

score_enable:
    stz @score_disable

exit_collision:
    rts

DieLoop:
    ; TODO: show final score
    jsr @WaitNextVBlank
    jsr @FlappyToOam

    .call M16
    ; velocity += gravity
    inc @flappy_v

    ; position += velocity
    lda @flappy_y
    asl
    asl
    clc
    adc @flappy_v
    lsr
    lsr
    sta @flappy_y
    .call M8
    cmp #b3
    bcs @DeadLoop
    bra @DieLoop

DeadLoop:
    jsr @WaitNextVBlank

    lda @joy1_press+1
    bit #JOY_BH
    bne @reset_game

    jmp @DeadLoop

reset_game:
    jmp @ResetVector

.include info.asm
