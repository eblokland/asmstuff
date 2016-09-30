.text
inputvar: .asciz "%lld"
outputstring: .asciz "%lld \n"
newline: .asciz "\n"
assign: .asciz "Assignment 1\newblokland, 4475798\ndbalmashnov, 4542294\n"
.global main
main:  
	movq $0, %rax		#initialize rax to 0, because we don't need vector
	movq $assign, %rdi	#add the adress of the string to register rdi
	call printf	
	movq $1, %rdi
	call inout

end:
	movq $0, %rax
	call exit

inout:
	pushq %rbp			
	movq %rsp, %rbp

	subq $8, %rsp			#subtracts 8 bytes from stack pointer(make space)
	leaq -8(%rbp), %rsi		#load adress of stack variable into rsi(second argument)
	movq $inputvar, %rdi		#load the first argument for scan
	movq $0, %rax			#don't need vector
	call scanf			#execute the scanner call

	movq -8(%rbp), %rdi
	call factorial

	movq %rax, %rsi
	movq $0, %rax			#still don't need vector
	movq $outputstring, %rdi	#load location of the input as argument for printf
	call printf			#execute the printing call


	movq %rbp, %rsp			
	popq %rbp
	ret

factorial:
	pushq %rbp
	movq %rsp, %rbp
	#push instrpointer
	cmpq $1, %rdi			#if n = 1, jump to factend
	je factend			#
	push %rdi 			#push currentvalue rdi onto stack
	decq %rdi			#decrement rdi
	call factorial			#call factorial with n = n-1
	popq %rdi			#after factorial has returned, pop last value rdi
	imulq %rax, %rdi 		#multiply return value with last value rdi
factend:
	movq %rdi, %rax
	#after factorial call, pop instr pointer
	movq %rbp, %rsp
	popq %rbp
	ret
