
; NOAM RAHAT - 205918360
; EVIATAR COHEN - 205913858
; This code multiplies two matrices and store the result in the 'result' array.

.model small
.stack 100h
	N EQU 3
.data
	mat1 db 2, 3, 1, 0Ah, 8, 1, 0Fh, 5, 4
	mat2 db 7, 0Dh, 6, 1, 2, 3, 1, 2, 3
	result dw (N*N) dup(?)
.code
START:
	mov ax, @data
	mov ds, ax
	;setting extra segment to screen memory
	mov ax, 0B800h
	mov es, ax
	
	
	mov cx, 0		;countes in withc column are we in
countCol:
		;multiply matrix by vector let BP be thee voctor index and SI to be the matrix index.
		mov bp, 0		;vecLoop counter (N times)
		mov si, 0		;matrix index[0:N*N-1]
	vecLoop:
		mov dx, 0		;row counter (N times)
		colLoop:
			;bx = bp + cx
			mov bx, bp
			add bx, cx
			mov ax, 0
			mov al, mat2[bx]	;ax = mat2[bp][cx]
			imul mat1[si]	;ax = mat2[bp][cx]*mat1[si]
			
			;add to result the current multiplication into result[dx][cx]
			mov di, cx
			add di, dx	;di = cx + dx		
			add result[di], ax
			
			;Index promotion
			ADD si,16d
			inc dx	;promoting colLoop counter
			cmp dx, N
			jne colLoop	
		;Index promotion
		inc bp		;promoting vecLoop counter
		cmp bp, N
		jne vecLoop
	;When you finish multipling the matrix by the vector, move on to the next vector
	add cx, N
	cmp cx, N*N
	jne countCol

	; return to OS	
	mov ax, 4C00h
	int 21h

end START