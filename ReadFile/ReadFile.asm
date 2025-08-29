;  Executable name : ReadFile
;  Version         : 1.0
;  Created date    : 29/8/2025
;  Last update     : 30/8/2025
;  Author          : Mohammed R. Attia
;  Architecture    : x64
;  Description     : A simple program in assembly for x64 Linux, using NASM 2.14,
;                    that prints the contents of a file into the console.
;
;  Build using these commands:
;    nasm -f elf64 -g -F stabs eatsyscall.asm
;    ld -o eatsyscall eatsyscall.o
;

section .data
        ; path of the data file
        filename: db "/home/moccisor/MyData/_Computer_Science_/asmwork/MyAsmWork/data.txt", 0
        ; error message
        openFileErrorMsg: db "can't open the file", 0
        openFileErrorLen: equ $-openFileErrorMsg
section .bss
        ; size of max data to be read
        dataLen: equ 250
        ; variable to hold the data to be read
        data: resb dataLen
section .text
global main
main:
    push rbp
    mov rbp, rsp; for correct debugging
    
    ; open the file that contains the data
    mov rax, 2          ; 2 = code for sys_open
    mov rdi, filename   ; filename to be open
    mov rsi, 0          ; O_RDONLY open with read-only flag
    mov rdx, 400        ; S_IRUSR  00400 user has read permission
    syscall
    
    cmp rax, 0
    js openFileError

    ; read the data from the file into the variable "data"
    mov rdi, rax        ; rax (the return of the last syscall) = fd (file descriptor) of the data file
    mov rax, 0          ; 0 = code for sys_read
    mov rsi, data       ; the address of the variable to put the data into
    mov rdx, dataLen    ; the size of bytes to read
    syscall
    
    ; print the data in the variable into the console
    mov rax, 1          ; 1 = code for sys_write
    mov rdi, 1          ; 1 = fd code for stdout
    mov rsi, data       ; the address of the variable that contains the data
    mov rdx, dataLen    ; the size of bytes to be print
    syscall
    
    jmp Exit

openFileError:
    mov rax, 1
    mov rdi, 2
    mov rsi, openFileErrorMsg
    mov rdx, openFileErrorLen
    syscall
    
Exit:
    ; exit the program
    mov rax, 60         ; code for sys_exit
    mov rdi, 0          ; return 0 = program ends with no issues
    syscall
    
    
    
    
    
    
    
    
    
    
    