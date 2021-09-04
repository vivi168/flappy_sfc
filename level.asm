InitLevel:
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
    cpx #BG_BUFFER_SIZE
    bne @clear_buffer_loop

    plp
    rts

LevelToBG1Buffer:
    rts
