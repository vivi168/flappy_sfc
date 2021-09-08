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

MenuLoop:
; if A -> record current (horizontal_offset // 8) + 67 (=> first spawn pillar)
;      -> spawn pillar
;      -> next spawn pillar @ first_spawn_pillar + 10, wrap at 70
;      -> jmp to MainLoop
    jsr @WaitNextVBlank

    jsr @CheckSpawnPillar
    jsr @WrapHorizontalOffset

    lda @joy1_press
    bit #JOY_AL
    bne @start_game

    jmp @MenuLoop

start_game:
    inc @pillar_enable

    lda @next_pillar_at
; rire:
;     clc
;     adc #PILLAR_SPACE
;     cmp @next_column_read
;     bcc @rire

;     clc
;     adc #PILLAR_SPACE

    cmp #LEVEL_WIDTH8
    bcc @issou

    sec
    sbc #LEVEL_WIDTH8
issou:
    sta @next_pillar_at

MainLoop:
    jsr @WaitNextVBlank

    jsr @EncodeScore
    jsr @PutScore
    jsr @CheckSpawnPillar
    jsr @WrapHorizontalOffset

    jsr @HandleInput

    jmp @MainLoop

WrapHorizontalOffset:
    .call M16
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
    .call M8

skip_copy_column:
    .call M8
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

.include info.asm
