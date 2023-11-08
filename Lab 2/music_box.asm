org 0000h

mov tmod, #00010001b; timer-0, mode-1;; timer-1, mode-1

RESTART_C_MAJOR: mov R1, #7

RESTART: mov R2, #10 ;50000 * 10 = 0.5 seconds

mov A, R1; looping through notes.
mov DPTR, #HIGH_BYTE_NOTE ;load high-byte note
movc A, @A+DPTR
mov R3, A

mov A, R1
mov DPTR, #LOW_BYTE_NOTE
movc A, @A+DPTR
mov R4, A
dec R1

DELAY500ms:mov TH1, #3ch
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
cjne R1, #255, RESTART
sjmp RESTART_C_MAJOR

HIGH_BYTE_NOTE: DB 0FEH,0FEH,0FDH,0FDH,0FDH,0FDH,0FCH,0FCH
LOW_BYTE_NOTE: DB 22H,06H,0C8H,82H,34H,0AH,0ADH,45H

end
