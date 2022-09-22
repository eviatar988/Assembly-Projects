.model small
.stack 200h
.data
Number dw 2020h
decimalDigArr db (5) dup (?)
.code

;Input: top stack element (n)
;Output: Prints the following lines:
;In the first line the whole number will appear in its decimal value.
;Next line - the number in its decimal value without its unity digit.
;In the next line - the number in its decimal value without the tens and ones digits, and so on.
;Until the last line is printed with the most significant digit of the number in its decimal value.
numPrefix proc uses dx bp si bx
	;Get AX = Number
	mov bp, sp
	mov ax, [bp + 10]
	
	;stopping condition: ax = 0
	cmp ax, 0
	je finish
	
	;initialize count
	mov si, 0 ;countes number of digits
	mov dx, 0
	
	push ax
	call lastDigIntoStack
	pop ax
	
	call print
	call newline
	
	;Next Call
	mov bx, 10 	;initialize bx to 10
	xor dx, dx	;set dx to 0
	div bx		;AX = AX / 10
	push ax		;Pass new value by stack
	call numPrefix
finish:
	ret 2
numPrefix endp

;Input: AX
;Output: Array of ax value in decimal seperated by digits
lastDigIntoStack proc
	;stopping condition: if AX is zero
	cmp ax, 0
	je DONE
	;initialize bx to 10
	mov bx, 10       
	;extract the last digit DX = remainder (modulus)
	div bx                 	 
	;push it in the memorry
	mov decimalDigArr[si], dl            	 
	;increment the count of digits number
	inc si             	 
	;set dx to 0
	xor dx, dx
	jmp NextCall
DONE:	;when stoping condition exists
	ret
NextCall:
	call lastDigIntoStack
lastDigIntoStack endp

;Input: decimalDigArr
;Output: print decimalDigArr to screen
print proc uses ax dx
	;stopping condition: check if number of digits is greater than zero
	cmp si, 0
	je exit
	
	;pop the top of stack memmory
	mov dl, decimalDigArr[si-1]
	;add 48 so that it represents the ASCII value of digits
	add dl, 48
	
	;interrupt to print a character
	mov ah, 02h
	int 21h
	;decrease the count
	dec si
	
	call print ;repeat
exit:
	ret
print endp

;interupt printing dx value
newline proc uses ax dx
	mov dl, 10	;line feeding
	mov ah, 02h
	int 21h
	mov dl, 13	;carriage return
	mov ah, 02h
	int 21h
	ret
newline endp


main:
	.startup
	;load the value stored in variable Nember into stack
	push ax
		mov ax, Number
		push ax
			call numPrefix
		pop ax
	pop ax

	.exit
end main