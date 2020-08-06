IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "io.inc"
INCLUDE "cell.inc"

;=============================================================================
; CODE
;=============================================================================
CODESEG

proc setVideoMode
    arg @@VM:byte
    uses eax

    movzx ax, [@@VM]
    int 10h

    ret
endp setVideoMode

proc waitForSpecificKeystroke
    arg @@key:byte
    uses eax
    
@@repeat:
    mov ah, 00h
    int 16h
    cmp al, [@@key]
    jne @@repeat

    ret
endp waitForSpecificKeystroke

proc terminateProcess
    uses eax

    call setVideoMode, 03h
    mov	ax, 04C00h
    int 21h

    ret
endp terminateProcess

proc drawSprite
    arg @@spritePointer:dword, @@row:dword, @@col:dword
    uses eax, ebx, ecx, edx, edi

    mov edi, VMEM                   ; set the start of video memory
    mov eax, [@@row]
    mov ebx, 8 * SCRW
    mul ebx
    add edi, eax
    mov eax, [@@col]
    mov ebx, 8
    mul ebx
    add edi, eax

    mov ecx, SPRITE_HEIGHT          ; loop each vertical pixel
    mov ebx, [@@spritePointer]      ; store the first byte of the sprite in ebx
@@repeatLine:
    push ecx                        ; save count for later
    mov ecx, SPRITE_WIDTH           ; loop each horizontal pixel
@@repeatPixel:
    mov al, [ebx]                   ; get the colour stored at ebx
    stosb                           ; set the pixel
    inc ebx                         ; increment the sprite address
    loop @@repeatPixel              ; repeat
    pop ecx                         ; restore the count
    add edi, SCRW - SPRITE_WIDTH    ; move to the start of the next line
    loop @@repeatLine               ; repeat

    ret
endp drawSprite

proc drawCell
    arg @@cellPointer:dword, @@row:dword, @@col:dword
    local @@sprite:dword
    uses eax, ebx

    mov ebx, [@@cellPointer]                ; fetch the cell
    mov [@@sprite], offset unrevealed       ; set the sprite to unrevealed
    cmp [(Cell ptr ebx).isRevealed], 1      ; see if the cell has been revealed
    jne @@draw                              ; if it is not revealed, draw immediately
    movzx eax, [(Cell ptr ebx).count]       ; else, calculate the location of the correct sprite
    mov ebx, SPRITE_WIDTH * SPRITE_HEIGHT   ; ebx := size(sprite)
    mul ebx                                 ; eax *= size
    add eax, offset empty                   ; eax += offset
    mov [@@sprite], eax                     ; @@sprite := eax
@@draw:
    call drawSprite, [@@sprite], [@@row], [@@col]

    ret
endp drawCell

proc drawBoard
    arg @@boardPointer:dword
    local @@row:dword, @@col:dword
    uses ebx, ecx

    mov [@@row], 0                  ; start at row 0
    mov ebx, [@@boardPointer]       ; save the pointer to the board
    mov ecx, GRID_SIZE              ; initiate ecx to loop rows
@@rowLoop:
    mov [@@col], 0                  ; start at col 0
    push ecx                        ; store the row counter for later
    mov ecx, GRID_SIZE              ; initiate ecx to loop cells
@@cellLoop:
    call drawCell, ebx, [@@row], [@@col]
    add ebx, SIZE Cell              ; prepare the next cell
    inc [@@col]                     ; increase the col count
    loop @@cellLoop                 ; repeat
    pop ecx                         ; restore the row counter
    inc [@@row]                     ; increase the row count
    loop @@rowLoop                  ; repeat

    ret
endp drawBoard

END