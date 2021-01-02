; Disassembly of the compiled E-Tracker player
;
; (C) 2020-2021 Stefan Drissen
;
; Object code (C) 1992 ESI
;----------------------------------------------
; row as shown in E-Tracker editor:
;
; | 000 | --- 0000 | --- 0000 | --- 0000
;   row   |/| ||command + parameter
;         | | |+- ornament
;         | | +-- instrument
;         | +- octave
;         +--- note

; note: C C# D D# E F F# G G# A A# B
; octave:     1-8
; instrument: 1-9 A-V (= 31 instruments)
; ornament:   1-9 A-V (= 31 ornaments)
; command:
;   0 no change
;   1 envelope generator    - [0-c] see @cmd.envelope
;   2 instrument inversion  - [0-1] see @cmd.instrument_inversion
;   3 tune delay (default 6)- [0-f] see @cmd.tune_delay
;   4 volume reduction      - [0-f] see @cmd.volume_reduction
;   5 extended noise        - [0-1] see @cmd.extended_noise
;   6 stop sound                    see @cmd.stop_sound
;   7 no change

include "saa1099.i"

    org &8000
    dump 1,0

;==============================================
etracker.init:

    ld hl,module
    jp @init

;==============================================
etracker.play:

@var.delay:
    ld a,1
    dec a
    jr nz,@same.notes

    ld ix,@str.channel.0

    ld b,6
@loop:
    push bc
    call @get.note
    ld bc,@str.channel.size
    add ix,bc
    pop bc

    djnz @-loop


    ld hl,(@var.noise.0)
    ld a,h
    call @swap.nibbles.a
    or l
    ld (@var.noise.extended+1),a

@var.tune_delay:
    ld a,6

@same.notes:

    ld (@var.delay+1),a

;----------------------------------------------

    ld ix,@str.channel.0
    call @update.channel    ; sets a, l, a'
    ld (@out + saa.register.amplitude_0),a
    ld (@out + saa.register.frequency_tone_0),hl

    push hl

    ld hl,0
    call @get.noise         ; move lower two bits of a' into l and h
    ld (@+store.noise+1),hl
    ld (@var.noise.gen.0+1),a

;----------------------------------------------

    ld ix,@str.channel.1
    call @update.channel
    ld (@out + saa.register.amplitude_1),a
    ld (@out + saa.register.frequency_tone_1),hl

    push hl
@store.noise:
    ld hl,0
    call @get.noise
    ld (@+store.noise+1),hl
    rl h
    jr nc,@+no_noise
    ld (@var.noise.gen.0+1),a
@no_noise:

;----------------------------------------------

    ld ix,@str.channel.2
    call @update.channel
    ld (@out + saa.register.amplitude_2),a
    ld (@out + saa.register.frequency_tone_2),hl

    push hl
@store.noise:
    ld hl,0
    call @get.noise
    ld (@+store.noise+1),hl
    rl h
    jr nc,@+no_noise
    ld (@var.noise.gen.0+1),a
@no_noise:

;----------------------------------------------

    ld ix,@str.channel.3
    call @update.channel
    ld (@out + saa.register.amplitude_3),a
    ld (@out + saa.register.frequency_tone_3),hl

    push hl
@store.noise:
    ld hl,0
    call @get.noise
    ld (@+store.noise+1),hl
    ld (@var.noise.gen.1+1),a

;----------------------------------------------

    ld ix,@str.channel.4
    call @update.channel
    ld (@out + saa.register.amplitude_4),a
    ld (@out + saa.register.frequency_tone_4),hl

    push hl
@store.noise:
    ld hl,0
    call @get.noise
    ld (@+store.noise+1),hl
    rl h
    jr nc,@+no_noise
    ld (@var.noise.gen.1+1),a
@no_noise:

;----------------------------------------------

    ld ix,@str.channel.5
    call @update.channel
    ld (@out + saa.register.amplitude_5),a
    ld (@out + saa.register.frequency_tone_5),hl

    push hl
@store.noise:
    ld hl,0
    call @get.noise
    rr l
    rr l
    rr h
    rr h
    ld (@out + saa.register.frequency_enable),hl

    rlca
    jr c,@+no_noise

@var.noise.gen.1:                           ; set by instruments ch3-ch5
    ld a,0
    rlca
@no_noise:
    rlca
    rlca
    rlca
@var.noise.gen.0:                           ; set by instruments ch0-ch2
    or 0
@var.noise.extended:                        ; set by @cmd.extended_noise
    or 0
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
@frequency.note:

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
@instrument.none:

    defb &fe    ; set loop
    defb &01
    defb &00
    defb &00
    defb &fc    ; get loop

;----------------------------------------------
@list.envelopes:

    @enabled: equ saa.envelope.enabled
    @bits.3:  equ saa.envelope.bits.3
    @bits.4:  equ saa.envelope.bits.4
    @same:    equ saa.envelope.left_right.same
    @inverse: equ saa.envelope.left_right.inverse

    defb @same    | @bits.4 | saa.envelope.mode.zero            | saa.envelope.reset

    defb @same    | @bits.3 | saa.envelope.mode.repeat_decay    | @enabled   ; 1
    defb @same    | @bits.3 | saa.envelope.mode.repeat_attack   | @enabled   ; 2
    defb @same    | @bits.3 | saa.envelope.mode.repeat_triangle | @enabled   ; 3

    defb @same    | @bits.4 | saa.envelope.mode.repeat_decay    | @enabled   ; 4
    defb @same    | @bits.4 | saa.envelope.mode.repeat_attack   | @enabled   ; 5
    defb @same    | @bits.4 | saa.envelope.mode.repeat_triangle | @enabled   ; 5

    defb @inverse | @bits.3 | saa.envelope.mode.repeat_decay    | @enabled   ; 7
    defb @inverse | @bits.3 | saa.envelope.mode.repeat_attack   | @enabled   ; 8
    defb @inverse | @bits.3 | saa.envelope.mode.repeat_triangle | @enabled   ; 9

    defb @inverse | @bits.4 | saa.envelope.mode.repeat_decay    | @enabled   ; A
    defb @inverse | @bits.4 | saa.envelope.mode.repeat_attack   | @enabled   ; B
    defb @inverse | @bits.4 | saa.envelope.mode.repeat_triangle | @enabled   ; C

;----------------------------------------------
@ornament.none:

    defb &fe    ; set loop
    defb &00
    defb &ff    ; get loop

;==============================================
@list.commands:

; jr table, used to adjust jr at @smc.command.jr
; first byte of each pair is compared, if command is
; equal or higher, jr is used else proceed to next
; -> compare bytes must be in descending order

; the subtracted value is in c

    @offset:    equ @smc.command.jr + 2

    defb &d2                        ; [&d2-&ff] -> c = [&00-&2d]
    defb @cmd.set_delay_next_note - @offset

    defb &72                        ; [&72-&d2] -> c = [&00-&60]
    defb @cmd.set_note - @offset

    defb &52                        ; [&52-&71] -> c = [&00-&1f]
    defb @cmd.set_instrument - @offset

    defb &51                        ; [&51]     -> c =  &00
    defb @cmd.end_of_track - @offset

    defb &50                        ; [&50]     -> c =  &00
    defb @cmd.stop_sound - @offset

    defb &30                        ; [&30-&4f] -> c = [&00-&1f]
    defb @cmd.set_ornament - @offset

    defb &2e                        ; [&2e-&2f] -> c = [&00-&01]
    defb @cmd.instrument_inversion - @offset

    defb &21                        ; [&21-2&d] -> c = [&00-&0c]
    defb @cmd.envelope - @offset

    defb &11                        ; [&11-&20] -> c = [&00-&0f]
    defb @cmd.volume_reduction - @offset

    defb &0f                        ; [&0f-&10] -> c = [&00-&01]
    defb @cmd.extended_noise - @offset

    defb &00                        ; [&00-&0f] -> c = [&00-&0f]
    defb @cmd.tune_delay - @offset

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
    ld hl,0
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
    ld hl,0
    call @bc.eq.section.c
    ld (ix+@ch.ptr.instrument.start  ),c
    ld (ix+@ch.ptr.instrument.start+1),b

    ld hl,@instrument.none
    ld (ix+@ch.ptr.instrument.loop  ),l
    ld (ix+@ch.ptr.instrument.loop+1),h

    jr @set.instrument

;==============================================
@cmd.set_ornament:

; input
;   c = [&00-&1f]

@var.ornaments:
    ld hl,0
    call @bc.eq.section.c
    ld (ix+@ch.ptr.ornament.start  ),c
    ld (ix+@ch.ptr.ornament.start+1),b

    ld hl,@ornament.none
    ld (ix+@ch.ptr.ornament.loop  ),l
    ld (ix+@ch.ptr.ornament.loop+1),h

    jr @set.ornament

;==============================================
@get.note:

; input
;   b  = counter channel
;           6       0 freq noise generator 0
;           5       1 freq internal envelope clock
;           4       2

;           3       3 freq noise generator 1
;           2       4 freq internal envelope clock
;           1       5
;   ix = ptr.channel
;
; BUG: envelope set in channel 3 sets incorrect envelope generator
;----------------------------------------------

    dec (ix+@ch.delay.next_note)
    ret p           ; ret when (ix+@ch.delay.next_note) > 0

    ld a,b
    cp 3            ; !!! bug - should be cp 4 according to DTA
    ld hl,@out + saa.register.envelope_generator_0
    jr nc,$+3       ; b >= 3 (-> channel <= 3, should be <= 2)
    inc hl          ; hl = envelope_generator_1
    ld (@ptr.envelope_generator+1),hl

@get.note.again:
    ld e,(ix+@ch.ptr.track  )
    ld d,(ix+@ch.ptr.track+1)

@get.command:

    ld hl,@list.commands - 1

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

    ld (ix+@ch.note),c

    ld c,(ix+@ch.ptr.instrument.start  )
    ld b,(ix+@ch.ptr.instrument.start+1)

;----------------------------------------------
@set.instrument:

    ld (ix+@ch.ptr.instrument  ),c
    ld (ix+@ch.ptr.instrument+1),b

    ld c,(ix+@ch.ptr.ornament.start  )
    ld b,(ix+@ch.ptr.ornament.start+1)

;----------------------------------------------
@set.ornament:

    ld (ix+@ch.ptr.ornament  ),c
    ld (ix+@ch.ptr.ornament+1),b

    ld (ix+@ch.delay.next_ornament),1
    ld (ix+@ch.delay.next_instrument),1
    ld (ix+@ch.delay.next_volume),1

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
    ld (0),a                ; @out + saa.register.envelope_generator_0 or 1

    jr @get.command

;==============================================
@cmd.instrument_inversion:  ; turn on or off instrument inversion

; input
;   c = [&00-&01]

    ld (ix+@ch.instrument.inversion),c

    jr @get.command

;==============================================
@cmd.tune_delay:

; input
;   c = [&00-&0f]

    ld a,c
    inc a
    ld (@var.tune_delay+1),a

    jr @get.command

;==============================================
@cmd.volume_reduction: ; volume reduction

; input
;   c = [&00-&0f]

    ld (ix+@ch.volume.reduction),c

    jr @get.command

;==============================================
@cmd.extended_noise:

; input
;   c = [&00-&01]

    jr z,@extended_noise.off

    ld c,saa.noise_0.variable

@extended_noise.off:
    ld hl,(@ptr.envelope_generator+1)   ; hl = @out.envelope_generator_0 or 1
    inc hl
    inc hl
    ld (hl),c                           ; hl = @var.noise.0 or 1

    jr @get.command

;==============================================
@cmd.stop_sound:

    ld bc,@instrument.none
    jr @set.instrument

;==============================================
@cmd.set_delay_next_note:

; input
;   c = [&00-&2d]

    ld (ix+@ch.delay.next_note),c
    ld (ix+@ch.ptr.track  ),e
    ld (ix+@ch.ptr.track+1),d

    ret

;==============================================
@cmd.end_of_track:

    call @read.song_table

    jp @get.note.again

;==============================================
@handle.instrument.loop_or_delay:

    cp &7f                      ; a was &fe
    jr z,@set.instrument_loop

    cp &7e                      ; a was &fc
    jr z,@get.instrument_loop

    add a,2
    ld c,a                      ; delay until next command
    jr @handle.instrument

;----------------------------------------------
@set.instrument_loop:

    ld (ix+@ch.ptr.instrument.loop  ),l
    ld (ix+@ch.ptr.instrument.loop+1),h
    jr @handle.instrument

;----------------------------------------------
@get.instrument_loop:

    ld l,(ix+@ch.ptr.instrument.loop  )
    ld h,(ix+@ch.ptr.instrument.loop+1)
    jr @handle.instrument

;==============================================
@handle.ornament.loop_or_delay:

    inc a
    jr z,@get.ornament_loop     ; a was &ff

    inc a
    jr z,@set.ornament_loop     ; a was &fe

    sub 8 * 12
    ld c,a                      ; c = delay until next command
    jr @handle.ornament

;----------------------------------------------
@get.ornament_loop:

    ld l,(ix+@ch.ptr.ornament.loop  )
    ld h,(ix+@ch.ptr.ornament.loop+1)
    jr @handle.ornament

;----------------------------------------------
@set.ornament_loop:

    ld (ix+@ch.ptr.ornament.loop  ),l
    ld (ix+@ch.ptr.ornament.loop+1),h
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

    ld e,(ix+@ch.ptr.instrument.pitch  )
    ld d,(ix+@ch.ptr.instrument.pitch+1)
    dec (ix+@ch.delay.next_instrument)
    ld l,(ix+@ch.ptr.instrument  )
    ld h,(ix+@ch.ptr.instrument+1)
    jr nz,@no.instrument.change

    ld c,1
@handle.instrument:
    ld a,(hl)
    inc hl
    rrca
    jr nc,@handle.instrument.loop_or_delay  ; a = even - returns c with delay until next command

    ld (ix+@ch.delay.next_instrument),c
    ld (ix+@ch.ptr.instrument.pitch+1),a
    ld e,(hl)
    ld d,a
    ld (ix+@ch.ptr.instrument.pitch),e
    inc hl

@no.instrument.change:
    push hl
    ld a,(ix+@ch.ornament.note)
    dec (ix+@ch.delay.next_ornament)
    jr nz,@no.ornament.change

    ld c,1
    ld l,(ix+@ch.ptr.ornament  )
    ld h,(ix+@ch.ptr.ornament+1)
@handle.ornament:
    ld a,(hl)
    inc hl
    cp 8 * 12                               ; ornament values capped at 8 octaves
                                            ; since they wrap around anyway
    jr nc,@handle.ornament.loop_or_delay    ; a >= 8 * 12

    ld (ix+@ch.delay.next_ornament),c
    ld (ix+@ch.ornament.note),a
    ld (ix+@ch.ptr.ornament  ),l
    ld (ix+@ch.ptr.ornament+1),h

@no.ornament.change:
    add a,(ix+@ch.note)
    cp 8 * 12 - 1
    ld hl,&07ff     ; maximum octave (7) + note (&ff)
    jr z,@max_note  ; a == &5f

@var.pattern.height:
    add a,0         ; set
    jr nc,$+4
    sub 8 * 12

    ld hl,&ff0c         ; h = -1, l = 12
    ld b,h
@loop:
    inc h
    sub l               ; l = 12 = octave
    jr nc,@-loop
                        ; h = octave
    ld c,a
    ld a,h
    ld hl,@frequency.note + 12
    add hl,bc
    ld l,(hl)
    ld h,a              ; hl = octave + frequency
@max_note:
    add hl,de           ; de = instrument.pitch
    ld a,h
    and &07             ; prevent octave overflow
    ld h,a

    ld a,d
    rrca
    rrca
    rrca
    and &0f
    ex af,af'           ; a' used by @get.noise to fill bit 7 of h & bit 7 of l

    ex de,hl
    pop hl              ; <- @ch.ptr.instrument
    ld a,(ix+@ch.volume)
    dec (ix+@ch.delay.next_volume)
    jr nz,@no.volume.change

    ld a,(hl)
    inc hl
@var.default_volume_delay:
    cp 0
    jr nz,@handle.volume.delay

    ld c,(hl)           ; delay next volume change
    inc hl
@get.volume.hl:
    ld a,(hl)           ; volume
    inc hl
@use.volume.a:
    ld (ix+@ch.delay.next_volume),c

@no.volume.change:
    ld (ix+@ch.ptr.instrument  ),l
    ld (ix+@ch.ptr.instrument+1),h
    ld (ix+@ch.volume),a
    ex de,hl
    ld b,(ix+@ch.volume.reduction)

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

    ld a,(ix+@ch.instrument.inversion)
    or a
    ld a,e
    jr nz,@inverted

    ld a,d
    ld d,e

@inverted:
    call @swap.nibbles.a
    or d

    ret

;==============================================
@handle.volume.delay:

; input
;   a = value to lookup

; output
;   c = value of entry that matches b

    push hl
    ld b,a
@var.volume_delay:
    ld hl,0
@find:
    ld a,(hl)
    or a
    jr z,@not_found

    inc hl
    ld c,(hl)
    inc hl
    cp b
    jr nz,@-find

    pop hl
    jr @get.volume.hl

;----------------------------------------------

@not_found:
    pop hl
    ld c,1
    ld a,b
    jr @use.volume.a

;----------------------------------------------

@str.channel.0:

    org 0

@ch.ptr.track:              defw 0
@ch.ptr.instrument:         defw 0
@ch.ptr.instrument.loop:    defw 0
@ch.ptr.ornament:           defw 0
@ch.ptr.ornament.loop:      defw 0
@ch.ptr.instrument.pitch:   defw 0

@ch.volume:                 defb 0
@ch.ornament.note:          defb 0
@ch.note:                   defb 0

@ch.ptr.instrument.start:   defw 0
@ch.ptr.ornament.start:     defw 0

@ch.delay.next_note:        defb 0
@ch.delay.next_ornament:    defb 0
@ch.delay.next_instrument:  defb 0
@ch.delay.next_volume:      defb 0

@ch.instrument.inversion:   defb 0
@ch.volume.reduction:       defb 0

@str.channel.size: equ $

    org @str.channel.0 + @str.channel.size

@str.channel.1: defs @str.channel.size
@str.channel.2: defs @str.channel.size
@str.channel.3: defs @str.channel.size
@str.channel.4: defs @str.channel.size
@str.channel.5: defs @str.channel.size

@out:

        defb 0          ; &00 amplitude_0
        defb 0          ; &01 amplitude_1
        defb 0          ; &02 amplitude_2
        defb 0          ; &03 amplitude_3
        defb 0          ; &04 amplitude_4
        defb 0          ; &05 amplitude_5
        defb 0          ; ---
        defb 0          ; ---
        defb 0          ; &08 frequency_tone_0
        defb 0          ; &09 frequency_tone_1
        defb 0          ; &0a frequency_tone_2
        defb 0          ; &0b frequency_tone_3
        defb 0          ; &0c frequency_tone_4
        defb 0          ; &0d frequency_tone_5
        defb 0          ; ---
        defb 0          ; ---
        defb 0          ; &10 octave_1_0
        defb 0          ; &11 octave_3_2
        defb 0          ; &12 octave_5_4
        defb 0          ; ---
        defb 0          ; &14 frequency_enable
        defb 0          ; &15 noise_enable
        defb 0          ; &16 noise_generator_1_0
        defb 0          ; ---
        defb 0          ; &18 envelope_generator_0
        defb 0          ; &19 envelope_generator_1

@var.noise.0:   defb 0
@var.noise.1:   defb 0

@out.size: equ $ - @out

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
    ld a,(bc)
    inc bc
    ld (@var.default_volume_delay+1),a
    ld (@var.volume_delay+1),bc

    ld hl,@str.channel.0
    ld b,6 * @str.channel.size + @out.size
    xor a
@loop:
    ld (hl),a
    inc hl
    djnz @-loop

    inc a                   ; -> a = 1
    ld (@var.delay+1),a

    ld ix,@str.channel.0
    ld de,@str.channel.size

    ld b,6
@loop:
    ld (ix+@ch.delay.next_ornament),a    ; a = 1
    ld (ix+@ch.delay.next_instrument),a  ; a = 1
    ld (ix+@ch.delay.next_volume),a      ; a = 1

    ld hl,@instrument.none
    ld (ix+@ch.ptr.instrument.start  ),l
    ld (ix+@ch.ptr.instrument.start+1),h

    ld (ix+@ch.ptr.instrument  ),l
    ld (ix+@ch.ptr.instrument+1),h

    ld hl,@ornament.none
    ld (ix+@ch.ptr.ornament.start  ),l
    ld (ix+@ch.ptr.ornament.start+1),h
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
    ld hl,0

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
    ld hl,0
    call @bc.eq.section.c
    ld (@str.channel.0+@ch.ptr.track),bc

    call @bc.eq.section
    ld (@str.channel.1+@ch.ptr.track),bc

    call @bc.eq.section
    ld (@str.channel.2+@ch.ptr.track),bc

    call @bc.eq.section
    ld (@str.channel.3+@ch.ptr.track),bc

    call @bc.eq.section
    ld (@str.channel.4+@ch.ptr.track),bc

    call @bc.eq.section
    ld (@str.channel.5+@ch.ptr.track),bc

    ret

;==============================================
@song_table.get_loop:

@var.song_table_loop:
    ld hl,0
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

; easier to debug module when aligned
; align &1000

module:
