MAXARGS equ 2	
MAXLEN	equ	20

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;

section .data
errArgMessage 	db 	"Error: incorrect argument count.",0,10		
errLenMessage 	db 	"Error: incorrect input length.",0,10		
errCharMessage 	db 	"Error: invalid character encountered.",0,10

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;

section .bss
X 		resb 	20 	
Y 		resd 	20 	
N	 	resd 	1 	
currentChar 	resd 	1 	
fillCounter 	resd 	1	
lyndonCounter 	resd 	1 	
displayCounter 	resd 	1 
flag 		resd 	1 	
intgOffset	resd 	1 	

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;

section .text
global asm_main

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;

asm_main:				
	enter 	0, 0		
	pusha		
	mov 	eax, dword [ebp+8] 	
	cmp 	eax, MAXARGS 		
	je 	numArgsValid 		
	mov 	eax, errArgMessage 	
	call 	print_string		
	call 	print_nl		
	jmp 	mainEnd 		
	
	numArgsValid:
		mov 	eax, dword [ebp+12] 	
		mov 	ebx, dword [eax+4] 
		mov 	[N], dword 0
		jmp 	checkCharLoop		

	checkCharLoop:
		mov 	al, byte[ebx]	
		cmp 	al, 0		
		je 	fillArray		
		
		cmp 	al, 'z'
		jg 	charNotValid		
		
		cmp 	al, 'a'
		jl 	charNotValid 		

		add 	[N], dword 1 	
		cmp 	dword [N], MAXLEN 
		jg 	lenStringNotValid 	

		inc 	ebx 			
		jmp 	checkCharLoop	

	fillArray:
		cmp 	[N], dword 0	
		je 	lenStringNotValid 	

		mov 	[fillCounter], dword 0	
		mov 	eax, dword [ebp+12]	
		mov 	ebx, dword [eax+4]	
		mov 	[currentChar], dword ebx
		
		fillLoop:
			mov 	ebx, dword [currentChar]	
			cmp 	byte[ebx], 0			
			je 	endFill			

			mov 	ecx, X				
			add 	ecx, dword [fillCounter]	
			mov 	al, byte [ebx]		
			mov 	[ecx], al		
			add 	[fillCounter], dword 1		
			add 	[currentChar], dword 1	
			jmp 	fillLoop	

		endFill:				
			mov 	[flag], dword 0		
			jmp 	display	

		startLyndonProcess:	
			jmp 	startLyndon		

	startLyndon:
		mov 	[lyndonCounter], dword 0	
		jmp 	maxLyn				
		endOfLyndon:
		mov 	[flag], dword 1 	
		jmp 	display				
		endOfDisplay:
		cmp 	[flag], dword 1			
		je 	mainEnd 			
		
	charNotValid:
		mov 	eax, errCharMessage
		call 	print_string			
		call 	print_nl
		jmp 	mainEnd 			

	lenStringNotValid:
		mov 	eax, errLenMessage
		call	print_string			
		call 	print_nl
		jmp 	mainEnd			

	mainEnd:
		popa 					
		mov 	eax, 0			
		leave 
		ret					

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;

maxLyn:
	enter 	0, 0 		
	pusha			
	mov 	[intgOffset], dword 0 		

	initialize:
	mov 	edx, [lyndonCounter]

	loopStart:
		mov 	ecx, [N]		
		sub 	ecx, dword 1		
		cmp 	ecx, edx		
		mov 	ecx, dword 1		
		je 	storeValue		

		forLoop:
			add 	edx, dword 1		
			cmp 	[N], edx		
			je 	storeValue		

			mov 	edi, edx	
			sub 	edi, ecx	
				
			mov 	eax, dword 0	
			add 	eax, X		
			add 	eax, edi	
			mov 	al, byte[eax] 	

			mov 	ebx, dword 0	
			add 	ebx, X		
			add 	ebx, edx	
			mov 	bl, byte[ebx]	

			cmp 	al, bl			
			jne 	innerConditional	
			jmp	forLoop 		

		innerConditional:
			cmp 	al, bl			
			jg 	storeValue		
	
			mov 	ecx, 0			
			add 	ecx, edx		
			add 	ecx, dword 1		
			sub 	ecx, [lyndonCounter]	
			jmp 	forLoop			

	storeValue:
		mov 	ebx, dword [lyndonCounter]	
		mov 	eax, dword [N]			
		cmp 	eax, ebx		
		je 	maxLynEnd
		mov 	eax, dword 0			
		add 	eax, Y				
		add 	eax, [intgOffset]		
		add 	[intgOffset], dword 4		

		mov 	[eax], ecx			
		add 	[lyndonCounter], dword 1	
		jmp 	initialize 			

	maxLynEnd:	
		popa			
		jmp 	endOfLyndon	

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;

display:
	enter 	0, 0 		
	pusha			

	mov 	edi, dword [N]
	sub 	edi, dword 1			
	mov 	[displayCounter], dword 0
	mov 	esi, X				
	cmp 	[flag], dword 0
	je 	displayString			
	mov 	edi, dword [N]
	mov 	esi, Y
	mov 	[intgOffset], dword 0
	jmp 	displayIntegers			
	
	displayString:
		cmp 	[displayCounter], edi	
		jg 	displayEndString		

		mov 	edx, X			
		add 	edx, dword [displayCounter]	
		mov 	al, byte [edx]			
		call 	print_char		
		add 	[displayCounter], dword 1	
		jmp 	displayString			

	displayEndString:
		call 	read_char		
		popa 				
		jmp 	startLyndonProcess 

	displayIntegers:
		cmp 	[displayCounter], edi		
		jge 	displayEndInteger		

		mov 	edx, Y			
		add 	edx, dword [intgOffset]	
		mov 	eax, dword [edx]
		call 	print_int			
		mov 	al, ' '				
		call 	print_char			
		add 	[intgOffset], dword 4		
		add 	[displayCounter], dword 1	
		jmp 	displayIntegers		

	displayEndInteger:
		call 	read_char		
		popa				
		jmp 	endOfDisplay		
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;	