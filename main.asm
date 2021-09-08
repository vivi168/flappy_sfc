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

    jsr @CheckSpawnPillar
    jsr @WrapHorizontalOffset

    lda @joy1_press
    bit #JOY_AL
    bne @start_game

    jmp @MenuLoop

start_game:
    ; bug here. sometimes pillar is not copied
    ; completely (race condition ?)
    inc @pillar_enable

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
