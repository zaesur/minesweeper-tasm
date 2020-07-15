;=============================================================================
; 32-bit Assembler Random Number Generation.
;
; For use under DMPI 0.9 protected mode.
;
; The pseudo random generator is basically a Linear congruential generator, as
; explained on https://en.wikipedia.org/wiki/Linear_congruential_generator.
;
; This implementation assumes a modulo of 2^32.
;
; The constants are use from C99 and C11.
;
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;	
;	This is a corrected version with a uniform output random distribution
;	David Blinder, 2017
;	
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
; Copyright (c) 2015, Tim Bruylants <tim.bruylants@gmail.com>
; All rights reserved.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions
; are met:
;
; 1. Redistributions of source code must retain the above copyright notice,
;    this list of conditions and the following disclaimer.
;
; 2. Redistributions in binary form must reproduce the above copyright notice,
;    this list of conditions and the following disclaimer in the documentation
;    and/or other materials provided with the distribution.
;
; 3. Neither the name of the copyright holder nor the names of its
;    contributors may be used to endorse or promote products derived from this
;    software without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGE.
;
;=============================================================================

IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "print.inc"
INCLUDE "cell.inc"

;=============================================================================
; CODE
;=============================================================================
CODESEG

proc printHeader
    arg @@number:dword
    uses eax, ecx, edx

    mov ah, 02h
    mov dl, ' '
    int 21h
    int 21h
    int 21h
    int 21h
    mov ecx, [@@number]
@@repeat:
    mov edx, [@@number]
    sub edx, ecx
    add edx, '0'
    int 21h
    mov dl, ' '
    int 21h
    int 21h
    int 21h
    loop @@repeat

    mov ah, 09h
	mov edx, offset newline
    int 21h
    
    ret
endp printHeader

proc printCell
    arg @@cell:dword
    uses eax, ebx
    
    mov ebx, [@@cell]
    mov ah, 02h
    
    ; print the border
    mov dl, '|'
    int 21h

    ; print the cell contents
    cmp [(Cell ptr ebx).isRevealed], 0
    je @@printSpace
    cmp [(Cell ptr ebx).isMine], 0
    je @@printCount
    mov dl, 'M'
    jmp @@print

    ; print the cell count if an empty cell is revealed
@@printCount:
    mov dl, [(Cell ptr ebx).count]
    add dl, '0'
    jmp @@print

    ; print a space for any unrevealed cells
@@printSpace:
    mov dl, ' '

@@print:
    int 21h

    ; print the border
    mov dl, '|'
    int 21h
    
    ret
endp printCell

DATASEG
    newline db 13, 10, '$'
END