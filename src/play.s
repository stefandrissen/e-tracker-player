
    org &8000
    dump 1,0

etracker.init:
etracker.play: equ etracker.init + 6

; include "e-tracker player.s"

etracker.init: equ &8000
etracker.play: equ &8006

; mdat "..\songs\Yerzmyey - Arcane Zone Part 2 (2013).cop"
; mdat "..\songs\Pyramex - Nyancat (2005).cop"
; mdat "..\songs\Pyramex, Martin Galway - Ocean Loader v1 (2014).cop"
; mdat "..\songs\Andy Monk - Paradox demo music 4.etc"
; mdat "..\songs\Andy Monk - Paradox demo music 5.etc"
; mdat "..\songs\Roger Hartley - Prophecy....etc"
; mdat "..\songs\Roger Hartley - Sanxion.etc"
; mdat "..\songs\Pyramex, Rob Hubbard - Sanxion SAA Remix (2013).saa"
; mdat "..\songs\Roger Hartley - Starworx.etc"
; mdat "..\songs\Craig Turberfield - The Witching Hour.etc"
; mdat "..\songs\Sean Bernard - STEP OUT (2015).c"
; mdat "..\songs\Pyramex, Rob Hubbard - Thing On A Spring (2013).cop"
; mdat "..\songs\Pyramex - Nameless Shoot'Em Up (2017).cop"
; mdat "..\songs\Pyramex - noname59641.etc"
; mdat "..\songs\Sean Bernard - Pop 'N' Twin Bee.etc"
; mdat "..\songs\Tomkin - Santa Goes Psycho 2 (Game music 2).etc"
; mdat "..\songs\Tomkin - T'n'T Demo.etc"
; mdat "..\songs\Pyramex, Rob Hubbard - Zoids (2014).cop"
; mdat "..\songs\Sean Bernard - BOUNCE! (2015).c"
 mdat "..\songs\Pyramex - sam n bass (2018).etc"
; mdat "..\songs\Sean Bernard - Dance!.etc"
; mdat "..\songs\Pyramex - RobLike-1 (2014).cop"
; mdat "..\songs\Pyramex - Stax intro.etc"
; mdat "..\songs\Pyramex, Ben Daglish - Ark Pandora (Remix) (2013).cmp"
; mdat "..\songs\Stefan Drissen - China Dudeludium (1995).etc"
; mdat "..\songs\Dan Zambonini - Memotech demo 1 (Part I).etc"
; mdat "..\songs\Craig Turberfield - Sophistry - ingame 6.etc"

autoexec

start:
    call etracker.init
;    ld a,&c9                    ; opcode_ret
;    ld (disable_loop),a         ; prevent loop
@loop:
    call etracker.play
    halt
    jr @loop
