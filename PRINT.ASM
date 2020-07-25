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
    uses eax, ecx, edx

    mov ah, 02h
    mov dl, ' '
    int 21h
    int 21h
    int 21h
    mov ecx, GRID_SIZE
@@repeat:
    mov edx, GRID_SIZE
    sub edx, ecx
    add edx, '0'
    int 21h
    mov dl, ' '
    int 21h
    int 21h
    loop @@repeat

    ; print a new line
    mov ah, 09h
	mov edx, offset newline
    int 21h
    
    ret
endp printHeader

proc printCell
    arg @@cellPointer:dword
    uses eax, ebx
    
    mov ebx, [@@cellPointer]
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

proc printRow
    arg @@rowNumber:dword, @@rowStart:dword
    uses eax, ecx, ebx, edx
    
    mov ah, 02h    
    mov edx, [@@rowNumber]
    add dl, '0'
    int 21h
    mov dl, ' '
    int 21h

    mov ebx, [@@rowStart]
    mov ecx, GRID_SIZE
@@repeat:
    call printCell, ebx
    add ebx, SIZE Cell
    loop @@repeat
    
    ; print a new line
    mov ah, 09h
	mov edx, offset newline
    int 21h
    
    ret
endp printRow

proc printBoard
    arg @@boardPointer:dword
    uses ebx, ecx, edx
    
    ; print the header
    call printHeader
    
    ; print the rows
    mov edx, [@@boardPointer]
    mov ecx, GRID_SIZE
@@repeat:
    mov ebx, GRID_SIZE
    sub ebx, ecx
    call printRow, ebx, edx
    add edx, GRID_SIZE * SIZE Cell
    loop @@repeat

    ret
endp printBoard

proc promptRow
    
endp promptRow

UDATASEG
    newline db 13, 10, '$'
END