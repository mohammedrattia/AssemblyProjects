;  Executable name : HexDump
;  Version         : 1.0
;  Created date    : 30/8/2025
;  Last update     : 30/8/2025
;  Author          : Mohammed R. Attia
;  Architecture    : x64
;  Description     : A simple program in assembly for x64 Linux, using NASM 2.14,
;                    that converts the data in a file into it hexadicimal representation
;                    and print it into the console.
;
;  Run it this way :
;    HexDump < [input file]
;
;  Build using these commands:
;    nasm -f elf64 -g -F stabs eatsyscall.asm
;    ld -o eatsyscall eatsyscall.o
;

section .data
        ; string to hold one converted hex byte
        HexStr: db " 00", 0
        HexLen equ $-HexStr
        
        ; end of line to be print after each 16 bytes
        endl: db 10, 0
        
        ; Hexadecimal digits
        Digits: db "0123456789ABCDEF", 0
section .bss
        ; buffer for reading chunck of data
        BuffLen equ 16
        Buff: resb BuffLen

section .text
global _start
_start:
    push rbp
    mov rbp, rsp    ; for correct debugging
    
Read:
    ; reading chunck of data into the buffer
    mov rax, 0                  ; 0 = sys_read
    mov rdi, 0                  ; 0 = stdin
    mov rsi, Buff               ; buffer address
    mov rdx, BuffLen            ; buffer length
    syscall
    mov r15, rax                ; saving the number of characters read for later
    cmp rax, 0                  ; exit when we reach the EOF
    je Exit
    
    xor r12, r12                ; making r12 = 0 to use for scan iterations
    dec r15                     ; decreasing r15 by one to avoid out of bound

    Scan:
        ; getting one byte from the buffer
        xor rax, rax                ; reseting rax to use it for calculation
        mov al, byte [Buff+r12]     ; moving the byte into al for processing
        mov rbx, rax                ; copying the byte into bl to process each 4bits 
        
        ; getting the lower 4bits
        ; making bit masking to get the 4bits only
        and al, 0Fh                 ; and removes the upper part
        ; another way:
        ; ror al, 4
        ; shr al, 4
        mov al, byte [Digits+rax]   ; moving the correct hex digit into ah
        mov byte [HexStr+2], al     ; moving the correct hex digit into its place in HexStr
        
        ; shifting right 4bits deletes the lower 4bits leaving the upper ones only
        shr bl, 4                   ; shifting right 4bits
        mov bl, byte [Digits+rbx]   ; moving the correct hex digit into ah
        mov byte [HexStr+1], bl     ; moving the correct hex digit into its place in HexStr
        
        ; printing the Hex Byte into the screen
        mov rax, 1                  ; 1 = sys_write
        mov rdi, 1                  ; 1 = stdout
        mov rsi, HexStr             ; Hex string address
        mov rdx, HexLen             ; Hex string length
        syscall
        
        inc r12                     ; increase the counter by one
        cmp r12, r15                ; check if we finished the buffer
        jna Scan
    
    ; go to new line if we finished the buffer
    mov rax, 1                  ; 1 = sys_write
    mov rdi, 1                  ; 1 = stdout
    mov rsi, endl               ; end line character address
    mov rdx, 1                  ; print one character '\n'
    syscall
    
    ; Read another buffer
    jmp Read
    
Exit:
    mov rax, 60     ; 60 = sys_exit
    mov rdi, 0      ; return 0 means everything is good
    syscall
    
    
    
    