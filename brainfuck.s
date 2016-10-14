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

.global brainfuck

format_str: .asciz "We should be executing the following code:\n%s"

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx

	movq %rdi, %rsi
	movq %rsi, %rbx
	movq $format_str, %rdi
	movq $0, %rax
	call printf
	movq $0, %rax

	#WE HAVE TO LLOC SPACE(probably store it somewhere later)
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
	movq $0, %rax
	popq %rbx
	movq %rbp, %rsp
	popq %rbp
	ret
	#ret

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
	movq $minus, %rsi
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
