IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "print.inc"
INCLUDE "cell.inc"

GRID_SIZE EQU 5

CODESEG

proc main
    sti
    cld
    
    call printCell, offset hiddenCell
    call printCell, offset revealedCell
    call printCell, offset hiddenMine
    call printCell, offset revealedMine
    
    mov 	eax, 4c00h      ; AH = 4Ch - Exit To DOS
    int 	21h             ; DOS INT 21h
endp main

STACK 100h

DATASEG
    hiddenCell Cell <0, 0, 5>
    revealedCell Cell <0, 1, 5>
    hiddenMine Cell <1, 0, 5>
    revealedMine Cell <1, 1, 5>

end main