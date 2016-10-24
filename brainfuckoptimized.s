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
	inputformat: .asciz "%c"
	extratest: .asciz "%d\n"
	outputstring: .asciz "%c"
	outputstringdot: .asciz "%c"
	outputstringtest: .asciz "%c %hu, "

.global brainfuck

format_str: .asciz "We should be executing the following code:\n%s"

# Your brainfuck subroutine will receive one argument:
# a zero terminated string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx		#make sure to push the non-volatile register that we use for our instruction pointer.
	pushq %r12

	movq %rdi, %rsi		#arg 2 for the print
	movq %rsi, %rbx		#store the instruction pointer in rbx 
	movq $format_str, %rdi	#arg1 for the print
	xorq %rax, %rax	
	call printf
	xorq %rax, %rax
	#WE HAVE TO ALLOC SPACE(probably store it somewhere later)
	movq $30000, %rdi	#arg1, amount of elements
	movq $1, %rsi		#arg2, length of 1 element(1byte)
	call calloc		#allocate memory & zero it all
	movq %rax, %r12		#move the pointer to another register for use in the program.
	pushq %rax		#save our pointer to the stack
	#allocate space for new string	
	
	movq %rbx, %rdi#move addr of string to scan into rdi for scasb
	
	xorq %rcx, %rcx
	not %rcx
	
	xorb %al, %al
	cld
repne 	scasb #ancient intel voodoo magic hopefully gives length of string
	
	notq %rcx
	#dec %rcx don't decrement because there needs to be room for a null pointer with the wurst case scenario

	movq %rcx, %rdi
	imulq $3, %rdi
	movq $1, %rsi
	call calloc
	#move new memory pointer into rsi for parser
	pushq %rax #push memory pointer for the parsed string.
	movq %rax, %rsi
	movq %rbx, %rdi
	call strparser
	movq %rax, %rbx #we're going to use the new string now!
#leaving this in for now, it's only for testing the parsed string 
#testprint:
#	cmpb $0, (%rbx)
#	je end
#	xorq %rax, %rax
#	movq $outputstringtest, %rdi
#	movb (%rbx), %sil
#	movw 1(%rbx), %dx
#	call printf
#	addq $3, %rbx
#	jmp testprint
	
instructionLoop:
#	cmp %asciiaddr, ('AsciCodeAddr')
#	je token1:
	movb (%rbx), %cl

	cmpb $period, %cl
	je periodExecute
	jl checkComma
checkBigger:
	cmpb $bigger, %cl
	je bigExecute
	jl smallExecute
checkLeft:
	cmpb $lbracket, %cl
	je lbrackExecute
	jg rbrackExecute
checkComma:
	cmpb $comma, %cl
	je commaExecute
	jg minusExecute
checkPlus:
	cmpb $plus, %cl
	je plusExecute
	jmp end
	
instructionLoopToken:
	addq $3, %rbx	#if we use rbx, restore and pop pls
	jmp instructionLoop

end:
	popq %rdi
	call free
	popq %rdi
	call free #free the two calloc'd thingamabobs
	#stack magictp link t2uh drivers
	xorq %rax, %rax
	popq %r12
	popq %rbx
	movq %rbp, %rsp
	popq %rbp
	ret

lbrackExecute:

	cmpb $0, (%r12)
	jne instructionLoopToken
	
	movzxw 1(%rbx), %r8 #move the offset to r8, zero extending
	imulq $3, %r8 #multiply it by 3
	addq %r8, %rbx #add the offset
	
	jmp instructionLoopToken

rbrackExecute:
	cmpb $0, (%r12)
	je instructionLoopToken
	
	movzxw 1(%rbx), %r8
	imulq $3, %r8
	subq %r8, %rbx

	jmp instructionLoopToken

smallExecute:
	movzxw 1(%rbx), %r8 #zero extends the 16 bit word at 1+rbx and stores it in r8 for subtraction from r12
	subq %r8, %r12
	jmp instructionLoopToken

bigExecute:
	movzxw 1(%rbx), %r8
	addq %r8, %r12	
	jmp instructionLoopToken

plusExecute:
	movb 1(%rbx), %r8b  #LITTLE ENDIAN 
	addb %r8b, (%r12) #i think this will add the least significant byte of the offset to the cell, and since
	#the cell is 1 byte the lopped off MSB should not matter.  i hope.
	jmp instructionLoopToken

minusExecute:
	movb 1(%rbx), %r8b
	subb %r8b, (%r12)
	jmp instructionLoopToken

commaExecute:
	pushq %r13
	movw 1(%rbx), %r13w #use r13w as loop counter
commaLoop:
	movq %r12, %rsi
	movq $inputformat, %rdi
	xorq %rax, %rax			#xor a, a is faster than movq $0
	call scanf
	decw %r13w
	jnz commaLoop  #i doubt there will ever be a use for having a loop here but hey, it's in the spec.

	popq %r13
	jmp instructionLoopToken

periodExecute:
	pushq %r13
	movw 1(%rbx), %r13w
periodLoop:
	movb (%r12), %sil
	movq $outputstringdot, %rdi
	xorq %rax, %rax	
	call printf
	decw %r13w
	jnz periodLoop #basically do while the offset != 0.  offset will always be > 0 to start with

	popq %r13
	jmp instructionLoopToken

#should receive as arguments the string to parse (a pointer to the base) and a pointer to the base of a dest. string
#rdi will be the to parse string, rsi will be the parsed string.  as always shit is byte addressed so don't forget
strparser:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r10
	pushq %rsi
	movw $1, %bx #holds a 16 bit number like offset
	#movq $0, %rbx #same as i in the outline
	movq $0, %r8 #will be the same as itemp in outline.
	movq $0, %r9 #same as depth in the outline
	
parseloop:
	movb (%rdi), %cl
	#check for EOS
	cmpb $0, %cl
	je parseLoopEnd
	movw $1, %bx #set offset for the beginning of the loop

	cmpb $period, %cl
	je periodExeParse
	jl checkCommaParse
checkBiggerParse:
	cmpb $bigger, %cl
	je bigExeParse
	jl checkSmallerParse
checkLeftParse:
	cmpb $lbracket, %cl
	je lbrackExeParse
	#jl parseloop #if it's smaller than lbracket and bigger than a greater then it's invalid.
checkRightParse:
	cmpb $rbracket, %cl
	je rbrackExeParse
checkSmallerParse:
	cmpb $smaller, %cl
	je smallExeParse
	incq %rdi
	jmp parseloop #if it's not equal to anything at this point, it's invalid.
checkCommaParse:
	cmpb $comma, %cl
	je commaExeParse
	jg minusExeParse
checkPlusParse:
	cmpb $plus, %cl	
	je plusExeParse
	incq %rdi
	jmp parseloop
	
	
	
parseLoopEnd:
	popq %rax #put the old pointer for the parsed string into the return register
	movq $0, (%rsi)
	popq %r10
	popq %rbx
	movq %rbp, %rsp
	popq %rbp
	ret #FUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUCK I FORGOT TO RETURN

lbrackExeParse:
#using r9 as depth
	movq $1, %r9
#store rdi on the stack and use as itemp
	pushq %rdi
#using r10 as lastchar
	xorb %r10b, %r10b
lbrackExeLoop:
	incq %rdi #increment at the beginning of the loop so that we begin with the next instruction
	cmpb $0, %r9b #i think this can be removed
	je lBrackLoopEnd #if depth is zero gtfo
	cmpb $lbracket, (%rdi)
	je lbrackadddepth
	cmpb $rbracket, (%rdi)
	je lbracksubdepth
	cmpb %r10b, (%rdi)
	je lBrackLoopBack #if the char is equal to the last char, don't add to the offset.
	call charIsValid
	cmpq $0, %rax #check output of charisvalid
	je lBrackLoopBack #if the char is not valid, don't add to the offset.
lBrackLoopOffset:
	incw %bx
	movb (%rdi), %r10b
lBrackLoopBack:
	#incq %rdi
	jmp lbrackExeLoop

lBrackLoopEnd:
	movb $lbracket, (%rsi)
	movw %bx, 1(%rsi)
	addq $3, %rsi
	popq %rdi #restore rdi to pre-loop value
	incq %rdi #and then increment it
	jmp parseloop

lbrackadddepth:
	incq %r9
	jmp lBrackLoopOffset
lbracksubdepth:
	decq %r9
	jz lBrackLoopEnd
	jmp lBrackLoopOffset

rbrackExeParse:
	#using r9 as depth
	movq $1, %r9
#store rdi on the stack and use register as itemp
	pushq %rdi
	#r10 as lastchar
	xorb %r10b, %r10b #start cleared
rbrackExeLoop:
	decq %rdi #we're going in reverse so instead of incrementing we decrement
	cmpb $0, %r9b #check depth 
	je rbrackLoopEnd
	cmpb $rbracket, (%rdi)
	je rbrackadddepth
	cmpb $lbracket, (%rdi)
	je rbracksubdepth
	cmpb %r10b, (%rdi)
	je rbrackLoopBack
	call charIsValid
	cmpq $0, %rax
	je rbrackLoopBack #somehow i forgot this
rbrackLoopOffset:
	incw %bx
	movb (%rdi), %r10b #set rdi to the new lastchar
rbrackLoopBack:
	#decq %rdi #decrement the bf inst pointer each loop
	jmp rbrackExeLoop

rbrackLoopEnd:
	movb $rbracket, (%rsi)
	movw %bx, 1(%rsi)
	addq $3, %rsi
	popq %rdi
	incq %rdi
	jmp parseloop
	
rbrackadddepth:
	incq %r9
	jmp rbrackLoopOffset
rbracksubdepth:
	decq %r9
	jz rbrackLoopEnd
	jmp rbrackLoopOffset


smallExeParse2:
	incw %bx
smallExeParse:
	incq %rdi
	cmpb $smaller, (%rdi)
	je smallExeParse2
	call charIsValid
	cmpq $0, %rax
	je smallExeParse

	movb $smaller, (%rsi)
	movw %bx, 1(%rsi)
	addq $3, %rsi
	jmp parseloop

bigExeParse2:
	incw %bx
bigExeParse:
	incq %rdi
	cmpb $bigger, (%rdi)
	je bigExeParse2
	call charIsValid
	cmpq $0, %rax
	je bigExeParse

	movb $bigger, (%rsi)
	movw %bx, 1(%rsi)
	addq $3, %rsi
	jmp parseloop

plusExeParse2:
	incw %bx
plusExeParse:
	incq %rdi
	cmpb $plus, (%rdi)
	je plusExeParse2
	call charIsValid
	cmpq $0, %rax
	je plusExeParse

	movb $plus, (%rsi)
	movw %bx, 1(%rsi)
	addq $3, %rsi
	jmp parseloop

minusExeParse2:
	incw %bx
minusExeParse:
	incq %rdi
	cmpb $minus, (%rdi)
	je minusExeParse2
	call charIsValid
	cmpq $0, %rax
	je minusExeParse
	
	movb $minus, (%rsi)
	movw %bx, 1(%rsi)
	addq $3, %rsi
	jmp parseloop
	

commaExeParse2:
	incw %bx
commaExeParse:
	incq %rdi #see period for comments
	cmpb $comma, (%rdi)
	je commaExeParse2
	call charIsValid
	cmpq $0, %rax
	je commaExeParse

	movb $comma, (%rsi)
	movw %bx, 1(%rsi)
	addq $3, %rsi
	jmp parseloop

periodExeParse2:
	incw %bx
periodExeParse:
	incq %rdi #increment the current instruction pointer to look at the next char
	cmpb $period, (%rdi)
	je periodExeParse2 #if the char matches increment bx and continue the looop
	call charIsValid 
	cmpq $0, %rax
	je periodExeParse
	#end of period loop
	movb $period, (%rsi) #put the stuff into the parsed string
	movw %bx, 1(%rsi)
	addq $3, %rsi #increment the pointer to the parsed string
	jmp parseloop
	

#returns true if the character is valid or null.
charIsValid:
	push %rbp
	movq %rsp, %rbp
	movq $0, %rax 
	cmpb $period, (%rdi)
	je charIsValidEnd
	cmpb $smaller, (%rdi)
	je charIsValidEnd
	cmpb $bigger, (%rdi)
	je charIsValidEnd
	cmpb $plus, (%rdi)
	je charIsValidEnd
	cmpb $minus, (%rdi)
	je charIsValidEnd
	cmpb $comma, (%rdi)
	je charIsValidEnd
	cmpb $lbracket, (%rdi)
	je charIsValidEnd
	cmpb $rbracket, (%rdi)
	je charIsValidEnd
	cmpb $0, (%rdi)
	je charIsValidEnd
	movq %rbp, %rsp
	pop %rbp
	ret

charIsValidEnd:
	movq $1, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	

