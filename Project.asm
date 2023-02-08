[org 0x0100]
 jmp start
score: dw 0
string: db "Score:"
stend: db "Game Over!"
dino: db 0x00
Tree: db '|'
jump: db 0
flag: db 0
clrscr: 
	push es
	push ax
	push cx
	push di
	mov ax, 0xb800
	mov es, ax ; point es to video base
	xor di, di ; point di to top left column
	mov ax, 0x0720 ; space char in normal attribute
	mov cx, 1800 ; number of screen locations
	cld ; auto increment mode
	rep stosw ; clear the whole screen
	pop di 
	pop cx
	pop ax
	pop es
	ret 


printnum: 
	push es
	push ax
	push bx
	push cx
	push dx
	push di
	mov ax, 0xb800
	mov es, ax ; point es to video base
	mov ax, [score] ; load score in ax
	mov bx, 10 ; use base 10 for division
	mov cx, 0 ; initialize count of digits
	nextdigit:
		mov dx, 0 ; zero upper half of dividend
		div bx ; divide by 10
		add dl, 0x30 ; convert digit into ascii value
		push dx ; save ascii value on stack
		inc cx ; increment count of values
		cmp ax, 0 ; is the quotient zero
		jnz nextdigit ; if no divide it again
		mov di, 174
	nextpos:
		pop dx ; remove a digit from the stack
		mov dh, 0x07 ; use normal attribute
		mov [es:di], dx ; print char on screen
		add di, 2 ; move to next screen location
		loop nextpos ; repeat for all digits on stack
	pop di
	pop dx
	pop cx
	pop bx
	pop ax	
	pop es
	ret



printstr: 				;will print "Score: "
	push es
	push ax
	push cx
	push si
	push di
	mov ax, 0xb800
	mov es, ax ; point es to video base
	mov di, 160 ; point di to top left column
	mov si, string ; point si to string
	mov cx, 6 ; load length of string in cx
	mov ah, 0x07 ; normal attribute fixed in al
nextchar: 
	mov al, [si] ; load next char of string
	mov [es:di], ax ; show this char on screen
	add di, 2 ; move to next screen location
	add si, 1 ; move to next char in string
	loop nextchar ; repeat the operation cx times
	pop di
	pop si
	pop cx
	pop ax
	pop es
	ret 

	


delay:
	push ax
	push bx
	mov ax,0xffff
	mov bx,0xffff
	_delay
		sub ax,1
		__delay:
			sub bx,1
			jnz __delay
		jnz _delay
	pop bx
	pop ax
	ret




game:
	pusha
	push es
	push di
	push si
	mov ax, 0xb800
	mov es, ax; point to video base
	mov ah, 0xce
	mov al, [dino]
	mov bh, 0x26
	mov bl, [Tree]
	mov ch, 0x07
	mov cl, ' '
	mov si, 1620 ;location of drag
	mov di, 1758 ;location of tree
	mov dx, 0
	call base
	_loop:
		call delay
		call printstr
		call printnum
		push ax
		cmp si,1140
		je no_jump
		mov ah,01h
		int 16h
		cmp al,20h
		jne _no_jump
		add byte[jump],1
		mov [es:si],cx
		mov [es:si-160],cx
		mov [es:si-2],cx
		sub si,480
		jmp _no_jump
		no_jump:
			add byte [flag],1
			cmp byte[flag],4   ;it will stay above for 4 cycles
			jne _no_jump
			mov byte[flag],0
			mov [es:si],cx
			mov [es:si-160],cx
			mov [es:si-2],cx
			add si,480		
				
		_no_jump:
		pop ax
		inc word[score]
		mov [es:di+2], cx	;clears tree's old location
		mov [es:di-158], cx
		mov [es:si], ax ;dino print
		mov word[es:si-160],0xce2e ;dino head
		mov word[es:si-2],0x0c5c   ;dino tail
		mov [es:di-160], bx
		mov word[es:di], 0x067c ;tree print
		cmp di, 1600	;if tree has come to left border
		jne continue 
		mov[es:di],cx
		mov[es:di-160],cx
		mov di, 1758	;we place it back to the right border(means it's a new tree)
		continue:
		push ax
		mov ah,0ch
		int 21h
		pop ax
		sub di, 2
		cmp si,di
		jne _loop	;continue till touched
	pop es
	pop di
	pop si
	popa
	ret

base:
	push ax
	push di
	mov ah,0xA2
	mov al,0x2A
	mov di,1758
	baseloop:
		mov[es:di],ax
		add di,2
		cmp di,1920
		jne baseloop
	pop di
	pop ax
	ret


GameOver:
	push es
	push ax
	push cx
	push si
	push di
	mov ax, 0xb800
	mov es, ax ; point es to video base
	mov di,2260  ; point di to top left column
	mov si, stend ; point si to string
	mov cx, 10 ; load length of string in cx
	mov ah, 0x07 ; normal attribute fixed in al
nextchar2: 
	mov al, [si] ; load next char of string
	mov [es:di], ax ; show this char on screen
	add di, 2 ; move to next screen location
	add si, 1 ; move to next char in string
	loop nextchar2 ; repeat the operation cx times
	pop di
	pop si
	pop cx
	pop ax
	pop es
	ret 


start:
	call clrscr
	call game
	call GameOver
	
mov ax, 0x4c00 ; terminate and stay resident
int 21h