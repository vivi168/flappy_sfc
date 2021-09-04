;**************************************
; SOKOBAN
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


MainLoop:
    jsr @WaitNextVBlank

    jsr @EncodeScore
    jsr @PutScore

    jsr @HandleInput
    jsr @WrapHorizontalOffset

    jmp @MainLoop

WrapHorizontalOffset:
    .call M16
    inc @horizontal_offset
    lda @horizontal_offset
    cmp #0200
    bcc @skip_wrap_horizontal_offset
    stz @horizontal_offset

skip_wrap_horizontal_offset:
    .call M8
    rts

.include info.asm
