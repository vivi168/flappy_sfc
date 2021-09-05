InitLevel:
    .call M16

; fill with tile 0
    ldx #0000
    lda #0000
clear_level_loop:
    sta @level_tiles,x
    inx
    inx
    cpx #064a
    bne @clear_level_loop

; fill grass (tile 1)
    lda #0101
fill_grass_loop:
    sta @level_tiles,x
    inx
    inx
    cpx #0690
    bne @fill_grass_loop

; fill ground (tile 2)
    lda #0202
fill_ground_loop:
    sta @level_tiles,x
    inx
    inx
    cpx #07a8
    bne @fill_ground_loop

    .call M8
    rts

PlacePillar:
    rts

; Copy first 48 columns
Copy48Columns:
    ldx #0000
    stx @next_column_read
    stx @next_column_write

copy_48_columns_loop:
    jsr @CopyColumn

    inx
    cpx #0030   ; copy first 48 columns
    bne @copy_48_columns_loop

    rts

CopyColumn:
    phx
    phd

    ; stack frame
    .call RESERVE_STACK_FRAME 04
    ldx @next_column_read
    stx 01
    ldx @next_column_write
    stx 03

    ldy #0000
copy_column_loop:
    ldx 01
    lda @level_tiles,x

    ldx 03
    sta !bg_buffers,x
    inx
    lda #00
    sta !bg_buffers,x

    .call M16
    lda 01
    clc
    adc #LEVEL_WIDTH
    sta 01

    lda 03
    clc
    adc #BUFFER_WIDTH
    sta 03
    .call M8

    iny
    cpy #LEVEL_HEIGHT
    bne @copy_column_loop

    jsr @IncNextColumnReadWrite

    ; restore stack frame
    .call RESTORE_STACK_FRAME 04
    pld

    plx
    rts

IncNextColumnReadWrite:
    .call M16
    lda @next_column_read
    inc
    cmp #LEVEL_WIDTH
    bne @check_next_column_write
    lda #0000
check_next_column_write:
    sta @next_column_read

    lda @next_column_write
    inc
    inc
    cmp #0840
    bne @check_next_column_write_2
    lda #0000
check_next_column_write_2:
    cmp #0040
    bne @next_column_copy
    lda #0800
next_column_copy:
    sta @next_column_write
    .call M8

    rts
