InitLevel:
    .call M16

; fill with tile 0
    ldx #0000
    lda #0000
clear_level_loop:
    sta @level_tiles,x
    inx
    inx
    cpx #05c0
    bne @clear_level_loop

; fill grass (tile 1)
    lda #0101
fill_grass_loop:
    sta @level_tiles,x
    inx
    inx
    cpx #0600
    bne @fill_grass_loop

; fill ground (tile 2)
    lda #0202
fill_ground_loop:
    sta @level_tiles,x
    inx
    inx
    cpx #0700
    bne @fill_ground_loop

    .call M8
    rts

PlacePillar:
    rts

ClearBG1Buffer:
    php
    .call MX16

    ldx #0000
clear_buffer_loop:
    lda #0000
    sta !bg1_buffer,x
    inx
    inx
    cpx #BG1_BUFFER_SIZE
    bne @clear_buffer_loop

    plp
    rts

LevelToBG1Buffer:
    jsr @ClearBG1Buffer
    ldx #0000
    stx @buffer_offset
    jsr @CopyHalf
    ldx #0800
    stx @buffer_offset
    ldx #0020
    jsr @CopyHalf

    rts

CopyHalf:
    stx @next_tile

    ldx #0000
    brk 00
level_to_bg1_buffer_loop:
    phx
    .call M16
    txa
    asl
    clc
    adc @buffer_offset
    tay
    .call M8

    ldx @next_tile
    lda @level_tiles,x

    tyx
    sta !bg1_buffer,x

    .call M16
    inc @next_tile
    lda @next_tile
    and #001f
    cmp #001f
    bne @skip_next_row

    lda @next_tile
    clc
    adc #0020
    sta @next_tile
skip_next_row:
    .call M8

    plx
    inx
    cpx #0380
    bne @level_to_bg1_buffer_loop

    rts
