IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "io.inc"
INCLUDE "cell.inc"
INCLUDE "mouse.inc"

CODESEG

proc main
    sti
    cld

    call setVideoMode, 13h
    call placeMines, offset board
    call drawBoard, offset board
    call waitForSpecificKeystroke, 01Bh
    call terminateProcess

endp main

STACK 100h

DATASEG
    board Cell GRID_SIZE*GRID_SIZE dup(<0,1,0>)
end main