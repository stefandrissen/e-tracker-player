; Disassembly of e-tracker player.bin
;
; CPU Type: Z80
;
; Created with dZ80 2.0
;
; on Monday, 30 of November 2020 at 10:33 PM

; | 000 | --- 0000 | --- 0000 | --- 0000
;   row  note ||command + parameter
;             |+- ornament
;             +-- instrument

; instrument: 1-9 A-V (= 31 instruments)
; note: C#4
; command:
;   0 no change
;   1 envelope generator - [1-c]
;   2 instrument inversion
;   3 tune delay (default 6)
;   4 volume reduction [0-f]
;   5 extended noise
;   6 stop sound
;   7 no change

include "saa1099.i"

    org &8000
    dump 1,0

etracker.init:

    ld hl,module
    jp @init

etracker.play:

@var.delay:
    ld a,&01
    dec a
    jr nz,@same.notes

    ld ix,@var.channels

    ld b,6
@loop:
    push bc
    call @get.note
    ld bc,@channel.size
    add ix,bc
    pop bc
    djnz @-loop

    ld hl,(l83ed)
    ld a,h
    call @swap.nibbles.a
    or l
    ld (l80e5+1),a          ; noise
@var.song_speed:
    ld a,6

@same.notes:

    ld (@var.delay+1),a

    ld ix,@var.channel.0
    call @update.channel
    ld (@out + saa.register.amplitude_0),a
    ld (@out + saa.register.frequency_tone_0),hl

    push hl

    ld hl,&0000
    call @get.noise         ;
    ld (@+var.noise+1),hl
    ld (l80e3+1),a          ; noise

    ld ix,@var.channel.1
    call @update.channel
    ld (@out + saa.register.amplitude_1),a
    ld (@out + saa.register.frequency_tone_1),hl

    push hl
@var.noise:
    ld hl,&0000
    call @get.noise
    ld (@+var.noise+1),hl
    rl h
    jr nc,l8065

    ld (l80e3+1),a          ; noise
l8065:
    ld ix,@var.channel.2
    call @update.channel
    ld (@out + saa.register.amplitude_2),a
    ld (@out + saa.register.frequency_tone_2),hl

    push hl
@var.noise:
    ld hl,&0000
    call @get.noise
    ld (@+var.noise+1),hl
    rl h
    jr nc,l8083

    ld (l80e3+1),a          ; noise
l8083:
    ld ix,@var.channel.3
    call @update.channel
    ld (@out + saa.register.amplitude_3),a
    ld (@out + saa.register.frequency_tone_3),hl

    push hl
@var.noise:
    ld hl,&0000
    call @get.noise
    ld (@+var.noise+1),hl
    ld (l80dd+1),a

    ld ix,@var.channel.4
    call @update.channel
    ld (@out + saa.register.amplitude_4),a
    ld (@out + saa.register.frequency_tone_4),hl

    push hl
@var.noise:
    ld hl,&0000
    call @get.noise
    ld (@+var.noise+1),hl
    rl h
    jr nc,l80bb

    ld (l80dd+1),a
l80bb:
    ld ix,@var.channel.5
    call @update.channel
    ld (@out + saa.register.amplitude_5),a
    ld (@out + saa.register.frequency_tone_5),hl

    push hl
@var.noise:
    ld hl,&0000
    call @get.noise
    rr l
    rr l
    rr h
    rr h
    ld (@out + saa.register.frequency_enable),hl

    rlca
    jr c,l80e0

l80dd:
    ld a,&00
    rlca
l80e0:
    rlca
    rlca
    rlca
l80e3:
    or &00
l80e5:
    or &00
    ld (@out + saa.register.noise_generator_1_0),a

    pop af                                  ; tone channel 5
    pop bc                                  ; tone channel 4
    call @swap.nibbles.a
    or b
    ld h,a
    pop af                                  ; tone channel 3
    pop bc                                  ; tone channel 2
    call @swap.nibbles.a
    or b
    ld l,a
    ld (@out + saa.register.octave_3_2),hl

    pop af                                  ; tone channel 1
    pop bc                                  ; tone channel 0
    call @swap.nibbles.a
    or b
    ld (@out + saa.register.octave_1_0),a

    ld bc,port.sound.address
    ld de,saa.register.sound_enable * &100 + saa.se.channels.enabled
    out (c),d
    dec b                                   ; -> b = port.sound.data
    out (c),e

if defined ( silent )

    xor a
    ld hl,@out + saa.register.amplitude_0
    ld (hl),a       ; 0
    inc hl
    ld (hl),a       ; 1
    inc hl
;   ld (hl),a       ; 2 ! bleep
    inc hl
    ld (hl),a       ; 3
    inc hl
    ld (hl),a       ; 4
    inc hl
    ld (hl),a       ; 5

    ;!!! silence channels

endif

l810f:
    ld hl,@out + saa.register.envelope_generator_1
    ld d,saa.register.envelope_generator_1  ; &19
@loop:
    inc b                                   ; -> b = port.sound.address
    out (c),d
    dec b                                   ; -> b = port.sound.data
    ld a,(hl)
    out (c),a
    dec d

    ret m                                   ; d = -1

    dec hl
    jr @-loop

;----------------------------------------------
; frequency -> note - used? &8120

    defb &05    ; B
    defb &21    ; C
    defb &3c    ; C#
    defb &55    ; D
    defb &6d    ; D#
    defb &84    ; E
    defb &99    ; F
    defb &ad    ; F#
    defb &c0    ; G
    defb &d2    ; G#
    defb &e3    ; A
    defb &f3    ; A#

;----------------------------------------------
@instrument.no_loop:
    defb &fe,&01,&00,&00,&fc        ; -2,1,0,0,-4 ?

;----------------------------------------------
@list.envelopes:

    defb saa.envelope.reset   | saa.envelope.bits.4 | saa.envelope.mode.zero            | saa.envelope.left_right.same

    defb saa.envelope.enabled | saa.envelope.bits.3 | saa.envelope.mode.repeat_decay    | saa.envelope.left_right.same
    defb saa.envelope.enabled | saa.envelope.bits.3 | saa.envelope.mode.repeat_attack   | saa.envelope.left_right.same
    defb saa.envelope.enabled | saa.envelope.bits.3 | saa.envelope.mode.repeat_triangle | saa.envelope.left_right.same
    defb saa.envelope.enabled | saa.envelope.bits.4 | saa.envelope.mode.repeat_decay    | saa.envelope.left_right.same
    defb saa.envelope.enabled | saa.envelope.bits.4 | saa.envelope.mode.repeat_attack   | saa.envelope.left_right.same
    defb saa.envelope.enabled | saa.envelope.bits.4 | saa.envelope.mode.repeat_triangle | saa.envelope.left_right.same

    defb saa.envelope.enabled | saa.envelope.bits.3 | saa.envelope.mode.repeat_decay    | saa.envelope.left_right.inverse
    defb saa.envelope.enabled | saa.envelope.bits.3 | saa.envelope.mode.repeat_attack   | saa.envelope.left_right.inverse
    defb saa.envelope.enabled | saa.envelope.bits.3 | saa.envelope.mode.repeat_triangle | saa.envelope.left_right.inverse
    defb saa.envelope.enabled | saa.envelope.bits.4 | saa.envelope.mode.repeat_decay    | saa.envelope.left_right.inverse
    defb saa.envelope.enabled | saa.envelope.bits.4 | saa.envelope.mode.repeat_attack   | saa.envelope.left_right.inverse
    defb saa.envelope.enabled | saa.envelope.bits.4 | saa.envelope.mode.repeat_triangle | saa.envelope.left_right.inverse

;----------------------------------------------
@ornament.no_loop:

    defb &fe,&00                    ; -2,0 ?

;==============================================
@list.commands:

; jr table, used to adjust jr at @smc.command.jr
; first byte of each pair is compared, if command is
; equal or higher, jr is used else proceed to next
; -> compare bytes must be in descending order

; the subtracted value is in c

    @offset:    equ @smc.command.jr + 2

    defb &ff                        ; ??? skipped

    defb &d2                        ; [&d2-&ff] -> c = [&00-&2d]
    defb @cmd.set_delay_next_note - @offset

    defb &72                        ; [&72-&d2] -> c = [&00-&60]
    defb @cmd.set_note - @offset

    defb &52                        ; [&52-&71] -> c = [&00-&1f]
    defb @cmd.set_instrument - @offset

    defb &51                        ; [&51] -> c = &00
    defb @cmd.end_of_track - @offset

    defb &50                        ; [&50] -> c = &00
    defb @cmd.stop_sound - @offset

    defb &30                        ; [&30-&4f] -> c = [&00-&1f]
    defb @cmd.set_ornament - @offset

    defb &2e                        ; [&2e-&2f] -> c = [&00-&01]
    defb @cmd.invert - @offset

    defb &21                        ; [&21-2&d] -> c = [&00-&0c]
    defb @cmd.envelope - @offset

    defb &11                        ; [&11-&20] -> c = [&00-&0f]
    defb @cmd.volume_reduction - @offset

    defb &0f                        ; [&0f-&10] -> c = [&00-&01]
    defb @cmd.l8214 - @offset

    defb &00                        ; [&00-&0f] -> c = [&00-&0f]
    defb @cmd.song_speed - @offset

;==============================================
@swap.nibbles.a:

    rlca
    rlca
    rlca
    rlca
    ret

;==============================================
@get.noise:

; move lower two bits of a' into l and h

    ex af,af'
    rrca            ; move bit 0 of a into carry
    rr l            ; move carry bit into bit 7 of l
    rrca            ; move bit 0 of a into carry
    rr h            ; move carry bit into bit 7 of h
    ret

;==============================================
@bc.eq.section.c:

; input
;   hl = index
;   c  = section

; output
;   bc = address
;----------------------------------------------

    sla c
    ld b,0
    jr nc,$+3
    inc b
    add hl,bc   ; bc = c * 2

@bc.eq.section:
    ld c,(hl)
    inc hl
    ld b,(hl)
    inc hl

    push hl
@var.module.start:
    ld hl,&0000
    add hl,bc
    ld c,l
    ld b,h
    pop hl

    ret

;==============================================
@cmd.set_instrument:

; input
;   c = [&00-&1f]

@var.instruments:
    ld hl,&0000
    call @bc.eq.section.c
    ld (ix+@c.instrument.start.lo),c
    ld (ix+@c.instrument.start.hi),b

    ld hl,@instrument.no_loop
    ld (ix+@c.instrument.loop.lo),l
    ld (ix+@c.instrument.loop.hi),h

    jr @set.instrument

;==============================================
@cmd.set_ornament:

; input
;   c = [&00-&1f]

@var.ornaments:
    ld hl,&0000
    call @bc.eq.section.c
    ld (ix+@c.ornament.start.lo),c
    ld (ix+@c.ornament.start.hi),b

    ld hl,@ornament.no_loop
    ld (ix+@c.ornament.loop.lo),l
    ld (ix+@c.ornament.loop.hi),h

    jr @set.ornament

;==============================================
@get.note:

; input
;   b  = channel
;   ix = ptr.channel
;----------------------------------------------

    dec (ix+@c.delay.next_note)
    ret p           ; ret when (ix+@c.delay.next_note) > 0

    ld a,b
    cp 3            ; !!! bug??? should be cp 4 according to DTA
    ld hl,@out + saa.register.envelope_generator_0
    jr nc,$+3       ; channel > 3
    inc hl          ; hl = envelope_generator_1
    ld (@ptr.envelope_generator+1),hl

l81b7:
    ld e,(ix+@c.track.lo)
    ld d,(ix+@c.track.hi)

@get.command:

    ld hl,@list.commands

@find:
    ld a,(de)
    inc hl
    sub (hl)
    inc hl
    jr c,@-find ; (hl) > a

    inc de
    ld c,a
    ld a,(hl)
    ld (@smc.command.jr+1),a  ; update jr below

@smc.command.jr:
    jr @smc.command.jr        ; smc = command from @list.commands

;==============================================
@cmd.set_note:

; input
;   c = [&00-&60]

    ld (ix+@c.note),c

    ld c,(ix+@c.instrument.start.lo)
    ld b,(ix+@c.instrument.start.hi)

;----------------------------------------------
@set.instrument:

    ld (ix+@c.instrument.lo),c
    ld (ix+@c.instrument.hi),b

    ld c,(ix+@c.ornament.start.lo)
    ld b,(ix+@c.ornament.start.hi)

;----------------------------------------------
@set.ornament:

    ld (ix+@c.ornament.lo),c
    ld (ix+@c.ornament.hi),b

    ld (ix+@c.delay.next_ornament),1
    ld (ix+@c.delay.next_instrument),1
    ld (ix+&16),1

    jr @get.command

;==============================================
@cmd.envelope:  ; turn on or off envelope generator

; input
;   c = envelope [&00-&0c]

    ld b,0
    ld hl,@list.envelopes
    add hl,bc
    ld a,(hl)
@ptr.envelope_generator:
    ld (&0000),a
    jr @get.command

;==============================================
@cmd.invert:    ; turn on or off instrument inversion

; input
;   c = [&00-&01]

    ld (ix+@c.instrument.inversion),c
    jr @get.command

;==============================================
@cmd.song_speed:

; input
;   c = [&00-&0f]

    ld a,c
    inc a
    ld (@var.song_speed+1),a
    jr @get.command

;==============================================
@cmd.volume_reduction: ; volume reduction

; input
;   c = [&00-&0f]

    ld (ix+@c.volume.reduction),c
    jr @get.command

;==============================================
@cmd.l8214:

; input
;   c = [&00-&01]

    jr z,@envelope.off

    ld c,saa.envelope.left_right.inverse | saa.envelope.mode.maximum

@envelope.off:
    ld hl,(@ptr.envelope_generator+1)
    inc hl
    inc hl
    ld (hl),c
    jr @get.command

;==============================================
@cmd.stop_sound:

    ld bc,@instrument.no_loop
    jr @set.instrument

;==============================================
@cmd.set_delay_next_note:

; input
;   c = [&00-&2d]

    ld (ix+@c.delay.next_note),c
    ld (ix+@c.track.lo),e
    ld (ix+@c.track.hi),d
    ret

;==============================================
@cmd.end_of_track:

    call @read.song_table
    jp l81b7

;----------------------------------------------

@handle.instrument.special:
    cp &7f
    jr z,@set.instrument_loop

    cp &7e
    jr z,@get.instrument_loop

    add a,2
    ld c,a
l8240:
    jr @handle.instrument

@set.instrument_loop:
    ld (ix+@c.instrument.loop.lo),l
    ld (ix+@c.instrument.loop.hi),h
    jr @handle.instrument

@get.instrument_loop:
    ld l,(ix+@c.instrument.loop.lo)
    ld h,(ix+@c.instrument.loop.hi)
    jr @handle.instrument

;----------------------------------------------

@handle.ornament.special:

    inc a
    jr z,@get.ornament_loop     ; a was &ff

    inc a
    jr z,@set.ornament_loop     ; a was &fe

    sub &60
    ld c,a                      ; c = entry a - &5e
    jr @handle.ornament

@get.ornament_loop:
    ld l,(ix+@c.ornament.loop.lo)
    ld h,(ix+@c.ornament.loop.hi)
    jr @handle.ornament

@set.ornament_loop:
    ld (ix+@c.ornament.loop.lo),l
    ld (ix+@c.ornament.loop.hi),h
    jr @handle.ornament

;==============================================
@update.channel:

; input
;   ix = ptr.channel

; output
;   a   =   amplitude
;   l   =   tone
;   a'  =   noise
;----------------------------------------------

    ld e,(ix+&0a)
    ld d,(ix+&0b)
    dec (ix+@c.delay.next_instrument)
    ld l,(ix+@c.instrument.lo)
    ld h,(ix+@c.instrument.hi)
    jr nz,@no.instrument.change

    ld c,1
@handle.instrument:
    ld a,(hl)
    inc hl
    rrca
    jr nc,@handle.instrument.special

    ld (ix+@c.delay.next_instrument),c
    ld (ix+&0b),a
    ld e,(hl)
    ld d,a
    ld (ix+&0a),e
    inc hl

@no.instrument.change:
    push hl
    ld a,(ix+@c.ornament)
    dec (ix+@c.delay.next_ornament)
    jr nz,@no.ornament.change

    ld c,1
    ld l,(ix+@c.ornament.lo)
    ld h,(ix+@c.ornament.hi)
@handle.ornament:
    ld a,(hl)
    inc hl
    cp &60
    jr nc,@handle.ornament.special ; a >= &60

    ld (ix+@c.delay.next_ornament),c
    ld (ix+@c.ornament),a
    ld (ix+@c.ornament.lo),l
    ld (ix+@c.ornament.hi),h

@no.ornament.change:
    add a,(ix+@c.note)
    cp &5f
    ld hl,&07ff     ; maximum tone (7) + note (&ff)
    jr z,l82d4

@var.pattern.height:
    add a,0         ; set
    jr nc,$+4
    sub &60

    ld hl,&ff0c     ; h = -1, l = 12
    ld b,h
@loop:
    inc h
    sub l           ; l = &0c = 12 = octave?
    jr nc,@-loop

    ld c,a
    ld a,h
    ld hl,@instrument.no_loop
    add hl,bc
    ld l,(hl)
    ld h,a
l82d4:
    add hl,de
    ld a,h
    and &07
    ld h,a

    ld a,d
    rrca
    rrca
    rrca
    and &0f
    ex af,af'           ; a' used by @get.noise to fill bit 7 of h & bit 7 of l

    ex de,hl
    pop hl
    ld a,(ix+@c.volume)
    dec (ix+&16)
    jr nz,l82f7

    ld a,(hl)
    inc hl
@var.82ec:
    cp &00
    jr nz,l8325

    ld c,(hl)
    inc hl
l82f2:
    ld a,(hl)
    inc hl
l82f4:
    ld (ix+&16),c

l82f7:
    ld (ix+@c.instrument.lo),l
    ld (ix+@c.instrument.hi),h
    ld (ix+@c.volume),a
    ex de,hl
    ld b,(ix+@c.volume.reduction)

    ld c,a
    and &0f
    sub b
    jr nc,@volume_ge_0
    xor a
@volume_ge_0:
    ld e,a

    ld a,c
    and &f0
    call @swap.nibbles.a
    sub b
    jr nc,@volume_ge_0
    xor a
@volume_ge_0:
    ld d,a

    ld a,(ix+@c.instrument.inversion)
    or a
    ld a,e
    jr nz,@inverted

    ld a,d
    ld d,e

@inverted:
    call @swap.nibbles.a
    or d

    ret

l8325:
    push hl
    ld b,a
@var.8327:
    ld hl,&0000         ; ???
l832a:
    ld a,(hl)
    or a
    jr z,l8337

    inc hl
    ld c,(hl)
    inc hl
    cp b
    jr nz,l832a

    pop hl
    jr l82f2

l8337:
    pop hl
    ld c,&01
    ld a,b
    jr l82f4

@channel.size: equ &19

@var.channels:                                      ; &833d

@c.track:                   equ &00                 ; address of track data
    @c.track.lo:                equ &00
    @c.track.hi:                equ &01

@c.instrument.lo:           equ &02
@c.instrument.hi:           equ &03
@c.instrument.loop.lo:      equ &04
@c.instrument.loop.hi:      equ &05

@c.ornament.lo:             equ &06
@c.ornament.hi:             equ &07
@c.ornament.loop.lo:        equ &08
@c.ornament.loop.hi:        equ &09

@c.volume:                  equ &0c
@c.ornament:                equ &0d
@c.note:                    equ &0e

@c.instrument.start.lo:     equ &0f
@c.instrument.start.hi:     equ &10
@c.ornament.start.lo:       equ &11
@c.ornament.start.hi:       equ &12

@c.delay.next_note:         equ &13
@c.delay.next_ornament:     equ &14
@c.delay.next_instrument:   equ &15

@c.instrument.inversion:    equ &17
@c.volume.reduction:        equ &18

@var.channel.0: defs @channel.size
@var.channel.1: defs @channel.size
@var.channel.2: defs @channel.size
@var.channel.3: defs @channel.size
@var.channel.4: defs @channel.size
@var.channel.5: defs @channel.size

@out:                                               ; &83d3

        defb 0          ; &00 amplitude_0
        defb 0          ; &01 amplitude_1
        defb 0          ; &02 amplitude_2
        defb 0          ; &03 amplitude_3
        defb 0          ; &04 amplitude_4
        defb 0          ; &05 amplitude_5
        defb 0
        defb 0
        defb 0          ; &08 frequency_tone_0      ; &83db
        defb 0          ; &09 frequency_tone_1      ; &83dc
        defb 0          ; &0a frequency_tone_2      ; &83dd
        defb 0          ; &0b frequency_tone_3      ; &83de
        defb 0          ; &0c frequency_tone_4      ; &83df
        defb 0          ; &0d frequency_tone_5      ; &83e0
        defb 0
        defb 0
        defb 0          ; &10 octave_1_0            ; &83e3
        defb 0          ; &11 octave_3_2            ; &83e4
        defb 0          ; &12 octave_5_4            ; &83e5
        defb 0
        defb 0          ; &14 frequency_enable      ; &83e7
        defb 0          ; &15 noise_enable          ; &83e8
        defb 0          ; &16 noise_generator_1_0   ; &83e9
        defb 0
        defb 0          ; &18 envelope_generator_0  ; &83eb
        defb 0          ; &19 envelope_generator_1  ; &83ec

l83ed:  defw 0

@var.channels.size: equ $ - @var.channels

;==============================================
@init:

; input
;   hl = start address of compiled module
;----------------------------------------------

    ld (@var.module.start+1),hl
    call @bc.eq.section
    ld (@var.song_table+1),bc

    call @bc.eq.section
    ld (@var.patterns+1),bc

    call @bc.eq.section
    ld (@var.instruments+1),bc

    call @bc.eq.section
    ld (@var.ornaments+1),bc

    call @bc.eq.section
    ld a,(bc)                   ; ???
    inc bc
    ld (@var.82ec+1),a          ; ??? song loop
    ld (@var.8327+1),bc         ; ???

    ld hl,@var.channels
    ld b,@var.channels.size
    xor a
@loop:
    ld (hl),a
    inc hl
    djnz @-loop

    inc a                   ; -> a = 1
    ld (@var.delay+1),a

    ld ix,@var.channels
    ld de,@channel.size

    ld b,6
@loop:
    ld (ix+@c.delay.next_ornament),a
    ld (ix+@c.delay.next_instrument),a
    ld (ix+&16),a

    ld hl,@instrument.no_loop
    ld (ix+@c.instrument.start.lo),l
    ld (ix+@c.instrument.start.hi),h

    ld (ix+@c.instrument.lo),l
    ld (ix+@c.instrument.hi),h

    ld hl,@ornament.no_loop
    ld (ix+@c.ornament.start.lo),l
    ld (ix+@c.ornament.start.hi),h
    add ix,de
    djnz @-loop

    ld de,saa.register.sound_enable * &100 + saa.se.generators.reset
    ld bc,port.sound.address
    out (c),d
    dec b
    out (c),e

;----------------------------------------------
@read.song_table:

; song table entries are a multiple of 3 -> [&00,&03,&06 .. &5a,&5d]

@var.song_table:
    ld hl,&0000

@init.song_table:

    ld c,(hl)
    ld a,c
    inc hl
    inc a
    jr z,@song_table.get_loop       ; a = &ff -> end of song

    inc a
    jr z,@song_table.set_loop       ; a = &fe

    sub &62
    jr nc,@song_table.set_height    ; a >= &60 (a was incremented twice above)

    ld (@var.song_table+1),hl
    sla c                           ; c * 2 -> song_table is multiple of 3 -> per channel

@var.patterns:
    ld hl,&0000
    call @bc.eq.section.c

    ld (@var.channel.0+@c.track),bc

    call @bc.eq.section
    ld (@var.channel.1+@c.track),bc

    call @bc.eq.section
    ld (@var.channel.2+@c.track),bc

    call @bc.eq.section
    ld (@var.channel.3+@c.track),bc

    call @bc.eq.section
    ld (@var.channel.4+@c.track),bc

    call @bc.eq.section
    ld (@var.channel.5+@c.track),bc

    ret

;==============================================
@song_table.get_loop:

@var.song_table_loop:
    ld hl,&0000
    jr @init.song_table

;==============================================
@song_table.set_loop:

    ld (@var.song_table_loop+1),hl
    jr @init.song_table

;==============================================
@song_table.set_height:

; input
;   a = [&00-&9b]

    ld (@var.pattern.height+1),a
    jr @init.song_table

;==============================================

module:
