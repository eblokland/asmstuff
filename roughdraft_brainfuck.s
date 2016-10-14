.equ lbracket, '[' #Declaring all tokens
.equ rbracket, ']'
.equ smaller, '<'
.equ bigger, '>'
.equ plus, '+'
.equ minus, '-'
.equ comma, ','
.equ period, '.'

.text
	inputtext: .asciz "[]<>+-,."	
	outputstring: .asciz "%c"
.global main
main:
	#WE HAVE TO ALLOC SPACE(probably store it somewhere later)
	leaq	 (inputtext), %rbx
instructionLoop:
#	cmp %asciiaddr, ('AsciCodeAddr')
#	je token1:
	movb (%rbx), %cl
	cmpb $0, %cl
	je end
	cmpb $lbracket, %cl
	je lbrackExecute
	cmpb $rbracket, %cl
	je rbrackExecute
	cmpb $smaller, %cl
	je smallExecute
	cmpb $bigger, %cl
	je bigExecute
	cmpb $plus, %cl
	je plusExecute
	cmpb $minus, %cl
	je minusExecute
	cmpb $comma, %cl
	je commaExecute
	cmpb $period, %cl
	je periodExecute
	
instructionLoopToken:
	incq %rbx	#if we use rbx, restore and pop pls
	jmp instructionLoop

end:
	#stack magic
	#ret
	movq $0, %rax
	call exit

lbrackExecute:
	movq $lbracket, %rsi
	movq $outputstring, %rdi
	movq $0, %rax
	call printf
	jmp instructionLoopToken

rbrackExecute:
	movq $rbracket, %rsi
	movq $outputstring, %rdi
	movq $0, %rax
	call printf
	jmp instructionLoopToken

smallExecute:
	movq $smaller, %rsi
	movq $outputstring, %rdi
	movq $0, %rax
	call printf
	jmp instructionLoopToken

bigExecute:
	movq $bigger, %rsi
	movq $outputstring, %rdi
	movq $0, %rax
	call printf
	jmp instructionLoopToken

plusExecute:
	movq $plus, %rsi
	movq $outputstring, %rdi
	movq $0, %rax
	call printf
	jmp instructionLoopToken

minusExecute:
	movq $smaller, %rsi
	movq $outputstring, %rdi
	movq $0, %rax
	call printf
	jmp instructionLoopToken

commaExecute:
	movq $comma, %rsi
	movq $outputstring, %rdi
	movq $0, %rax
	call printf
	jmp instructionLoopToken

periodExecute:
	movq $period, %rsi
	movq $outputstring, %rdi
	movq $0, %rax
	call printf
	jmp instructionLoopToken

