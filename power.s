.text
formatstring:	.asciz "%ld"
outputstring:	.asciz "The answer is %d\n"
inputstring:	.asciz "Please input the base\n"
inputstring2:	.asciz "Please input the exponent\n"
.global main
main:
	movq $0, %rax			#no vector arg
	movq $inputstring, %rdi		#ready inputstring for printing
	call printf			#print
	call please			#call subroutine for input
	pushq %rsi			#this is our first argument, pushed on the stack

	movq $0, %rax			#no vector arg
	movq $inputstring2, %rdi	#ready inputstring 2 for printing
	call printf			#print
	call please			#call input subroutine again
	pushq %rsi			#second argument pushed on the stack

	call pow			#calculate arg1^arg2
	movq %rbx, %rsi			
	movq $outputstring, %rdi	#ready outputstring for print
	movq $0, %rax			#no vector arg
	call printf			#print result

end:
	movq $0, %rax
	call exit

pow:
	pushq %rbp			#realign stack
	movq %rsp, %rbp			#
	movq $1, %rbx			#initialize total to 1
	movq $0, %rcx			#initialize loopcounter to 0
	movq 16(%rbp), %rdi		#arg2(exp)
	movq 24(%rbp), %rdx		#arg1(base)
powloop:				#start of loop
	imulq %rdx, %rbx		#multiply total by base, store in total
	incq %rcx			#increment loop counter
	cmpq %rdi, %rcx 		#compare loopcounter to exp
	jl powloop			#if loopcounter<exp goto powloop
	movq %rbp, %rsp			#realign stack
	popq %rbp			#
	ret				#

please:
	pushq %rbp			#remove base pointer from stack
	movq %rsp, %rbp			#current stackpointer is new basepointer
	subq $8, %rsp			#allocate space for print
	leaq -8(%rbp), %rsi		#assign this space for scanf
	movq $formatstring, %rdi	#expects %d
	movq $0, %rax			#no vector arg
	call scanf			#call scan
	movq -8(%rbp), %rsi		#save result in rsi
	movq %rbp, %rsp			#basepointer is new stackpointer, signals end of subroutine
	popq %rbp			#push basepointer on stack
	ret				#uses basepointer to return to main
