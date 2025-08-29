;  Executable name : toUppercase
;  Version         : 1.0
;  Created date    : 29/8/2025
;  Last update     : 30/8/2025
;  Author          : Mohammed R. Attia
;  Architecture    : x64
;  Description     : A simple program in assembly for x64 Linux, using NASM 2.14,
;                    that converts the data in a file into Uppercase.
;
;  Build using these commands:
;    nasm -f elf64 -g -F stabs eatsyscall.asm
;    ld -o eatsyscall eatsyscall.o
;

section .data
        buffLen: equ 1024
        
section .bss
        buff: resb buffLen
        char: resb 1

section .text
global main
main:
    push rbp
    mov rbp, rsp; for correct debugging
    
Read:
    ; read one character of data
    mov rax, 0                  ; 0 = code for sys_read
    mov rdi, 0                  ; fd for the data file
    mov rsi, buff               ; variable to hold the character after reading
    mov rdx, buffLen            ; number of bytes to be read
    syscall
    
    mov rcx, buffLen
    mov r13, buff
    dec r13

Process:
    ; if return equals 0 we reached the eof (end of file)
    cmp rax, 0                  ; compare rax with 0
    jz Exit                     ; jump to exit if the return is 0
    
    ; print the char if it's not a lowercase letter
    cmp byte [r13+rcx], 61h        ; check if the char is below 'a'
    jb Continue
    cmp byte [r13+rcx], 7Ah        ; check if the char is above 'z'
    ja Continue
    
    ; converting lowercase to uppercase by subtracting 20h
    sub byte [r13+rcx], 20h

Continue:
    loop Process
    
    
Write:
    ; print the character into the console
    mov rax, 1                  ; 1 = code for sys_write
    mov rdi, 1                  ; 1 = fd for stdout
    mov rsi, buff               ; the character we print
    mov rdx, buffLen            ; No. bytes to be printed
    syscall
    
    ; repeat for the next character
    jmp Read
    
Exit:
    mov rax, 60
    mov rdi, 0
    syscall
    
    
    
    
    
    
    
    
    