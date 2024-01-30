global write_x1_asm
global write_x2_asm
global write_x3_asm
global write_x4_asm

section .text

write_x1_asm:
    align 64
    mov rax, 5
.loop:
    mov [rdx], rax
    sub rcx, 1
    jnle .loop
    ret

write_x2_asm:
    align 64
    mov rax, 5
.loop:
    mov [rdx], rax
    mov [rdx+8], rax
    sub rcx, 2
    jnle .loop
    ret

write_x3_asm:
    align 64
    mov rax, 5
.loop:
    mov [rdx], rax
    mov [rdx+8], rax
    mov [rdx+16], rax
    sub rcx, 3
    jnle .loop
    ret

write_x4_asm:
    align 64
    mov rax, 5
.loop:
    mov [rdx], rax
    mov [rdx+8], rax
    mov [rdx+16], rax
    mov [rdx+24], rax
    sub rcx, 4
    jnle .loop
    ret
