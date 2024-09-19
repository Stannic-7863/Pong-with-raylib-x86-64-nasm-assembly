	; Todo : Structure code for less repition 


global main
	extern sprintf
	extern IsKeyDown
	extern GetScreenHeight
	extern GetScreenWidth
	extern SetTargetFPS
	extern InitWindow
	extern WindowShouldClose
	extern CloseWindow
	extern BeginDrawing
	extern ClearBackground
	extern EndDrawing
	extern DrawCircle
	extern DrawRectangle
	extern DrawText
main:
	; epilouge  
	push rbp 
	mov rbp, rsp 
	sub rsp, 16

	; create a window 
	mov rdx, window_title 
	mov rsi, 700  
	mov rdi, 700
	call InitWindow

	mov rdi, 60 
	call SetTargetFPS
	; set initial game state 
	jmp reset

inc_score_1:
	mov eax, [score_1]
	add eax, 1
	mov [score_1], eax
	jmp reset

inc_score_2:
	mov eax, [score_2]
	add eax, 1 
	mov [score_2], eax

reset:
	; reset everything to initial state 
	mov ebx, [paddle_height]
	shr ebx, 1

	call GetScreenHeight
	shr eax, 1 

	sub eax, ebx 

	mov [paddle_1_y], eax 
	mov [paddle_2_y], eax 

	mov dword [ball_vel_y], 0

	add eax, ebx 
	mov [ball_y], eax

	call GetScreenWidth
	shr eax, 1

	mov dword [ball_x], eax

logic:
	; just a useless label :)

paddle_1_movement_up:
	; 87 is keycode for W 
	mov rdi, 87 
	call IsKeyDown
	and rax, 1 
	jz paddle_1_movement_down

	mov eax, [paddle_1_y]
	add eax, -5 
	mov [paddle_1_y], eax 

paddle_1_movement_down:	
	; 83 is keycode for S 
	mov rdi, 83 
	call IsKeyDown
	and rax, 1 
	jz paddle_2_movement_up

	mov eax, [paddle_1_y]
	add eax, 5 
	mov [paddle_1_y], eax 

paddle_2_movement_up:
	; 265 is key code for up key 
	mov rdi, 265 
	call IsKeyDown
	and rax, 1 
	jz paddle_2_movement_down

	mov eax, [paddle_2_y]
	add eax, -5 
	mov [paddle_2_y], eax 

paddle_2_movement_down:	
	; 264 is keycode for down key 
	mov rdi, 264 
	call IsKeyDown
	and rax, 1 
	jz paddle_1_bound_up

	mov eax, [paddle_2_y]
	add eax, 5 
	mov [paddle_2_y], eax 

; Limit the paddles to screen only 
paddle_1_bound_up:
	mov ebx, [paddle_1_y]
	cmp ebx, 0 
	jg paddle_1_bound_down 
 
	mov dword [paddle_1_y], 0 

paddle_1_bound_down:
	call GetScreenHeight
	sub eax, [paddle_height]
	cmp ebx, eax 
	jl paddle_2_bound_up

	mov [paddle_1_y], eax 

paddle_2_bound_up:
	mov ebx, [paddle_2_y]
	cmp ebx, 0 
	jg paddle_2_bound_down 
 
	mov dword [paddle_2_y], 0 

paddle_2_bound_down:
	call GetScreenHeight
	sub eax, [paddle_height]
	cmp ebx, eax 
	jl ballmovement 

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

; reverse Y-velocity when ball hits the top or bottom of screen 
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
	jle check_ball_left_right

	mov [ball_y], ebx 
	mov eax, [ball_vel_y]
	imul eax, -1 
	mov [ball_vel_y], eax

; reset and increment score if ball goes out of bound on x axis 
check_ball_left_right: 
	mov ebx, [ball_x]
	cmp ebx, 0 
	jl inc_score_2

	call GetScreenWidth
	cmp ebx, eax 
	jg inc_score_1

; paddle collision code 
checkcolpaddle1: 

	movss xmm0, [ball_size]
	cvttss2si ecx, xmm0

	; if !(ball_x >= paddle_x) 
	mov eax, [paddle_1_x]
	mov ebx, [ball_x]
	cmp eax, ebx 
	jg checkcolpaddle2
	
	; if !(ball_x <= paddle_x + paddle_width) 
	add eax, [paddle_width]
	cmp eax, ebx 
	jl checkcolpaddle2

	; if !(ball_y + offset >= paddle_y) 
	mov eax, [paddle_1_y]
	mov ebx, [ball_y]
	mov edx, ebx 
	add edx, ecx 
	cmp eax, edx
	jg checkcolpaddle2 

	; if !(ball_y - offset <= paddle_y + paddle_height) 
	mov edx, [paddle_height]
	add eax, edx
	sub ebx, ecx
	cmp eax, ebx 
	jl checkcolpaddle2 

	shr edx, 1
	; basically : paddle_y + paddle_height / 2 
	sub eax, edx
	add ebx, ecx 	
	; basically : ((paddle_y + paddle_height / 2 ) - ball_y) / 10
	; The farther away the ball from the center of the paddle 
	; the more y_velocity it shall have  
	sub eax, ebx 
	; https://stackoverflow.com/questions/51717317/dividing-with-a-negative-number-gives-me-an-overflow-in-nasm
	cdq
	mov ebx, -10 
	idiv ebx 

	mov [ball_vel_y], eax 

	mov eax, [ball_vel_x]
	imul eax, -1 
	mov [ball_vel_x], eax
	; if collision jump to drawing since you can't be colliding with two paddles at the same time
	jmp drawing

checkcolpaddle2:

	movss xmm0, [ball_size]
	cvttss2si ecx, xmm0

	; if !(paddle_x < ball_x)
	mov eax, [paddle_2_x]
	mov ebx, [ball_x]
	cmp eax, ebx 
	jg drawing

	; if !(paddle_x + paddle_width > ball_x)
	add eax, [paddle_width]
	cmp eax, ebx 
	jl drawing

	mov eax, [paddle_2_y]
	mov ebx, [ball_y]
	mov edx, ebx 
	add edx, ecx 
	cmp eax, edx
	jg drawing 

	mov edx, [paddle_height]
	add eax, edx
	sub ebx, ecx
	cmp eax, ebx 
	jl drawing 

	shr edx, 1
	sub eax, edx
	add ebx, ecx 	
	sub eax, ebx 
	cdq
	mov ebx, -10 
	idiv ebx 
	mov [ball_vel_y], eax 
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


	; Draw score 
	mov edx, [score_2]
	mov rsi, format_str
	mov rdi, score_buffer
	call sprintf

	call GetScreenWidth
	sub rax, 200 

	mov r8, 0xffdccd00
	mov rcx, 20 
	mov rdx, 20
	mov rsi, rax
	mov rdi, score_buffer
	call DrawText

	mov edx, [score_1]
	mov rsi, format_str
	mov rdi, score_buffer
	call sprintf

	mov r8, 0xffdccd00
	mov rcx, 20 
	mov rdx, 20 
	mov rsi, 200 
	mov rdi, score_buffer
	call DrawText

	call EndDrawing

gameloop:
	; if !(WindowShouldClose()) then go to logic else continue to prolouge then exit 
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
	format_str db "%d", 0x0a, 0x00
	window_title db "Pong asm", 0x00
	ball_size dd 10.0
	ball_x dd 310 
	ball_y dd 310
	ball_vel_y dd 0
	ball_vel_x dd -3

	paddle_1_x dd 10  
	paddle_1_y dd 300  
	paddle_2_x dd 680  
	paddle_2_y dd 300

	score_1 dd 0 
	score_2 dd 0
	score_buffer dd 4

	paddle_height dd 100 
	paddle_width dd 10

