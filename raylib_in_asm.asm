
global main 
extern InitWindow
extern CloseWindow 
extern WindowShouldClose 
extern BeginDrawing
extern EndDrawing
extern ClearBackground 
extern DrawRectangle
extern SetTargetFPS
extern DrawFPS
extern IsKeyDown
extern DrawCircle
section .text

%define PLT wrt ..plt 

main:
	push rbp  
	mov rbp, rsp

	sub rsp, 64

	mov rdi, 1000    
    mov rsi, 1000 
	lea rdx, [rel title]
	call InitWindow PLT 
	
	mov rdi, 60 
	call SetTargetFPS PLT 
	jmp gameloop	

logic:

paddle_move_up:
	mov rdi, 87
	call IsKeyDown PLT 
	and rax, 1  
	je paddle_move_down

	mov rax, [rel paddle_y]
	add rax, -5 
	mov [rel paddle_y], rax

paddle_move_down:
  	mov rdi, 83
  	call IsKeyDown PLT 
  	and rax, 1  
  	je paddle2_move_up
  	
  	mov rax, [rel paddle_y]
  	add rax, 5 
  	mov [rel paddle_y], rax
 
paddle2_move_up: 
  	mov rdi, 265
  	call IsKeyDown PLT 
  	and rax, 1  
  	je paddle2_move_down
  	
  	mov rax, [rel paddle2_y]
  	sub rax, 5 
  	mov [rel paddle2_y], rax
 
paddle2_move_down: 
  	mov rdi, 264
  	call IsKeyDown PLT 
  	and rax, 1  
  	je Drawing
  	
  	mov rax, [rel paddle2_y]
  	add rax, 5 
	mov [rel paddle2_y], rax
 
Drawing:
  	call BeginDrawing PLT 
	mov rdi, 0xFF181818
	call ClearBackground PLT 
	mov r8, 0xFF00FF00
	mov rcx, [rel height] 
	mov rdx, [rel width]
	mov rsi, [rel paddle_y] 
	mov rdi, [rel paddle_x] 
	call DrawRectangle PLT 

	mov r8, 0xFF00FF00
	mov rcx, [rel height]
	mov rdx, [rel width]
	mov rsi, [rel paddle2_y]
	mov rdi, [rel paddle2_x]
	call DrawRectangle PLT

	mov rcx, 0xFFFFFFFF
	movss xmm0, [rel ball_size]
	mov rsi, [rel ball_y]
	mov rdi, [rel ball_x]
	call DrawCircle PLT

	mov rdi, 10 
	mov rsi, 10 
	call DrawFPS PLT 
  	call EndDrawing PLT 

gameloop:
  	call WindowShouldClose PLT ; stores 1 in rax if user quit 
  	cmp rax, 1 
  	jnz logic ; jnz = jump if not zero
	
	call CloseWindow PLT 
	add rsp, 16
	mov rax, 60 
	mov rdi, 0 
	syscall

section .data 
title db "Big Balls", 0x00

width dd 10 
height dd 50

paddle_x dd 10 
paddle_y dd 250 

paddle2_x dd 500 
paddle2_y dd 250 

ball_x dd 250  
ball_y dd 250
ball_size dd 50.0
