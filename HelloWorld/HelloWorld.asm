;  Executable name : HelloWorld
;  Version         : 1.0
;  Created date    : 5/9/2025
;  Last update     : 5/9/2025
;  Author          : Mohammed R. Attia
;  Architecture    : x64
;  Description     : A simple program in assembly for x64 Linux, using NASM 2.14,
;                    that outputs "Hello, Wrold!".
;
;  Build using these commands:
;    nasm -f elf64 -g -F stabs eatsyscall.asm
;    ld -o eatsyscall eatsyscall.o
;

section .data
            HelloWorld: db "Hello, World!", 10, 0
            HWLen: equ $-HelloWorld

section .text
global main
main:
    ; output hello world
    mov rax, 1              ; 1 = sys_write
    mov rdi, 1              ; 1 = stdout
    mov rsi, HelloWorld     ; the address of the text
    mov rdx, HWLen          ; the length of the bytes
    syscall
    
    ; exit the program
    mov rax, 60             ; 60 = sys_exit
    mov rdi, 0
    syscall
    
