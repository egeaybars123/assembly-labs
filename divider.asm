	org	0000h
	mov	R0, #15H
	mov	R1, #0A0H
	mov	R2, #70H

	mov	40h, R2
	mov	A, R0

SUBTRACT:	
	clr	C
	inc	R3
	jc	INCRQ
	subb	A, R2
	jnc	BORROW
	dec	R1
	cjne	R1, #0H, SUBTRACT
	sjmp	INCRQ

INCRQ:
	inc	R4
	sjmp subtract

BORROW:
	cjne	R1, #0H, SUBTRACT
	cjne	A, 40h, COMPARE
	sjmp	SUBTRACT

COMPARE:	jnc	SUBTRACT
	mov	R5, A



	END

