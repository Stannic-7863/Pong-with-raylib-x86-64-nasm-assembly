global main
	extern InitWindow
	extern SetTargetFPS
	extern DrawCircle
	extern WindowShouldClose
	extern ClearBackground
	extern CloseWindow
	extern BeginDrawing
	extern EndDrawing
	extern GetScreenHeight
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

	mov eax, [ball_y]
	add eax, [ball_vel_y]
	mov [ball_y], eax 

	mov eax, [ball_y]
	cmp eax, 0 
	jge checkballlower  

	mov eax, 0 
	mov [ball_y], eax
	mov eax, [ball_vel_y]
	imul eax, -1 
	mov [ball_vel_y], eax

checkballlower:
	call GetScreenHeight
	mov ebx, eax 
	mov eax, [ball_y]
	cmp eax, ebx 
	jle drawing

	mov [ball_y], ebx 
	mov eax, [ball_vel_y]
	imul eax, -1 
	mov [ball_vel_y], eax

drawing:
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
	window_title db "Pong asm", 0x00
	ball_size dd 10.0
	ball_x dd 250 
	ball_y dd 250
	ball_vel_y dd -5 
