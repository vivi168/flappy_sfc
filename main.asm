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
    jsr @WaitNextVBlank

    ; if A -> record current (horizontal_offset // 8) + 67 (=> first spawn pillar)
    ;      -> spawn pillar
    ;      -> next spawn pillar @ first_spawn_pillar + 10, wrap at 70
    ;      -> jmp to MainLoop

    jmp @MenuLoop

MainLoop:
    jsr @WaitNextVBlank

    jsr @EncodeScore
    jsr @PutScore
    jsr @CheckSpawnPillar

    jsr @HandleInput
    jsr @WrapHorizontalOffset

    jmp @MainLoop

WrapHorizontalOffset:
    .call M16
    inc @horizontal_offset
    lda @horizontal_offset
    cmp #0200
    bne @skip_wrap_horizontal_offset
    stz @horizontal_offset

skip_wrap_horizontal_offset:

    ; copy new column each time we scroll 8px
    bit #0007
    bne @skip_copy_column

    jsr @CopyColumn
    inc @pillar_disable

skip_copy_column:
    .call M8
    rts

CheckSpawnPillar:
    lda @pillar_disable
    cmp #10
    bne @skip_spawn_pillar
    stz @pillar_disable
    jsr @SpawnPillar

skip_spawn_pillar:
    rts

.include info.asm
