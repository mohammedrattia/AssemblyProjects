;  Executable name : hexdump
;  Version         : 2.0
;  Created date    : 5/9/2025
;  Last update     : 5/9/2025
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
    ; buffer for reading chunck of data
    BUFFLEN     equ 16
    Buff:       resb BUFFLEN

section .data
    ; string to hold one converted hex byte
    DumpLine:     db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
    DUMPLEN      equ $-DumpLine
    ASCLine:     db "|................|",10
    ASCLEN      equ $-ASCLine
    FULLLEN     equ $-DumpLine
    
    ; Hexadecimal digits
    Digits:     db "0123456789ABCDEF", 0
    ; ASCII maping
    DotXlat: 
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
        db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
        db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
        db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
        db 60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh
        db 70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,7Ch,7Dh,7Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
section .text


;-------------------------------------------------------------------------
; ClearLine:    Clears the hex dump line by filling it with '00' and dots.
; UPDATED:     5/9/2025
; IN:          Nothing
; RETURNS:     Nothing
; MODIFIES:    RAX, RBX, RCX, RDX, DumpLine, ASCLine
; CALLS:       DumpChar
; DESCRIPTION: Iterates through all 16 positions in the dump line and inserts
;              '00' in the hex area and '.' in the ASCII area, effectively
;              resetting the line before new data is processed.
;
ClearLine:
    push rax
    push rbx
    push rcx
    push rdx
    
    mov  rdx,15     ; We're going to go 16 pokes, counting from 0
.poke:	
    mov rax,0       ; Tell DumpChar to poke a '0'
    call DumpChar   ; Insert the '0' into the hex dump string
    sub rdx,1       ; DEC doesn't affect CF!
    jae .poke       ; Loop back if RDX >= 0
    
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

;-------------------------------------------------------------------------
; WriteLine:    Prints the current hex + ASCII dump line to stdout.
; UPDATED:     5/9/2025
; IN:          Nothing
; RETURNS:     Nothing
; MODIFIES:    RAX, RDI, RSI, RDX
; CALLS:       syscall sys_write
; DESCRIPTION: Writes both the hexadecimal and ASCII parts of the dump line
;              to the console using the Linux sys_write syscall.
;
WriteLine:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
; printing the Hex Byte into the screen
    mov rax, 1                  ; 1 = sys_write
    mov rdi, 1                  ; 1 = stdout
    mov rsi, DumpLine           ; Hex string address
    mov rdx, FULLLEN            ; Hex string length
    syscall
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
 

;-------------------------------------------------------------------------
; DumpChar:    Insert a byte's hex and ASCII representation into the dump line.
; UPDATED:     5/9/2025
; IN:          RAX = byte value (0–255)
;              RDX = position in line (0–15)
; RETURNS:     Nothing
; MODIFIES:    RAX, RBX, RDI, DumpLine, ASCLine
; CALLS:       Nothing
; DESCRIPTION: Maps the input byte into both its ASCII (or '.' if non-printable)
;              and hexadecimal string representation and stores them in the
;              appropriate place in the dump line.
;
DumpChar:
; Save caller's registers that will be modified
    push rbx
    push rdi
    
; First we insert the input char into the ASCII portion of the dump line
    mov bl,[DotXlat+rax]      ; Translate nonprintables to '.'
    mov [ASCLine+rdx+1],bl    ; Write to ASCII portion
    
; Next we insert the hex equivalent of the input char in the hex portion of the hex dump line:
    mov rbx, rax            ; copying the byte into bl to process each 4bits
    lea rdi, [rdx*2+rdx]    ; calculating the position of the hex char
    
    ; getting the lower 4bits
    ; making bit masking to get the 4bits only
    and al, 0Fh                     ; and removes the upper part
    mov al, byte [Digits+rax]       ; moving the correct hex digit into ah
    mov byte [DumpLine+rdi+2], al   ; moving the correct hex digit into its place in HexStr
    
    ; shifting right 4bits deletes the lower 4bits leaving the upper ones only
    shr bl, 4                       ; shifting right 4bits
    mov bl, byte [Digits+rbx]       ; moving the correct hex digit into ah
    mov byte [DumpLine+rdi+1], bl   ; moving the correct hex digit into its place in HexStr

; Restore the caller's vars
    pop rdi
    pop rbx
    ret
    
;-------------------------------------------------------------------------
; LoadBuff:    Fills the buffer with data from stdin via syscall sys_read.
; UPDATED:     5/9/2025
; IN:          Nothing
; RETURNS:     R15 = number of bytes read
; MODIFIES:    RAX, RCX, RDX, RSI, RDI, R15, Buff
; CALLS:       syscall sys_read
; DESCRIPTION: Reads up to BUFFLEN bytes from stdin into Buff, storing the
;              number of bytes read in R15. Clears RCX to prepare for scanning.
;
LoadBuff:
    push rax    ; Save caller's RAX
    push rdx    ; Save caller's RDX
    push rsi    ; Save caller's RSI
    push rdi    ; Save caller's RDI
    
; reading chunck of data into the buffer
    mov rax, 0          ; 0 = sys_read
    mov rdi, 0          ; 0 = stdin
    mov rsi, Buff       ; buffer address
    mov rdx, BUFFLEN    ; buffer length
    syscall
    
    mov r15, rax        ; saving the number of characters read for later
    xor rcx, rcx        ; clears RCX
    
    pop rdi     ; Restore caller's RDI
    pop rsi     ; Restore caller's RSI
    pop rdx     ; Restore caller's RDX
    pop rax     ; Restore caller's RAX
    ret

; ------------------------------------------------------------------------
; MAIN PROGRAM BEGINS HERE
;-------------------------------------------------------------------------
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
    je Next
    call ClearLine
Next:
    jmp Scan
    
Exit:
    mov rax, 60     ; 60 = sys_exit
    mov rdi, 0      ; return 0 means everything is good
    syscall
    
    
    
    