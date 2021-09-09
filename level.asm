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

SpawnPillar:
    .call RESERVE_STACK_FRAME 04
    ; 01/02 pillar top height
    ; 03/04 pillar bot height
    ; 05/06 next_pillar_at
    jsr @NextPillarHeight

    lda @pillar_enable
    bne @continue_spawn_pillar
    jmp @exit_spawn_pillar
continue_spawn_pillar:
    lda @next_pillar_at
    .call M16
    and #00ff
    tax
    stx 05
    .call M8

    lda @next_pillar_height_top
    dec
    dec
    sta 01
    stz 02
    lda @next_pillar_height_bot
    dec
    dec
    sta 03
    stz 04

; clear pillar

    ldy #0000
clear_pillar_loop:

    lda #00 ; left part
    sta @level_tiles,x

    inx     ; middle part
    sta @level_tiles,x

    inx     ; right part
    sta @level_tiles,x

    .call M16
    txa
    clc
    adc #PILLAR_WRAP
    tax
    .call M8

    iny
    cpy #PILLAR_HEIGHT
    bne @clear_pillar_loop

; spawn pillar top
    ldx 05
    ldy #0000
spawn_pillar_top_loop:

    lda #09 ; left part
    sta @level_tiles,x

    inx     ; middle part (0a)
    inc
    sta @level_tiles,x

    inx     ; right part (0b)
    inc
    sta @level_tiles,x

    .call M16
    txa
    clc
    adc #PILLAR_WRAP
    tax
    .call M8

    iny
    cpy 01
    bne @spawn_pillar_top_loop

; bottleneck top
    lda #f9
    sta @level_tiles,x ; left part

    inx
    dec
    sta @level_tiles,x ; middle part

    inx
    dec
    sta @level_tiles,x ; right part

    .call M16
    txa
    clc
    adc #PILLAR_WRAP
    tax
    .call M8

    lda #fc
    sta @level_tiles,x ; left part

    inx
    dec
    sta @level_tiles,x ; middle part

    inx
    dec
    sta @level_tiles,x ; right part

    .call M16
    txa
    clc
    adc #PILLAR_WRAP
    tax
    .call M8

; score / opening
    ldy #0000
spawn_opening_loop:
    lda #00
    sta @level_tiles,x ; left part

    inx
    lda #0c
    sta @level_tiles,x ; middle part

    inx
    lda #f3
    sta @level_tiles,x ; right part

    .call M16
    txa
    clc
    adc #PILLAR_WRAP
    tax
    .call M8

    iny
    cpy #0006
    bne @spawn_opening_loop

; bottleneck bottom
    lda #03
    sta @level_tiles,x ; left part

    inx
    inc
    sta @level_tiles,x ; middle part

    inx
    inc
    sta @level_tiles,x ; right part

    .call M16
    txa
    clc
    adc #PILLAR_WRAP
    tax
    .call M8

    lda #06
    sta @level_tiles,x ; left part

    inx
    inc
    sta @level_tiles,x ; middle part

    inx
    inc
    sta @level_tiles,x ; right part

    .call M16
    txa
    clc
    adc #PILLAR_WRAP
    tax
    .call M8


; spawn pillar bottom
    ldy #0000
spawn_pillar_bot_loop:

    lda #09 ; left part
    sta @level_tiles,x

    inx     ; middle part (0a)
    inc
    sta @level_tiles,x

    inx     ; right part (0b)
    inc
    sta @level_tiles,x

    .call M16
    txa
    clc
    adc #PILLAR_WRAP
    tax
    .call M8

    iny
    cpy 03
    bne @spawn_pillar_bot_loop

exit_spawn_pillar:
    jsr @IncNextPillarAt

    .call RESTORE_STACK_FRAME 04
    rts

CopyInitialColumns:
    ldx #0000
    stx @next_column_read
    stx @next_column_write

copy_initial_columns_loop:
    jsr @CopyColumn

    inx
    cpx #0022
    bne @copy_initial_columns_loop

    rts

CopyColumn:
    php
    phx
    .call M8
    .call RESERVE_STACK_FRAME 05
    ; 01/02 -> next_column_read
    ; 03/04 -> next_column_write
    ; 05 -> tile props
    ldx @next_column_read
    stx 01
    ldx @next_column_write
    stx 03

    ldy #0000
copy_column_loop:
    stz 05
    ldx 01
    lda @level_tiles,x

    bpl @carry_on_copy
    eor #ff
    pha
    lda #80
    sta 05
    pla

carry_on_copy:
    ldx 03
    sta !bg_buffers,x
    inx
    lda 05
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

    .call RESTORE_STACK_FRAME 05
    plx
    plp
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

IncNextPillarAt:
    lda @next_pillar_at
    clc
    adc #PILLAR_SPACING
    cmp #LEVEL_WIDTH8
    bcc @exit_inc_next_pillar_at

    sec
    sbc #LEVEL_WIDTH8
exit_inc_next_pillar_at:
    sta @next_pillar_at

    stz @spawn_pillar_delay

    rts

NextPillarHeight:
    ; here, also generate next pillar height
    jsr @Random
    lda @next_rand
    and #07
    inc
    inc
    inc
    inc

    brk 00
    sta @next_pillar_height_top

    lda #11 ; pillar height - opening
    sec
    sbc @next_pillar_height_top
    sta @next_pillar_height_bot

    rts

; Xorshift algorithm
Random:
	lda @next_rand+1
	lsr
	lda @next_rand
	ror
	eor @next_rand+1
	sta @next_rand+1 ; high part of x ^= x << 7 done
	ror              ; A has now x >> 9 and high bit comes from low byte
	eor @next_rand   ; x ^= x >> 9 and the low part of x ^= x << 7 done
	sta @next_rand
	eor @next_rand+1
	sta @next_rand+1 ; x ^= x << 8 done
	rts
