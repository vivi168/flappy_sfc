;**************************************
;
; clear oam buffer with off screen sprites
;
;**************************************
InitOamBuffer:
    php
    .call M8
    .call X16

    ldx #0000
set_x_lsb:
    lda #01 ; set sprite to x=-255
    sta !oam_buffer,x

    lda #f0 ; set sprite to y=240
    sta !oam_buffer+1,x

    inx
    inx
    inx
    inx
    cpx #OAML_SIZE
    bne @set_x_lsb

    lda #55         ; 01 01 01 01
set_x_msb:
    sta !oam_buffer,x
    inx
    sta !oam_buffer,x
    inx
    cpx #OAM_SIZE
    bne @set_x_msb

    plp
    rts

FlappyToOam:
    lda #FLAPPY_X
    sta !oam_buffer     ; x
    lda @flappy_y
    sta !oam_buffer+1   ; y

    lda #00
    sta !oam_buffer+2   ; tile number

    lda #30             ; 00110000
    sta !oam_buffer+3   ; vhppcccn

    lda #54
    sta !oam_buffer_hi

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

    ; if (pipes.intersectsWith(bird) || land.intersectsWith(bird)) {
    ;     chec if touches grass (01) or pipe
    ;     die();
    ; }

    jsr @CheckCollision

    rts

CheckCollision:
    lda @flappy_y
    lsr
    lsr
    lsr

    sta M7A
    stz M7A

    lda #LEVEL_WIDTH8
    sta M7B

    .call M16
    lda #FLAPPY_X16
    clc
    adc @flappy_mx
    clc
    adc #0008
    lsr
    lsr
    lsr

    clc
    adc MPYL

    ; lda MPYL
    tax
    .call M8

    lda @level_tiles,x
    cmp #0c
    beq @score_up

    cmp #0d
    beq @score_enable

    lda @level_tiles,x
    bne @Die

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

Die:
    ; falls until touches ground.
    ; show final score
die_loop:
    bra @die_loop

    rts
