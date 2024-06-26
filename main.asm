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

    call getCell, offset board, [@@row], [@@col]
    cmp [(Cell ptr ebx).isMine], 1
    jne @@revealCell
    call revealMines, offset board
    jmp @@draw
@@revealCell:
    call revealCell, offset board, [@@row], [@@col]
    
@@draw:
    mov ax, 02h              ; hide the mouse
    int 33h
    call drawBoard, offset board
    mov ax, 01h             ; show the mouse
    int 33h

@@skip:
    ret
endp mouseHandler

proc main
    sti
    cld
    
    push ds
    pop es

    call setVideoMode, 13h
    call mouse_install, offset mouseHandler
    mov ax, 01h              ; show the mouse
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