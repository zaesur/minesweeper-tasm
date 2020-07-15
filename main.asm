IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "rand.inc"

DATASEG

CODESEG

proc main
    sti
    cld
    
    ret
endp main

STACK 100h
end main