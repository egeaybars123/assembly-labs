org 0000h

WAIT_RECEIVE: mov TMOD, #20h; timer-1, mode-2, 1200 bps
mov TH1, #243
mov TL1, #243
mov SCON, #01010000B ; mode-1 (8-bit UART with data framing), variable baud rate - receiver enabled
mov R1, #7 ;used for going through all the notes.
setb TR1

WAIT_SERIAL:jnb RI,$
clr RI
mov A, SBUF
;mov A, #32h ;used for debugging in MCU8051 IDE.
mov B, #10 ;necessary for determining the interval of notes.

CONVERT_TO_HEX:
	cjne	A, #40h, CHECK_40H ;data coming from terminal is in ASCII

CHECK_40H:
	jc	CONVERT_TO_NUM
	subb	A, #37h
	sjmp	check_validity

CONVERT_TO_NUM:
	clr C
	subb	A, #30h
	cjne A, #10, check_validity

CHECK_VALIDITY: jnc WAIT_RECEIVE
jz WAIT_RECEIVE
clr C
mul AB
mov R2, A
mov R5, A; R4 stores how many 0.5s for a note interval.

START_NOTE:clr TF1
clr TF0
mov TMOD, #00010001b; timer-0, mode-1;; timer-1, mode-1

;RESTART_C_MAJOR: mov R1, #7

RESTART: mov A, R5 ;reload the count of 0.5s for the next note.
mov R2, A

mov A, R1; looping through notes.
mov DPTR, #HIGH_BYTE_NOTE ;load high-byte note
movc A, @A+DPTR
mov R3, A

mov A, R1
mov DPTR, #LOW_BYTE_NOTE
movc A, @A+DPTR
mov R4, A
dec R1

DELAY500ms: mov TH1, #3ch
mov TL1, #0b0h
setb TR1

RELOAD: mov TH0, R3
mov TL0, R4
setb TR0
cpl P1.0

WAIT: jnb TF0, WAIT
clr TF0
jb TF1, DECREMENT
sjmp RELOAD

DECREMENT: clr TF1
djnz R2, DELAY500MS
cjne R1, #0, RESTART
clr TR1
clr TR0
sjmp WAIT_RECEIVE

HIGH_BYTE_NOTE: DB 0FEH,0FEH,0FDH,0FDH,0FDH,0FDH,0FCH,0FCH
LOW_BYTE_NOTE: DB 22H,06H,0C8H,82H,34H,00AH,0ADH,45H

end
