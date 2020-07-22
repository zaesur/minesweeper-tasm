IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "print.inc"
INCLUDE "cell.inc"

GRID_SIZE EQU 6

CODESEG

proc main
    sti
    cld
    
    call printBoard, GRID_SIZE, offset board

    mov 	eax, 4c00h      ; AH = 4Ch - Exit To DOS
    int 	21h             ; DOS INT 21h
endp main

STACK 100h

UDATASEG
    board Cell GRID_SIZE*GRID_SIZE dup(<>)

end main