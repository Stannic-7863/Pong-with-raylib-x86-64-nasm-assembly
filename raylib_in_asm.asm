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
	extern DrawRectangle
	extern IsKeyDown
main:
	; epilouge  
	push rbp 
	mov rbp, rsp 
	sub rsp, 16
	
	mov rdx, window_title 
	mov rsi, 700  
	mov rdi, 700
	call InitWindow

	mov rdi, 60 
	call SetTargetFPS
	
	jmp gameloop

logic:

paddle_1_movement_up:
	mov rdi, 87 
	call IsKeyDown
	and rax, 1 
	jz paddle_1_movement_down

	mov eax, [paddle_1_y]
	add eax, -5 
	mov [paddle_1_y], eax 

paddle_1_movement_down:	
	mov rdi, 83 
	call IsKeyDown
	and rax, 1 
	jz paddle_2_movement_up

	mov eax, [paddle_1_y]
	add eax, 5 
	mov [paddle_1_y], eax 

paddle_2_movement_up:
	mov rdi, 265 
	call IsKeyDown
	and rax, 1 
	jz paddle_2_movement_down

	mov eax, [paddle_2_y]
	add eax, -5 
	mov [paddle_2_y], eax 

paddle_2_movement_down:	
	mov rdi, 264 
	call IsKeyDown
	and rax, 1 
	jz ballmovement

	mov eax, [paddle_2_y]
	add eax, 5 
	mov [paddle_2_y], eax 

ballmovement:
	mov eax, [ball_y]
	add eax, [ball_vel_y]
	mov [ball_y], eax 

	mov eax, [ball_x]
	add eax, [ball_vel_x]
	mov [ball_x], eax 

	mov eax, [ball_y]
	cmp eax, 0 
	jge checkballlower  

checkballupper:
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
	jle checkcolpaddle1

	mov [ball_y], ebx 
	mov eax, [ball_vel_y]
	imul eax, -1 
	mov [ball_vel_y], eax

checkcolpaddle1: 

	mov eax, [paddle_1_x]
	mov ebx, [ball_x]

	cmp eax, ebx 
	jg checkcolpaddle2

	add eax, [paddle_width]
	cmp eax, ebx 
	jl checkcolpaddle2

	mov eax, [paddle_1_y]
	mov ebx, [ball_y]
	cmp eax, ebx
	jg checkcolpaddle2 

	add eax, [paddle_height]
	cmp eax, ebx 
	jl checkcolpaddle2 

	mov eax, [ball_vel_x]
	imul eax, -1 
	mov [ball_vel_x], eax

checkcolpaddle2: 

	mov eax, [paddle_2_x]
	mov ebx, [ball_x]

	cmp eax, ebx 
	jg drawing

	add eax, [paddle_width]
	cmp eax, ebx 
	jl drawing

	mov eax, [paddle_2_y]
	mov ebx, [ball_y]
	cmp eax, ebx
	jg drawing 

	add eax, [paddle_height]
	cmp eax, ebx 
	jl drawing 

	mov eax, [ball_vel_x]
	imul eax, -1 
	mov [ball_vel_x], eax

drawing:
	call BeginDrawing

	; clear background
	mov rdi, 0xFF000000
	call ClearBackground

	; Draw the ball 
	mov rdx, 0xFF00FFFF
	movss xmm0, [ball_size]
	mov rsi, [ball_y] 
	mov rdi, [ball_x]
	call DrawCircle

	; Draw paddles 
	mov r8, 0xFF00FF00
	mov rcx, [paddle_height]
	mov rdx, [paddle_width]
	mov rsi, [paddle_1_y]
	mov rdi, [paddle_1_x]
	call DrawRectangle

	mov rcx, [paddle_height]
	mov rdx, [paddle_width]
	mov rsi, [paddle_2_y]
	mov rdi, [paddle_2_x]
	call DrawRectangle

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
	ball_x dd 310 
	ball_y dd 310
	ball_vel_y dd -5
	ball_vel_x dd -3

	paddle_1_x dd 10  
	paddle_2_x dd 680  
	paddle_1_y dd 300  
	paddle_2_y dd 300

	paddle_height dd 50 
	paddle_width dd 10
