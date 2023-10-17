ORG	0
acall	CONFIGURE_LCD
mov	DPTR, #input_str
;use R5 to store the multiplier count.
;use R6 to store the sum of the input.

DATA_LOOP:
	movc	A, @A+dptr
	jz	keyboard_loop
	acall	SEND_DATA
	clr	A
	inc	dptr
	sjmp	DATA_LOOP

KEYBOARD_LOOP:
	acall	KEYBOARD
	acall SEND_DATA
	sjmp CHECK_A
	;sjmp	KEYBOARD_LOOP

CHECK_A:
	;acall KEYBOARD
	cjne A, #'A', CONVERT_TO_HEX
	mov A, #0C0h
	acall send_command ; force cursor to the second line of the LCD
	mov A, #'('
	sjmp PRIME_ITERATOR

CONVERT_TO_HEX:
	cjne A, #40h, CHECK_40H

CHECK_40H:
	jc CONVERT_TO_NUM
	subb A, #37h
	sjmp STORE_INPUT

CONVERT_TO_NUM:
	SUBB A, #30h

STORE_INPUT:
	mov B, R5
	push ACC
	mov	DPTR, #DECIMALS
	mov A, R5
	movc	A, @A+DPTR
	pop B
	mul AB
	add A, R6
	mov R6, A
	inc R5
	sjmp keyboard_loop

DPTR_SET:
	mov	DPTR, #prime_numbers
PRIME_ITERATOR:
	clr	A
	movc	A, @A+DPTR
	mov B, A
	mov A, R6 ;making sure A/B.
	div AB ;if remainder(B) is not 0, move to the next line, but if 0, iterate with the same prime number.
	push ACC
	mov A, B
	JZ CONVERT_TO_ASCII ;if Remainder is zero
	inc DPTR
	sjmp PRIME_ITERATOR

CONVERT_TO_ASCII:
	clr	C		; Clear the Carry Flag
	subb	A, #0AH		;Subtract 0AH from A
	jc	NUM		; When a carry is present, A is numeric
	add	A, #41H		;Add 41H for Alphabet
	sjmp	STORE		; Jump to store the value

NUM:
	mov	A, R0		; Copy R0 to A
	add	A, #30H		; Add 30H with A to get ASCII

STORE:
	;MOV R0,#30H; Point the destination location
	acall	send_data	; Store A content to the memory location pointed by R0
	mov A, #','
	pop ACC
	cjne A, #1, PRIME_ITERATOR
	ljmp DONE


PRIME_NUMBERS:	DB	2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251

INPUT_STR:	DB	'INPUT=', 0

DECIMALS: DB 100, 10, 1


;CONFIG CODE FOR PROTEUS SIMULATION ENVIRONMENT

CONFIGURE_LCD:			;THIS SUBROUTINE SENDS THE INITIALIZATION COMMANDS TO THE LCD
	mov	a, #38H		;TWO LINES, 5X7 MATRIX
	acall	SEND_COMMAND
	mov	a, #0FH		;DISPLAY ON, CURSOR BLINKING
	acall	SEND_COMMAND
	mov	a, #06H		;INCREMENT CURSOR (SHIFT CURSOR TO RIGHT)
	acall	SEND_COMMAND
	mov	a, #01H		;CLEAR DISPLAY SCREEN
	acall	SEND_COMMAND
	mov	a, #80H		;FORCE CURSOR TO BEGINNING OF THE FIRST LINE
	acall	SEND_COMMAND
	ret

SEND_COMMAND:
	mov	p1, a		;THE COMMAND IS STORED IN A, SEND IT TO LCD
	clr	p3.5		;RS=0 BEFORE SENDING COMMAND
	clr	p3.6		;R/W=0 TO WRITE
	setb	p3.7		;SEND A HIGH TO LOW SIGNAL TO ENABLE PIN
	acall	DELAY
	clr	p3.7
	ret


SEND_DATA:
	mov	p1, a		;SEND THE DATA STORED IN A TO LCD
	setb	p3.5		;RS=1 BEFORE SENDING DATA
	clr	p3.6		;R/W=0 TO WRITE
	setb	p3.7		;SEND A HIGH TO LOW SIGNAL TO ENABLE PIN
	acall	DELAY
	clr	p3.7
	ret


DELAY:
	push	0
	push	1
	mov	r0, #50
DELAY_OUTER_LOOP:
	mov	r1, #255
	djnz	r1, $
	djnz	r0, DELAY_OUTER_LOOP
	pop	1
	pop	0
	ret


KEYBOARD:			;takes the key pressed from the keyboard and puts it to A
	mov	P0, #0ffh	;makes P0 input
K1:
	mov	P2, #0		;ground all rows
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, K1
K2:
	acall	DELAY
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, KB_OVER
	sjmp	K2
KB_OVER:
	acall	DELAY
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, KB_OVER1
	sjmp	K2
KB_OVER1:
	mov	P2, #11111110B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_0
	mov	P2, #11111101B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_1
	mov	P2, #11111011B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_2
	mov	P2, #11110111B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_3
	ljmp	K2

ROW_0:
	mov	DPTR, #KCODE0
	sjmp	KB_FIND
ROW_1:
	mov	DPTR, #KCODE1
	sjmp	KB_FIND
ROW_2:
	mov	DPTR, #KCODE2
	sjmp	KB_FIND
ROW_3:
	mov	DPTR, #KCODE3
KB_FIND:
	rrc	A
	jnc	KB_MATCH
	inc	DPTR
	sjmp	KB_FIND
KB_MATCH:
	clr	A
	movc	A, @A+DPTR	; get ASCII code from the table 
	ret

;ASCII look-up table 
KCODE0:	DB	'1', '2', '3', 'A'
KCODE1:	DB	'4', '5', '6', 'B'
KCODE2:	DB	'7', '8', '9', 'C'
KCODE3:	DB	'*', '0', '#', 'D'

DONE:
	mov A, #')'
	acall send_data
END

