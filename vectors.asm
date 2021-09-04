ResetVector:
    sei                 ; disable interrupts
    clc
    xce
    cld
    jmp !FastReset
FastReset:
    .call M8
    .call X16

    ldx #STACK_TOP
    txs                 ; set stack pointer to 1fff

    lda #01
    sta MEMSEL

; ---- Forced Blank
    lda #80
    sta INIDISP
    jsr @ClearRegisters

; ---- BG settings
    lda #09             ; bg 3 high prio, mode 1
    sta BGMODE

    .call RESET_OFFSET BG1HOFS, BG1VOFS
    .call RESET_OFFSET BG2HOFS, BG2VOFS
    .call RESET_OFFSET BG3HOFS, BG3VOFS

    lda #10
    sta BG12NBA         ; BG1 tiles @ VRAM[0000], BG2 tiles @ VRAM[2000]

    lda #02
    sta BG34NBA         ; BG3 tiles @ VRAM[4000]

    lda #28
    sta BG1SC           ; BG1 MAP @ VRAM[5000]

    lda #2c
    sta BG2SC           ; BG2 MAP @ VRAM[5800]

    lda #30
    sta BG3SC           ; BG3 MAP @ VRAM[6000]

    lda #13             ; enable BG12 + sprites (0b10011)
    sta TM

;  ---- OBJ settings
    lda #62             ; sprite 16x16 small, 32x32 big
    sta OBJSEL          ; oam start @VRAM[8000]

;  ---- Some initialization
    jsr @InitOamBuffer
    jsr @InitLevel
    jsr @ClearBG1Buffer

;  ---- DMA Transfers
    .call VRAM_DMA_TRANSFER 0000, bg1_tiles, BG1_TILES_SIZE
    .call VRAM_DMA_TRANSFER 1000, bg2_tiles, BG2_TILES_SIZE           ; VRAM[0x2000] (word step)
    .call VRAM_DMA_TRANSFER 4000, sprites_tiles, SPRITES_TILES_SIZE   ; VRAM[0x8000] (word step)

    .call VRAM_DMA_TRANSFER 2c00, bg2_map, BG2_MAP_SIZE

    .call CGRAM_DMA_TRANSFER 00, bg1_pal, BG_PALETTES_SIZE
    .call CGRAM_DMA_TRANSFER 80, sprites1_pal, SPRITES_PALETTES_SIZE  ; CGRAM[0x100] (word step)

    jsr @TransferBG1Buffer
    jsr @TransferOamBuffer

; ---- Release Forced Blank
    lda #0f             ; release forced blanking, set screen to full brightness
    sta INIDISP

    lda #81             ; enable NMI, turn on automatic joypad polling
    sta NMITIMEN
    cli

    jmp @MainLoop

BreakVector:
    rti

WaitNextVBlank:
    stz @vblank_disable
wait_next_vblank:
    lda @vblank_disable
    beq @wait_next_vblank
    stz @vblank_disable
    rts

NmiVector:
    jmp !FastNmi
FastNmi:
    php
    .call MX16
    pha
    phx
    phy

    .call M8
    .call X16

    lda RDNMI

    inc @frame_counter

    lda @horizontal_offset
    sta BG1HOFS
    lda @horizontal_offset+1
    sta BG1HOFS

    jsr @TransferBG1Buffer
    jsr @TransferOamBuffer

    jsr @ReadJoyPad1

    inc @vblank_disable

    .call MX16
    ply
    plx
    pla
    plp
    rti
