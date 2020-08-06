IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "io.inc"
INCLUDE "cell.inc"
INCLUDE "mouse.inc"

CODESEG

proc handler
    local @@row:dword, @@col:dword
    uses eax, ebx, ecx, edx

    and bl, 3
    jz @@skip
    
    sar cx, 3
    cmp cx, GRID_SIZE
    jge @@skip
    
    sar dx, 3
    cmp dx, GRID_SIZE
    jge @@skip

    call revealCell, offset board, cx, dx
    call drawBoard, offset board

@@skip:
    ret
endp handler

proc main
    sti
    cld

    call setVideoMode, 13h
    call mouse_install, offset handler
    mov ax, 01h
    int 33h
    call placeMines, offset board
    call drawBoard, offset board
    call waitForSpecificKeystroke, 01Bh
    call terminateProcess

endp main

STACK 100h

DATASEG
    board Cell GRID_SIZE*GRID_SIZE dup(<0,0,0>)
end main