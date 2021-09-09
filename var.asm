.org 7e0000

joy1_raw:                 .rb 2
joy1_press:               .rb 2
joy1_held:                .rb 2

frame_counter:            .rb 1
vblank_disable:           .rb 1

horizontal_offset:        .rb 2
flappy_mx:                .rb 2

hex_to_dec_in:            .rb 2
hex_to_dec_out:           .rb 3

next_column_read:         .rb 2
next_column_write:        .rb 2

pillar_enable:            .rb 1
spawn_pillar_delay:       .rb 1
next_pillar_at:           .rb 1

flappy_x:                 .rb 2
flappy_y:                 .rb 2
flappy_v:                 .rb 2

level_tiles:              .rb LEVEL_SIZE

.org 7e2000

bg_buffers:
bg1_buffer:
bg1_buffer_left:          .rb 800
bg1_buffer_right:         .rb 800
bg3_buffer:               .rb 800
oam_buffer:               .rb 200
oam_buffer_hi:            .rb 20
