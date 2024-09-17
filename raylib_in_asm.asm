global main
	extern InitWindow
	extern SetTargetFPS
	extern DrawCircle
	extern WindowShouldClose
	extern ClearBackground
	extern CloseWindow
	extern BeginDrawing
	extern EndDrawing
main:
	; epilouge  
	push rbp 
	mov rbp, rsp 
	sub rsp, 16
	
	mov rdx, window_title 
	mov rsi, 500  
	mov rdi, 500
	call InitWindow

	mov rdi, 60 
	call SetTargetFPS
	
	jmp gameloop

logic:

	call BeginDrawing

	mov rdi, 0xFF000000
	call ClearBackground

	; Draw the ball 
	mov rdx, 0xFF00FFFF
	movss xmm0, [ball_size]
	mov rsi, [ball_y] 
	mov rdi, [ball_x]
	call DrawCircle
	
	call EndDrawing

gameloop:
	call WindowShouldClose
	cmp rax, 1
	jnz logic

prolouge:
	call CloseWindow
	; prolouge 
	add rsp, 16
	mov rsp, rbp 
	pop rbp
exit:
	; exit
	mov rax, 60
	mov rdi, 0 
	syscall

section .data 
	window_title db "Pong asm"
	ball_size dd 10.0
	ball_x dd 250 
	ball_y dd 250
