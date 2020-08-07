IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "io.inc"
INCLUDE "cell.inc"
INCLUDE "mouse.inc"

CODESEG

proc mouseHandler
    local @@row:dword, @@col:dword
    uses eax, ebx, ecx, edx

    and bl, 3
    jz @@skip

    sar cx, 4
    cmp cx, GRID_SIZE
    jge @@skip
    mov [@@col], ecx

    sar dx, 3
    cmp dx, GRID_SIZE
    jge @@skip
    mov [@@row], edx

    call revealCell, offset board, [@@row], [@@col]
    call drawBoard, offset board

@@skip:
    ret
endp mouseHandler

proc main
    sti
    cld

    call setVideoMode, 13h
    call mouse_install, offset mouseHandler
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