;  ========================================================================
;
;  (C) Copyright 2023 by Molly Rocket, Inc., All Rights Reserved.
;
;  This software is provided 'as-is', without any express or implied
;  warranty. In no event will the authors be held liable for any damages
;  arising from the use of this software.
;
;  Please see https://computerenhance.com for more information
;
;  ========================================================================

;  ========================================================================
;  LISTING 144
;  ========================================================================

global read_x1_asm
global read_x2_asm
global read_x3_asm
global read_x4_asm

section .text

;
; NOTE(casey): These ASM routines are written for the Windows
; 64-bit ABI. They expect the count in rcx and the data pointer in rdx.
;

read_x1_asm:
	align 64
.loop:
    mov rax, [rdx]
    sub rcx, 1
    jnle .loop
    ret

read_x2_asm:
    align 64
.loop:
    mov rax, [rdx]
    mov rax, [rdx]
    sub rcx, 2
    jnle .loop
    ret

read_x3_asm:
    align 64
.loop:
    mov rax, [rdx]
    mov rax, [rdx]
    mov rax, [rdx]
    sub rcx, 3
    jnle .loop
    ret

read_x4_asm:
    align 64
.loop:
    mov rax, [rdx]
    mov rax, [rdx]
    mov rax, [rdx]
    mov rax, [rdx]
    sub rcx, 4
    jnle .loop
    ret
