; לצערנו, לא הצלחנו להשלים את יתר החלקים בעקבות תקופת המבחנים

;EviatarCohen 205913858	
;Noam Rahat 205918360

;this program print a Quote in difffrent speeds

;'D' FASTER PRINT 
;'A' SLOWER PRINT 
;'P' POUSE PRINT

.model small
.data
    FlagCounter dw 0 
    letterCount dw 0
    quote db "It's hardware that makes a machine fast. It's software that makes a fast machine slow."
    color db 0001111b ; first color
    speed dw 16
    flagStop db 0

.stack 100h
.code

set_flag proc
	
	inc FlagCounter	; update counter
	prev_isr:
		int 80h ; use the old interupt
	
	iret
set_flag endp

IVTsetting proc uses ax es
    
    mov ax,0h ; IVT is location is '0000' address of RAM
    mov es,ax
    cli ; block interrupts
    ;moving Int9 into IVT[080h]
    mov ax,es:[1ch*4] ;copying old ISR1c IP to free vector
    mov es:[80h*4],ax
    mov ax,es:[1ch*4+2] ;copying old ISR1c CS to free vector
    mov es:[80h*4+2],ax
    ;moving ISR_New_Int9 into IVT[9]
    mov ax, set_flag ;copying IP of ISR_New to IVT[9]
    mov es:[1ch*4],ax
    mov ax,cs ;copying CS of our ISR_New into IVT[9]
    mov es:[1ch*4+2],ax
    sti ;enable interrupts
    
    ret
IVTsetting endp

reIVTsetting proc uses ax es
	
	mov ax, 0h
	mov es, ax
	cli
	mov ax, es:[80h*4]
	mov es:[1ch*4], ax

	mov ax, es:[80h*4 + 2]
	mov es:[1ch*4 + 2], ax
	sti
	
	ret
reIVTsetting endp

; this func clear the screen
screenInit proc uses cx ax si es
	mov cx, 0FA0h
	balckScreen:
		mov si, cx
		mov ah, ' '
		mov al, 0h
		mov es:[si], al
	loop balckScreen
	ret
screenInit endp

;this func print the letter of the quote
printQoute proc uses bx ax dx si cx
    
    mov si, letterCount
    mov bx, offset quote
	mov al, ds:[bx+si]
    
    
    ; print the letter with *color* background
    mov ah, 09h
    mov bh, 0
    mov bl, color
    mov cx, 1d
    int 10h

    inc letterCount

    ; get cursor position
    mov bh, 0 
    mov ah,3h
    int 10h

    inc dl ; inc cursor position
    mov ah, 2
    int 10h; set cursor position
    
	; COLOR CHAINGING ?
    mov dx, 0
    mov cx, 3
    mov ax, letterCount
    div cx

    cmp dx,0
    jnz sameColor
    add color, 10000b ; color adder 
    sameColor:
    cmp color,01111111b ; last color
    jbe notColor
    mov color, 0001111b ; first color
    notColor:

    
    ret
printQoute endp

; this func take the crouser to the middle of the screen
CursorToMiddle proc uses dx bx ax
    
    mov dh, 12
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h 
    
    ret
CursorToMiddle endp

; this func take the crouser to the end of the screen
resetCursor proc uses dx bx ax
    
    mov dh, 25
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h 
    
    ret
resetCursor endp

;this fucn chainging the speed of the printing
newSpeed PROC uses cx dx ax bx es
    
    mov cx,2
    mov dx,0 

    cmp al, 0A0h ; d key
	je faster

	cmp al, 9Eh ; a key ?
	je slower

	cmp al, 19h ; p ?
	je pouseORcontioue

    jmp funcEnd

faster:
        mov FlagCounter,0
        mov ax, speed
        div cx
        cmp ax, 0
        jne notLIM
        mov ax, 1
        notLIM:
        mov speed, ax
        jmp funcEnd
slower:
        mov FlagCounter,0
        mov ax, speed
        mul cx
        mov speed, ax
        jmp funcEnd
pouseORcontioue:
        cmp flagStop,0
        je stop
resume:
    mov flagStop,0
    jmp funcEnd
stop:
    mov flagStop, 1
    jmp funcEnd
    funcEnd:
    
    ret
newSpeed endp

START:
    
    call IVTsetting
    ;setting data segment
    mov ax, @data
    mov ds, ax
    ;setting extra segment to screen memory
    mov ax, 0b800h
    mov es, ax

	; cancel keybpard interrupts    
    in al, 21h
	or al, 02h
	out 21h, al	
	
	
    call screenInit
    call CursorToMiddle

mainLoop:
    mov ax, 86d ; len of quote
    mov bx, letterCount
    cmp bx, ax
    jge printEnd
    in al, 64h
	TEST al, 01
    jz notChangeSpeed
        
    in al, 60h
    call newSpeed
notChangeSpeed:
    mov cx , speed
    cmp FlagCounter, cx								
    jnz mainLoop
    cmp flagStop, 1
    je noPrint
    call printQoute
noPrint:
        mov FlagCounter, 0 
        jmp mainLoop
    
printEnd:
    call screenInit
    call resetCursor
    call reIVTsetting
    mov al, 0
	out 21h, al
	
    ;return to OS
     mov ax, 4c00h
    int 21h
END START

