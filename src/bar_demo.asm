; IODemo.asm
; Produces a "bouncing" animation on the LEDs.
; The LED pattern is initialized with the switch state.

ORG 0

loop:
	LOAD	Total
	ADD		Increment
    OUT	    Bar
    STORE   Total
    CALL    Delay
    Jump 	loop
    

Delay:
	OUT    Timer
WaitingLoop:
	IN     Timer
	ADD    DelayTime
	JNEG   WaitingLoop
	RETURN

; Variables
Total:	   DW 0
DelayTime: Dw -2
Increment: DW 3000
Time:	   Dw 0
Temp:	   DW 0
Res:	   DW 0
Count:	   DW 0

; Useful values
Bit0:      DW &B0000000001
Bit9:      DW &B1000000000
Zero:	   DW 0
One:	   DW 1
Nine:	   DW 512
Mod:	   DW &B0111111111
Twenty:	   DW 20

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
Bar:	   EQU 006
