.text
inputvar: .long
outputstring: .asciz "%d \n"
newline: .asciz "\n"
assign: .asciz "Assignment 1\newblokland, 4475798\ndbalmashnov, 4542294\n"
.global main
main:  
	movq $0, %rax		#initialize rax to 0, because we don't need vector
	movq $assign, %rdi	#add the adress of the string to register rdi
	call printf	
	call inout

end:
	movq $0, %rdi
	call exit

inout:
	pushq %rbp			
	movq %rsp, %rbp

	subq $8, %rsp			#subtracts 2 bytes from stack pointer(make space)
	leaq -8(%rbp), %rsi		#load adress of stack variable into rsi(second argument)
	movq $inputvar, %rdi		#load the first argument for scan
	movq $0, %rax			#don't need vector
	call scanf			#execute the scanner call

	movq -8(%rbp), %rsi
	incq %rsi
	movq $0, %rax			#still don't need vector
	movq $outputstring, %rdi	#load location of the input as argument for printf
	call printf			#execute the printing call


	movq %rbp, %rsp			
	popq %rbp
	ret
