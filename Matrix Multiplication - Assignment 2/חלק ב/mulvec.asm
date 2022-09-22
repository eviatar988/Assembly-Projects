
; NOAM RAHAT - 205918360
; EVIATAR COHEN - 205913858
; This code multipli  matrix by vector and store the result in the 'result' array.

.model small
.stack 100h
	N EQU 3
.data
	mat db 2, 3, 1, 0Ah, 8, 1, 0Fh, 5, 4
	vec db 7, 0Dh, 6
	result dw (N) dup(?)
.code
START:
	mov ax, @data
	mov ds, ax
	;setting extra segment to screen memory
	mov ax, 0B800h
	mov es, ax
	
	;multiply matrix by vector let BX be thee voctor index and SI to be the matrix index.
	mov bx, 0		;vecLoop counter (N times)
	mov si, 0		;matrix index[0:N*N-1]
vecLoop:
	mov di, 0		;column counter (N times)
	colLoop:
		mov ax, 0
		mov al, vec[bx]	;ax = vec[bx]
		imul mat[si]	;ax = vec[bx]*matrix[si]
		
		;add to result the current multiplication   
		add result[di], ax
		
		;Index promotion
		inc si
		inc di	;promoting colLoop counter
		cmp di, N
		jne colLoop	
	;Index promotion
	inc bx		;promoting vecLoop counter
	cmp bx, N
	jne vecLoop
	
	
	; return to OS	
	mov ax, 4C00h
	int 21h

end START