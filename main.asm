IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "print.inc"
INCLUDE "cell.inc"

CODESEG

proc main
    sti
    cld
    
    call placeMines, offset board, GRID_SIZE
    call printBoard, offset board

    mov 	eax, 4c00h      ; AH = 4Ch - Exit To DOS
    int 	21h             ; DOS INT 21h
endp main

STACK 100h

DATASEG
    board Cell GRID_SIZE*GRID_SIZE dup(<0,1,0>)

end main