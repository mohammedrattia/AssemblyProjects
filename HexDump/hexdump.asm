;  Executable name : hexdump
;  Version         : 2.0
;  Created date    : 5/9/2025
;  Last update     : 10/9/2025
;  Author          : Mohammed R. Attia
;  Architecture    : x64
;  Description     : A simple program in assembly for x64 Linux, using NASM 2.14,
;                    that converts the data in a file into it hexadicimal representation
;                    and print it into the console.
;
;  Run it this way :
;    hexdump < [input file]
;
;  Build using these commands:
;    nasm -f elf64 -g -F stabs hexdump.asm
;    ld -o hexdump hexdump.o
;

section .bss

section .data

section .text

extern LoadBuff, DumpChar, WriteLine, ClearLine
EXTERN Buff, BuffLength

; For SASM use:
; %include "hexlib.asm"

;------------------------------------------------------------------------
; MAIN PROGRAM BEGINS HERE
;------------------------------------------------------------------------
; main:        Program entry point for HexDump.
; UPDATED:     5/9/2025
; IN:          Command line arguments (ignored, input is via stdin redirection)
; RETURNS:     Exit status code (0 on success)
; MODIFIES:    RAX, RDI, RSI, RCX, RDX, R15, Buff, DumpLine, ASCLine
; CALLS:       LoadBuff, DumpChar, WriteLine, ClearLine, syscall sys_exit
; DESCRIPTION: Initializes registers, enters the main loop to read chunks
;              from stdin, convert them into hexadecimal + ASCII dump lines,
;              print them, and repeat until EOF. Exits cleanly at EOF.
;

global _start
_start:
    mov rbp,rsp; for correct debugging
    
    ; Whatever initialization needs doing before loop scan starts is here:
    xor rsi, rsi
    call LoadBuff   ; Read the first line
    cmp r15, 0      ; exit when we reach the EOF
    je Exit
    
Scan:
; getting one byte from the buffer
    xor rax, rax                ; reseting rax to use it for calculation
    mov al, byte [Buff+rcx]     ; moving the byte into al for processing
    mov rdx, rsi                ; Copy total counter into RDX
    and rdx, 000000000000000Fh  ; Mask out lowest 4 bits of counter
    call DumpChar

; Go to the next character and see if the buffer is done
    inc rsi             ; increase the total counter by one
    inc rcx             ; increase the counter by one
    cmp rcx, r15        ; check if we finished the buffer
    jb Scan

    call WriteLine      ; print the dump line if it is completed
    call LoadBuff       ; load the next Buff
    cmp r15, 0          ; exit when we reach the EOF
    je Exit
    cmp r15, 16         ; if the last Buff less than 16 byte we need to clear
    je .next
    call ClearLine
.next:
    jmp Scan
    
Exit:
    mov rax, 60     ; 60 = sys_exit
    mov rdi, 0      ; return 0 means everything is good
    syscall
    
    
    
    