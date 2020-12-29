; compiled e-tracker module with retrigger bug
; as can be heard on Pyramex's Sam n Bass
; https://www.youtube.com/watch?v=tytdytuiNEs

@offset: equ $

@start: org 0

defw @song_table
defw @patterns
defw @instruments
defw @ornaments
defw @instrument_delays

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

@track.5:   ; first pattern, channel C
assert $ == &2a

defb &52    ; instrument 1
defb &30    ; ornament 1
defb &03    ; song speed 4
defb &8a    ; note &18 C-3
defb &d2    ; delay next note 0
defb &11    ; volume reduction 0
defb &d2    ; delay next note 0
defb &89    ; note &17 B-2
defb &d3    ; delay next note 1
defb &88    ; note &16 A#2
defb &d3    ; delay next note 1
defb &87    ; note &15 A-2
defb &d5    ; delay next note 3
defb &87    ; note &15 A-2
defb &d5    ; delay next note 3
defb &7e    ; note &0c C-2
defb &d3    ; delay next note 1
defb &53    ; instrument 2
defb &e1    ; delay next note 15
defb &51    ; end of track

@track.6:   ; second pattern, channel c - problem track
assert $ == &3e

defb &52    ; instrument 1  ; this is retriggering note
defb &30    ; ornament 1
defb &03    ; song speed 4
defb &d5    ; delay next note 3
defb &03    ; song speed 4
defb &88    ; note &16 A#2
defb &d3    ; delay next note 1
defb &87    ; note &15 A-2
defb &d5    ; delay next note 3
defb &87    ; note &15 A-2
defb &d5    ; delay next note 3
defb &7e    ; note &0c C-2
defb &d3    ; delay next note 1
defb &53    ; instrument 2
defb &e1    ; delay next note 15
defb &51    ; end of track

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
defb &fe    ; set loop
defb &02
defb &cc
defb &fc    ; get loop

@instrument.2:
assert $ == &7d

defb &fe    ; set loop
defb &00
defb &01
defb &00
defb &ff
defb &ff
defb &fc    ; get loop

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
@instrument_delays:

assert $ == &008c

defb &01        ; default value

defb &02,&04    ; 2 -> delay 4

defb &00        ; end

;----------------------------------------------

@song_table:
assert $ == &0090

defb &61    ; height 1
defb &00    ; pattern 1
defb &03    ; pattern 2
defb &fe    ; set loop
defb &06    ; pattern 3
defb &ff    ; get loop

;----------------------------------------------

@patterns:
assert $ == &0096

; pattern 1

defw @track.1
defw @track.4
defw @track.5   ; ok
defw @track.2
defw @track.2
defw @track.7

; pattern 2

defw @track.2
defw @track.2
defw @track.6   ; problem
defw @track.2
defw @track.2
defw @track.7

; pattern 3

defw @track.3
defw @track.3
defw @track.3
defw @track.3
defw @track.3
defw @track.3

org $ + @offset
