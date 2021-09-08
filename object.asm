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
    lda @flappy_x
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
    and #00ff
    asl
    asl
    clc
    adc @flappy_v
    lsr
    lsr
    sta @flappy_y
    .call M8


    ; if (pipes.intersectsWith(bird) || land.intersectsWith(bird)) {
    ;     chec if touches grass (01) or pipe
    ;     die();
    ; }

    ; if (position < 0) {
    ;     check if touches ground (02)
    ;     position = 0;
    ; }
    rts
