
;D-Compiler - decompiles E-Tracker tunes
;(C) 1994 Stefan Drissen
;last update: 1 November, 09:53

               ORG  0
               DUMP 1,0

               JP   start+32768


               DEFM "      D-Compiler version 1.00"
               DEFM "(C) 1994 Stefan Drissen 31.10.94"
               DEFM "--------------------------------"
               DEFM "    "

module:        DEFW 2048

               ORG  102
               DUMP 1,$
exit:
               LD   SP,32768
               LD   HL,0
exit.count:
               DEC  HL
               LD   A,H
               OR   L
               JR   NZ,exit.count

sthmpr:        LD   A,0
               OUT  (251),A
stsptr:        LD   SP,0
               JP   high+32768
high:
stlmpr:        LD   A,0
               OUT  (250),A
               EI
               RET

start:
               DI
               IN   A,(250)
               LD   (stlmpr+32769),A
               IN   A,(251)
               LD   (sthmpr+32769),A
               LD   (stsptr+32769),SP

               LD   A,33
               OUT  (250),A
               LD   SP,32768
               JP   low
low:
               LD   HL,(module)
               LD   (mod.start+1),HL

               CALL calc.addr
               LD   (song.pointer+1),BC
               CALL calc.addr
               LD   (pat.pointer+2),BC
               CALL calc.addr
               LD   (ins.pointer+1),BC
               CALL calc.addr
               LD   (orn.pointer+1),BC
               CALL calc.addr
               LD   A,(BC)
               INC  BC
               LD   (voldatabyte+1),A
               LD   (cmpvollist+1),BC

;============
; song table
;============

               LD   A,emod.page
               OUT  (251),A

               XOR  A
               LD   (esong.lngth),A
               LD   (esong.loop2),A

               LD   HL,esong.table
               LD   DE,esong.table+1
               LD   BC,512-1
               LD   (HL),A
               LDIR

               LD   DE,esong.table

song.pointer:  LD   HL,0
               LD   B,0
nxtpat:        LD   C,(HL)
               INC  HL
               LD   A,C
               INC  A
               JR   Z,song.loop    ;A=255
               INC  A
               JR   Z,set.loop     ;A=254
               SUB  98
               JR   NC,set.height  ;A>=96

               LD   A,C
               LD   C,-1
div3:          INC  C
               SUB  3
               JR   NC,div3
               LD   A,C
               LD   (DE),A
               INC  DE
               LD   A,B
               LD   (DE),A
               INC  DE
               JR   nxtpat
set.height:
               CP   48
               JR   C,nonegpat
               SUB  96
nonegpat:
               DEC  A
               LD   B,A
               JR   nxtpat
set.loop:
               PUSH HL
               PUSH DE
               EX   DE,HL
               LD   DE,esong.table
               OR   A
               SBC  HL,DE
               RR   H
               SRL  L
               LD   A,L
               LD   (esong.loop2),A
               POP  DE
               POP  HL
               JR   nxtpat

song.loop:
               EX   DE,HL
               LD   DE,esong.table
               OR   A
               SBC  HL,DE
               RR   H
               SRL  L
               LD   A,L
               LD   (esong.lngth),A

               LD   HL,esong.table
               LD   BC,0
count.pat:
               LD   A,(HL)
               INC  HL
               INC  HL
               CP   C
               JR   C,$+3
               LD   C,A
               DJNZ count.pat

               INC  C
               LD   A,C
               LD   (num.pats+1),A

;==========
; patterns
;==========

               LD   A,emod.page
               OUT  (251),A

               LD   HL,t.patlen
               LD   DE,t.patlen+1
               LD   BC,31
               LD   (HL),64
               LDIR

               LD   HL,epatterns
               LD   E,32
patalp:
               LD   C,64
patclp:
               LD   B,6
patblp:
               LD   (HL),%10001111
               INC  HL
               LD   (HL),%11111111
               INC  HL
               LD   (HL),%10000000
               INC  HL
               DJNZ patblp
               DEC  C
               JR   NZ,patclp
               BIT  6,H
               RES  6,H
               JR   Z,$+3
               INC  A
               OUT  (251),A
               DEC  E
               JR   NZ,patalp

               LD   A,emod.page
               OUT  (251),A

pat.pointer:   LD   IX,0
               LD   IY,t.patlen
               LD   DE,epatterns
num.pats:      LD   C,0

conv.all:
               LD   B,6
conv.six:
               PUSH BC
               LD   L,(IX+0)
               LD   H,(IX+1)
               INC  IX
               INC  IX
               LD   BC,(mod.start+1)
               ADD  HL,BC
               PUSH DE
               LD   A,31
               LD   (ins),A
               LD   (orn),A
               LD   A,15
               LD   (note),A
               XOR  A
               EX   AF,AF'
               CALL convert
               POP  DE
               INC  DE
               INC  DE
               INC  DE
               POP  BC
               DJNZ conv.six
               EX   AF,AF'
               LD   (IY),A
               INC  IY
               LD   HL,63*6*3
               ADD  HL,DE
               EX   DE,HL

               IN   A,(251)
               BIT  6,D
               RES  6,D
               JR   Z,$+3
               INC  A
               OUT  (251),A

               DEC  C
               JR   NZ,conv.all

               LD   A,emod.page
               OUT  (251),A
               LD   HL,t.patlen
               LD   DE,epatt.lngth
               LD   BC,32
               LDIR

;===========
; ornaments
;===========

               LD   A,emod.page+2
               OUT  (251),A

               LD   HL,eornam.data
               LD   DE,eornam.data+1
               LD   BC,32*256-1
               LD   (HL),0
               LDIR

               LD   HL,t.ornhead
               LD   DE,t.ornhead+1
               LD   BC,32*4-1
               LD   (HL),0
               LDIR

               LD   HL,(cmpvollist+1)
               DEC  HL
orn.pointer:
               LD   DE,0
               OR   A
               SBC  HL,DE
               LD   A,L
               RRCA
               OR   A
               JP   Z,skip.ornament

               LD   IX,(orn.pointer+1)
               LD   IY,t.ornhead
               LD   DE,eornam.data
               LD   B,A
orn.blp:
               PUSH BC
               PUSH DE
               XOR  A
               LD   (orn.loop+1),A
               LD   (orn.count+1),A
               INC  A
               LD   (orn.reg+1),A
               LD   L,(IX+0)
               LD   H,(IX+1)
               INC  IX
               INC  IX
               LD   BC,(mod.start+1)
               ADD  HL,BC
cont.orn:
               LD   A,(HL)
               INC  HL
               CP   96
               JR   C,orn.reg
               INC  A
               JR   Z,orn.loop
               INC  A
               JR   Z,set.ornloop
               SUB  96
               LD   (orn.reg+1),A
               JR   cont.orn
orn.loop:
               LD   A,0
orn.count:     LD   C,0
               DEC  C
               OR   A
               JR   Z,not.looped
               LD   (IY+0),C
               JR   orn.done
not.looped:
               LD   (IY+2),C
               JR   orn.done
set.ornloop:
               LD   A,(orn.count+1)
               LD   (IY+1),A
               LD   A,1
               LD   (orn.loop+1),A
               JR   cont.orn
orn.reg:
               LD   B,0
               LD   C,B
               CP   48
               JR   C,ornlen.blp
               SUB  96
ornlen.blp:
               LD   (DE),A
               INC  DE
               DJNZ ornlen.blp
               LD   A,(orn.count+1)
               ADD  C
               LD   (orn.count+1),A
               LD   A,1
               LD   (orn.reg+1),A
               JR   cont.orn
orn.done:
               LD   DE,4
               ADD  IY,DE
               POP  DE
               INC  D
               POP  BC
               DJNZ orn.blp
skip.ornament:
               LD   A,emod.page
               OUT  (251),A
               LD   HL,t.ornhead
               LD   DE,eorn.header
               LD   BC,32*4
               LDIR

;=============
; instruments
;=============

               LD   A,emod.page+2
               OUT  (251),A

               LD   HL,einstr.data
               LD   DE,einstr.data+4
               LD   BC,16*1024
               LD   (HL),0
               INC  HL
               LD   (HL),%00000100
               INC  HL
               LD   (HL),0
               INC  HL
               LD   (HL),0
               LD   HL,einstr.data
               LDIR

               INC  A
               OUT  (251),A
               RES  6,H
               RES  6,D
               LD   BC,16*1024-4
               LDIR

               DEC  A
               OUT  (251),A

               LD   HL,t.inshead
               LD   DE,t.inshead+1
               LD   BC,32*4-1
               LD   (HL),0
               LDIR

               LD   HL,(orn.pointer+1)
ins.pointer:
               LD   DE,0
               OR   A
               SBC  HL,DE
               LD   A,L
               RRCA

               LD   IX,(ins.pointer+1)
               LD   IY,t.inshead
               LD   DE,einstr.data
               LD   B,A
ins.blp:
               PUSH BC
               PUSH DE
               XOR  A
               LD   (ins.loop+1),A
               LD   (ins.count+1),A
               INC  A
               LD   (dev.count+1),A
               LD   (vol.count+1),A
               LD   L,(IX+0)
               LD   H,(IX+1)
               INC  IX
               INC  IX
               LD   BC,(mod.start+1)
               ADD  HL,BC
cont.ins:
dev.count:     LD   A,0
               DEC  A
               JR   NZ,nodevchange
               LD   A,1
               LD   (dev.count+1),A
retdev:        LD   A,(HL)
               INC  HL
               RRCA
               JR   NC,deviation
               INC  DE
               INC  DE
               INC  DE
               PUSH AF
               AND  %00000111
               LD   B,A
               LD   C,(HL)
               INC  HL
               BIT  2,B
               JR   Z,notnegdev
               PUSH HL
               LD   HL,2048
               OR   A
               SBC  HL,BC
               SET  7,H
               LD   C,L
               LD   B,H
               POP  HL
notnegdev:
               LD   A,B
               LD   (devhi+1),A
               LD   (DE),A
               DEC  DE
               LD   A,C
               LD   (devlo+1),A
               LD   (DE),A
               DEC  DE
               POP  AF
               RRCA
               RRCA
               RRCA
               LD   C,A
               RRCA
               RRCA
               AND  %00000011
               BIT  0,C
               JR   Z,$+4
               SET  2,A
               BIT  1,C
               JR   Z,$+4
               SET  3,A
               LD   (freqnoise+1),A
               LD   (DE),A
               DEC  DE
               JR   dev.reg
deviation:
               CP   127
               JR   Z,set.insloop
               CP   126
               JR   Z,ins.loop
               ADD  A,2
               LD   (dev.count+1),A
               JR   retdev
ins.loop:
               LD   A,0
ins.count:     LD   C,0
               DEC  C
               OR   A
               JR   Z,inot.looped
               LD   (IY+0),C
               JR   ins.done
inot.looped:
               LD   (IY+2),C
               JR   ins.done
set.insloop:
               LD   A,(ins.count+1)
               LD   (IY+1),A
               LD   A,1
               LD   (ins.loop+1),A
               JR   cont.ins

nodevchange:
               LD   (dev.count+1),A
               INC  DE
freqnoise:     LD   A,0
               LD   (DE),A
               INC  DE
devlo:         LD   A,0
               LD   (DE),A
               INC  DE
devhi:         LD   A,0
               LD   (DE),A
               DEC  DE
               DEC  DE
               DEC  DE
dev.reg:
               LD   A,(ins.count+1)
               INC  A
               LD   (ins.count+1),A

vol.count:     LD   A,0
               DEC  A
               JR   NZ,novolchange

               LD   A,(HL)
               INC  HL
voldatabyte:   CP   0
               JR   NZ,newvol

               LD   C,(HL)
               INC  HL
foundvol:      LD   A,(HL)
               INC  HL
retvol:        LD   (volume+1),A
               LD   A,C
               JR   novolchange

newvol:        PUSH HL
               LD   B,A
cmpvollist:    LD   HL,0
nxtinvolst:    LD   A,(HL)
               OR   A
               JR   Z,volnotfound
               INC  HL
               LD   C,(HL)
               INC  HL
               CP   B
               JR   NZ,nxtinvolst
               POP  HL
               JR   foundvol
volnotfound:
               POP  HL
               LD   C,1
               LD   A,B
               JR   retvol
novolchange:
               LD   (vol.count+1),A
volume:        LD   A,0
               LD   (DE),A
               INC  DE
               INC  DE
               INC  DE
               INC  DE
               JP   cont.ins

ins.done:
               LD   DE,4
               ADD  IY,DE
               POP  DE
               INC  D
               INC  D
               INC  D
               INC  D
               IN   A,(251)
               BIT  6,D
               RES  6,D
               JR   Z,$+3
               INC  A
               OUT  (251),A
               POP  BC
               DEC  B
               JP   NZ,ins.blp

               LD   A,emod.page
               OUT  (251),A
               LD   HL,t.inshead
               LD   DE,eins.header
               LD   BC,32*4
               LDIR

               JP   exit

comlist:
               DEFB 210
               DEFW waitnx
               DEFB 114
               DEFW nwnote
               DEFB 082
               DEFW instrm
               DEFB 081
               DEFW patbrk
               DEFB 080
               DEFW cncins
               DEFB 048
               DEFW ornamn
               DEFB 046
               DEFW invert
               DEFB 033
               DEFW envlon
               DEFB 017
               DEFW volred
               DEFB 015
               DEFW extnse
               DEFB 000
               DEFW fspeed

ins:           DEFB 0
orn:           DEFB 0
note:          DEFB 0


envlon:
               INC  HL
               INC  HL
               LD   A,(HL)
               AND  %10000000
               OR   C
               OR   1*16
               LD   (HL),A
               DEC  HL
               DEC  HL
               JR   nxtcommand

volred:
               INC  HL
               INC  HL
               LD   A,(HL)
               AND  %10000000
               OR   C
               OR   4*16
               LD   (HL),A
               DEC  HL
               DEC  HL
               JR   nxtcommand

extnse:
               INC  HL
               INC  HL
               LD   A,(HL)
               AND  %10000000
               OR   C
               OR   5*16
               LD   (HL),A
               DEC  HL
               DEC  HL
               JR   nxtcommand

fspeed:
               INC  C
               INC  HL
               INC  HL
               LD   A,(HL)
               AND  %10000000
               OR   C
               OR   3*16
               LD   (HL),A
               DEC  HL
               DEC  HL
               JR   nxtcommand

invert:
               INC  HL
               INC  HL
               LD   A,(HL)
               AND  %10000000
               OR   C
               OR   2*16
               LD   (HL),A
               DEC  HL
               DEC  HL
               JR   nxtcommand

ornamn:
               LD   A,C
               LD   (orn),A
               AND  %00001111
               LD   B,A
               INC  HL
               LD   A,(HL)
               AND  %11110000
               OR   B
               LD   (HL),A
               INC  HL
               BIT  4,C
               SET  7,(HL)
               JR   NZ,$+4
               RES  7,(HL)
               DEC  HL
               DEC  HL
               JR   nxtcommand


convert:
               EX   DE,HL
nxtcommand:
               PUSH HL
               LD   HL,comlist-3
findcom:       LD   A,(DE)
               INC  HL
               INC  HL
               INC  HL
               SUB  (HL)
               JR   C,findcom
               INC  DE
               LD   C,A
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   H,(HL)
               LD   L,A
               LD   (comjp+1),HL
               POP  HL
comjp:         JP   comjp

waitnx:
               LD   B,0
               INC  C
               EX   AF,AF'
               ADD  C
               EX   AF,AF'
               PUSH HL
               LD   L,C
               LD   H,B
               SLA  C
               RL   B
               ADD  HL,HL
               ADD  HL,HL
               ADD  HL,HL
               ADD  HL,HL
               ADD  HL,BC
               LD   C,L
               LD   B,H
               POP  HL
               ADD  HL,BC

               JR   nxtcommand

nwnote:
               LD   A,C
               LD   B,-1
calcoct:       INC  B
               SUB  12
               JR   NC,calcoct
               ADD  12
               SLA  B
               SLA  B
               SLA  B
               SLA  B
               OR   B
               LD   (note),A
               LD   C,A
               LD   A,(ins)
               BIT  4,A
               JR   Z,$+4
               SET  7,C
               LD   (HL),C
               AND  %00001111
               RLCA
               RLCA
               RLCA
               RLCA
               LD   C,A
               LD   A,(orn)
               AND  %00001111
               OR   C
               INC  HL
               LD   (HL),A
               LD   A,(orn)
               INC  HL
               BIT  4,A
               SET  7,(HL)
               JR   NZ,$+4
               RES  7,(HL)
               DEC  HL
               DEC  HL
               JR   nxtcommand

cncins:
               INC  HL
               INC  HL
               LD   A,(HL)
               AND  %10001111
               OR   6*16
               LD   (HL),A
               DEC  HL
               DEC  HL
               JR   nxtcommand


instrm:
               LD   A,C
               LD   (ins),A

               LD   A,(note)
               BIT  4,C
               JR   Z,$+4
               SET  7,A
               LD   (HL),A

               LD   A,C
               RLCA
               RLCA
               RLCA
               RLCA
               AND  %11110000
               LD   C,A
               LD   A,(orn)
               LD   B,A
               AND  %00001111
               OR   C
               INC  HL
               LD   (HL),A

               INC  HL
               BIT  4,B
               SET  7,(HL)
               JR   NZ,$+4
               RES  7,(HL)

               DEC  HL
               DEC  HL
               JP   nxtcommand
patbrk:
               RET


calc.addr:     LD   C,(HL)
               INC  HL
               LD   B,(HL)
               INC  HL
               PUSH HL
mod.start:     LD   HL,0
               ADD  HL,BC
               LD   C,L
               LD   B,H
               POP  HL
               RET

t.patlen:      ;32
t.ornhead:     ;32*4
t.inshead:     ;32*4

               DEFM "Now for a bit of waffle to fill up the "
               DEFM "remaining space left in this sector.  "
               DEFM "Craig Turberfield is to blame for "
               DEFM "getting me to write this program, it all "
               DEFM "started in Gloucester.   "
end:

emod.page:     EQU  3

eins.header:   EQU  32768
eorn.header:   EQU  32768+128
esong.table:   EQU  32768+256
epatt.lngth:   EQU  32768+768
esong.lngth:   EQU  32768+800
esong.loop2:   EQU  32768+801
epatterns:     EQU  32768+802
eornam.data:   EQU  37666          ;+2 pages
einstr.data:   EQU  45858
