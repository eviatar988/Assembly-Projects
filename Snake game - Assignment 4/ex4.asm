;Eviatar Cohen 205913858		
;Noam Rahat 205918360
;This function implement the game Snake


.model small
.stack 100h
.data
O_location dw 7D0h
X_location dw 0h
score db -1d
out_msg db 'SCORE:',0Ah,0Dh,'$'
last_scan_code db 0A0h
counter db 0
.code
change_C1_int proc uses cx si ax 
	mov ax,0h ; IVT is location is '0000' address of RAM
	mov es,ax
	cli ; block interrupts
	;moving IntC1 into IVT[080h]
	mov ax,es:[1ch*4] ;copying old ISRC1 IP to free vector
	mov es:[80h*4],ax
	mov ax,es:[1ch*4+2] ;copying old ISRC1 CS to free vector
	mov es:[80h*4+2],ax
	;moving ISR_New into IVT[C1]
	mov ax, offset set_flag ;copying IP of ISR_New to IVT[C1]
	mov es:[1ch*4],ax
	mov ax,cs ;copying CS of our ISR_New into IVT[C1]
	mov es:[1ch*4+2],ax
	sti ;enable interrupts
	
	ret
change_C1_int endp

return_IVT proc
	mov ax,0h ; IVT is location is '0000' address of RAM
	mov es,ax
	cli ; block interrupts
	;copy back IntC1 into IVT[C1h]
	mov ax,es:[80h*4] ;copying old ISRC1 IP to free vector
	mov es:[1ch*4],ax
	mov ax,es:[80h*4+2] ;copying old ISRC1 CS to free vector
	mov es:[1ch*4+2],ax
	
	sti ;enable interrupts
	ret
return_IVT endp

set_flag proc
	
	cmp counter , 2d
	jz flagUp
	inc counter
	jmp always
flagUp:
	mov counter, 0
always:

	int 80h ;use the old interupt
	iret
set_flag endp

;This function initiats the screen
init proc uses cx si ax 
	
	
	mov cx, 0FA0h
	balckScreen:
		mov si, cx
		mov ah, ' '
		mov al, 0h
		mov es:[si], al
	loop balckScreen
	
	mov al, 'O'
	mov ah, 04h ;red
	mov si, O_location
	mov es:[si], ax
	
	ret
init endp

;This function determines the position of the 'X' randomly on the screen and increases the score
newRandomDot proc uses bx dx ax 
	
	inc score

again:
	xor dx,dx
	;get minute to BL
	mov al, 02h
	out 70h, al
	in al, 71h
	mov bl, al
	;get seconed to BH
	mov al, 00h
	out 70h, al
	in al, 71h
	mov bh, al
	;div clock offset (BX) by 4000 
	mov ax,bx
	mov bx, 0FA0h
	div bx
	mov bx, dx ;BX = Random()%4000
	;Updating X Location
	mov X_location, bx
	
	;cheaking if BX place is even
	xor dx, dx
	mov ax, X_location
	mov bx, 2d
	div bx
	cmp dx, 0
	je print 
	dec X_location
	 
	;cheaking if X_location and O_location in the same place
	mov bx, X_location
	mov dx, O_location
	cmp bx,dx
	je again
	
print:
	;Print newRandomDot to the Screen
	mov bx, X_location
	mov al,'X' 
	mov ah, 04h 
	mov es:[bx],ax
	
	ret 
newRandomDot endp

;The following function receives input from the user and moves 'O' accordingly
AutoMove proc uses si ax dx bx 
	
	mov last_scan_code,al
	
	cmp al,0A0h ; Is it the 'd' key ?
	je dPressed
	cmp al,9Eh ; Is it the 'a' key ?
	je aPressed
	cmp al,91h ; Is it the 'w' key ?
	je wPressed
	cmp al,9Fh ; Is it the 's' key ?
	je sPressed
	cmp al,90h ; Is it the 'q' key ?
	je qPressed
	
	jmp out1 
	
	dPressed:
		;pressChecking if O simbole at the left corner	
		mov si, O_location
		xor dx,dx
		mov ax,si
		mov bx,160d
		div bx
		cmp dx,158d
		je out1 
		
		
		mov es:[si], ' '
		add O_location, 2
		mov al, 'O'
		mov ah, 04h ;red
		mov si, O_location
		mov es:[si], ax
		cmp si,X_location ; pressChecking if randomDot = O_location
		jne out1 
		call newRandomDot
		mov counter,0
	jmp out1 
	
	aPressed:
		;pressChecking if O simbole at the left corner	
		mov si, O_location
		xor dx,dx
		mov ax,si
		mov bx,160d
		div bx
		cmp dx,0
		je out1 
		
		mov es:[si], ' '
		sub O_location, 2
		mov al, 'O'
		mov ah, 04h ;red
		mov si, O_location
		mov es:[si], ax
		cmp si,X_location
		jne out1 
		call newRandomDot
		mov counter,0
	jmp out1 
		
	wPressed:
		mov si, O_location
		cmp si,158d ; pressChecking if O simbole at the top
		jbe out1 
		
		mov es:[si], ' '
		sub O_location, 160d
		mov al, 'O'
		mov ah, 04h ;red
		mov si, O_location
		mov es:[si], ax
		cmp si,X_location
		jne out1 
		call newRandomDot
		mov counter,0
	jmp out1 
			
	sPressed:
		mov si, O_location
		cmp si,3840d ; pressChecking if O simbole at the floor
		jge out1 
		
		mov es:[si], ' '
		add O_location, 160d
		mov al, 'O'
		mov ah, 04h ;red
		mov si, O_location
		mov es:[si], ax
		cmp si,X_location
		jne out1 
		call newRandomDot
		mov counter,0
		
	jmp out1 
	
	qPressed:
		;unmasking keybord
		mov al, 0
		out 21h, al
		
		;printing "SCORE:" string 
		mov dx, offset out_msg 
		mov ah, 9 
		int 21h 
		
		;printing score value
		mov dx, 0 
		mov ax , 0                 
		mov al , score
		mov bx ,10
		; print Dozens digit
		div bx       
		mov bx, 0       
		mov bl ,dl 
		add al, 30h
		mov dl , al
		mov ah,2h
		int 21h
		; print Unity digit
		mov dx,0
		mov dl,bl
		add dl, 30h
		mov ah,2h
		int 21h
		
		call return_IVT
		.exit
		
	out1:	
	ret
	
AutoMove endp

;---------------------------------------------------------------------------
main:
	.startup					
	call change_C1_int
	
	;setting extra segment to screen memory 
	mov ax, 0B800h
	mov es, ax
	
	
	call init ; This func resetting the screen to black whith 'O' at the middle
	call newRandomDot ;This func printing 'x' in Random location
	
	; Mask interrupts from keyboard
	in al, 21h
	or al, 02h
	out 21h, al	
	
MainLoop: ; Check if keyboard pressed
    in al, 64h
    test al, 01
    jnz pressCheck ;if pressed, check which botton
    cmp counter, 2d ; else, move in the same direction
    jnz MainLoop
    call AutoMove 
    mov counter,0

pressCheck: ; Check which keyboard pressed
    in al, 60h
    mov cl, last_scan_code
    cmp al, cl
    jz MainLoop ;  if equal,Loop again
    call AutoMove ; otherwise,new botton pressed, go to AutoMove
    jmp MainLoop ; do the same proccess again
      
	.exit
end main