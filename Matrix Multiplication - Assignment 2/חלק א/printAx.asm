; NOAM RAHAT - 205918360
; EVIATAR COHEN - 205913858
; This code presentt the content of 'AX' - register in HEXA on the screen.

.model small
.data
  arr db "0123456789ABCDEF"
  examples dw 0, -357, 12B4h
.stack 100h

.code
START:
	;setting data segment
	mov ax, @data
	mov ds, ax


	;setting extra segment to screen memory
	mov ax, 0B800h
	mov es, ax
	mov cl, 4	;will be used in the isolation procedure
	
	mov di, 0	;let DI be "examples" arry index
	mov si, 0	;SI wil help us droping a line on the screen
l1:
	mov ax, examples[di]
	add si,160d 	;Drop a line on the screen
	
	;dealing with AH value, without changing AX register
	mov bl, ah 
	shr bl, cl			;isolating the 4 msb of AX by shifting 4 bits
	mov bh, 0
	mov bl, arr[bx]		;offset to the hexa digit
	mov bh, 0Fh			;writing to screen memory
	mov es:[280h+96h+si], bx ;printing to the sreen

	mov bl,ah 			;duplicate ax
	shl bl,cl			;isolating the 4 next msb of AX by shifting 4 bits
	shr bl,cl
	mov bh,0
	mov bl, arr[bx]		;offset to the hexa digit
	mov bh,0Fh			;writing to screen memory
	mov es:[280h+98h+si], bx ;printing to the sreen

	;AL - the same process
	;dealing with AL value, without changing AX register
	mov bl,al 			;duplicate ax
	shr bl,cl			;isolating the next 4 msb of AX by shifting 4 bits
	mov bh,0
	mov bl, arr[bx]		;offset to the hexa digit
	mov bh,0Fh			;writing to screen memory
	mov es:[280h+9Ah+si], bx ;printing to the sreen

	mov bl,al ; duplicate ax
	shl bl,cl			;isolating the next 4 LSB of AX by shifting 4 bits
	shr bl,cl
	mov bh,0
	mov bl, arr[bx]		;offset to the hexa digit
	mov bh,0Fh			;writing to screen memory					
	mov es:[280h+9Ch+si], bx ;printing to the sreen
	;promoting index by 2, because "examples" arry is a DW arry.
	add di, 2
	cmp di, 6
jne l1
	

	;return to OS
	mov ax, 4c00h
	int 21h
end START