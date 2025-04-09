; bar_demo.asm (version 6)
; Updated 09APR2025
; Ouputs a continuously changing value whose increment is determined by switches
; The leftmost switch makes the increment negative
; The User set the max bar number when the program initialize, they have to then lower all the switches to start the program

ORG 0
Set:
	IN		Switches
    JZERO	Set
    OUT		Bar_max

Wait:
	In		Switches
    JZERO	Loop
    JUMP	Wait

Loop:
	IN		Switches
	STORE	Increment
	SHIFT	-9
	JZERO	Positive    
	JUMP	Negative

Positive:
	LOAD	Increment
	JZERO	Display
	LOAD	Total
	ADDI	1
    STORE	Total
	OUT		Bar
	LOAD	Increment
	ADDI	-1
	STORE	Increment
	JPOS	Positive
    
Negative:
	LOAD	Increment
	JZERO	Display
	LOAD	Total
	ADDI	-1
    STORE	Total
	OUT		Bar
	LOAD	Increment
	ADDI	1
	STORE	Increment
	JNEG	Negative
    
Display:
	LOAD	Total
    OUT		Bar
	OUT		Hex0
	STORE   Total
	CALL    Delay
	JUMP 	Loop

Delay:
	OUT    Timer

WaitingLoop:
	IN     Timer
	ADD    DelayTime
	JNEG   WaitingLoop
	RETURN

; Variables
Total:	   DW 0
DelayTime: Dw -1
Increment: DW 0

; Useful values
Bit0:      DW &B0000000001
Bit9:      DW &B1000000000

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
Bar:	   EQU 006
Bar_max:   EQU 007