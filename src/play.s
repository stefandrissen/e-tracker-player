
    org &8000
    dump 1,0

etracker.init:
etracker.play:  equ etracker.init + 6

include "e-tracker player.s"

@module.start:

include "retrigger.s"

@module.length: equ $ - @module.start

autoexec

start:

    call @includes.player

@data.only:

    call etracker.init

;    ld a,&c9                    ; opcode_ret
;    ld (disable_loop),a         ; prevent loop
@loop:
    call etracker.play
    halt
    jr @loop

;----------------------------------------------
@includes.player:

    ; if module starts with player (ld hl,&84b3),
    ; copy module to normal location -

    ld hl,module
    ld a,(hl)
    cp &21  ; ld hl,
    ret nz
    inc hl
    ld a,(hl)
    cp &b3
    ret nz
    inc hl
    ld a,(hl)
    cp &84
    ret nz

    ld hl,module + &04b3
    ld de,module
    ld bc,@module.length - &04b3
    ldir

    ret
