; compiled e-tracker module with retrigger bug
; as can be heard on Pyramex's Sam n Bass
; https://www.youtube.com/watch?v=tytdytuiNEs

@offset: equ $

@start: org 0

defw @song_table
defw @patterns
defw @instruments
defw @ornaments
defw &008c

defm "ETracker (C) BY ESI."

;----------------------------------------------

@track.1:
assert $ == &1e

defb &11
defb &f1
defb &51

@track.2:
assert $ == &21

defb &f1
defb &51

@track.3:
assert $ == &23

defb &d2
defb &51

@track.4:
assert $ == &25

defb &53
defb &31
defb &21
defb &f1
defb &51

@track.5:
assert $ == &2a

defb &52
defb &30
defb &03
defb &8a
defb &d2
defb &11
defb &d2
defb &89
defb &d3
defb &88
defb &d3
defb &87
defb &d5
defb &87
defb &d5
defb &7e
defb &d3
defb &53
defb &e1
defb &51

@track.6:           ; problem track
assert $ == &3e

defb &52
defb &30
defb &03
defb &d5
defb &03
defb &88
defb &d3
defb &87
defb &d5
defb &87
defb &d5
defb &7e
defb &d3
defb &53
defb &e1
defb &51

@track.7:
assert $ == &4e

defb &1a
defb &d2
defb &1b
defb &d2
defb &1c
defb &d2
defb &1d
defb &d2
defb &1e
defb &d2
defb &1f
defb &ec
defb &51

;----------------------------------------------

@ornament.1:
assert $ == &5b

defb &00    ;  0
defb &5f    ; -1
defb &5e    ; -2
defb &5d    ; -3
defb &5c    ; -4
defb &5b    ; -5
defb &5a    ; -6
defb &59    ; -7
defb &58    ; -8
defb &57    ; -9
defb &56    ; -10
defb &55    ; -11
defb &54    ; -12
defb &53    ; -13
defb &52    ; -14
defb &51    ; -15
defb &50    ; -16
defb &ff    ; get loop (none was set)

@ornament.2:
assert $ == &6d

defb &00    ; 0
defb &ff    ; get loop (none was set)

;----------------------------------------------

@instrument.1:
assert $ == &6f

defb &1f
defb &fc
defb &02
defb &cc
defb &02
defb &1f
defb &fd
defb &fe
defb &04
defb &1f
defb &fe
defb &02
defb &cc
defb &fc

@instrument.2:
assert $ == &7d

defb &fe
defb &00
defb &01
defb &00
defb &ff
defb &ff
defb &fc

;----------------------------------------------

@instruments:
assert $ == &0084

defw @instrument.1
defw @instrument.2

;----------------------------------------------

@ornaments:
assert $ == &0088

defw @ornament.1
defw @ornament.2

;----------------------------------------------

assert $ == &008c

defb &01
defb &02
defb &04
defb &00

;----------------------------------------------

@song_table:
assert $ == &0090

defb &61
defb &00
defb &03
defb &fe
defb &06
defb &ff

;----------------------------------------------

@patterns:
assert $ == &0096

defw @track.1
defw @track.4
defw @track.5
defw @track.2
defw @track.2
defw @track.7

defw @track.2
defw @track.2
defw @track.6   ; problem
defw @track.2
defw @track.2
defw @track.7

defw @track.3
defw @track.3
defw @track.3
defw @track.3
defw @track.3
defw @track.3

org $ + @offset
