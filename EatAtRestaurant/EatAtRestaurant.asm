;  Executable name : ReadFile
;  Version         : 1.0
;  Created date    : 29/8/2025
;  Last update     : 29/8/2025
;  Author          : Mohammed R. Attia
;  Architecture    : x64
;  Description     : A simple program in assembly for x64 Linux, using NASM 2.14,
;                    that takes name of restaurant from user and print "Eat at {restaurant's name}!".
;
;  Build using these commands:
;    nasm -f elf64 -g -F stabs eatsyscall.asm
;    ld -o eatsyscall eatsyscall.o
;
SECTION .data          ; Section containing initialised data

        EatMsg: db "Eat at "
        ;EatMsg: db "Eat at Joe's...",0Ah ,"...Ten million flies can't ALL be wrong!",10
        EatLen: equ $-EatMsg
        mark: db "!", 0Ah
        markLen: equ $-mark

SECTION .bss           ; Section containing uninitialized data
        resLen: equ 250
        restaurant: resb resLen	

SECTION .text          ; Section containing code

global 	main	       ; Linker needs this to find the entry point!

main:
    push rbp
    mov rbp,rsp
    
    mov rax, 0          ; 1 = sys_read for syscall
    mov rdi, 0          ; 0 = fd for stdin
    mov rsi, restaurant
    mov rdx, resLen
    syscall

    mov rax,1           ; 1 = sys_write for syscall
    mov rdi,1           ; 1 = fd for stdout; i.e., write to the terminal window
    mov rsi,EatMsg      ; Put address of the message string in rsi
    mov rdx,EatLen      ; Length of string to be written in rdx
    syscall             ; Make the system call
    
    mov rax,1           ; 1 = sys_write for syscall
    mov rdi,1           ; 1 = fd for stdout; i.e., write to the terminal window
    mov rsi,restaurant  ; Put address of the message string in rsi
    mov rdx,resLen      ; Length of string to be written in rdx
    syscall             ; Make the system call
    
    mov rax,1           ; 1 = sys_write for syscall
    mov rdi,1           ; 1 = fd for stdout; i.e., write to the terminal window
    mov rsi,mark        ; Put address of the message string in rsi
    mov rdx,markLen     ; Length of string to be written in rdx
    syscall             ; Make the system call

    mov rax,60          ; 60 = exit the program
    mov rdi,0           ; Return value in rdi 0 = nothing to return
    syscall             ; Call syscall to exit








