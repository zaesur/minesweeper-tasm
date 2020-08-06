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
    stosb
    inc ebx                         ; increment the sprite address
    loop @@repeatPixel
    pop ecx                         ; restore the count
    add edi, SCRW - SPRITE_WIDTH    ; move to the start of the next line
    loop @@repeatLine

    ret
endp drawSprite

proc drawCell
    arg @@cellPointer:dword, @@row:dword, @@col:dword
    uses eax, ebx

    mov ebx, [@@cellPointer]
    mov eax, offset unrevealed
    cmp [(Cell ptr ebx).isRevealed], 1
    jne @@draw
    movzx eax, [(Cell ptr ebx).count]
    mov ebx, SPRITE_WIDTH * SPRITE_HEIGHT
    mul ebx
    add eax, offset empty
@@draw:
    call drawSprite, eax, [@@row], [@@col]

    ret
endp drawCell

proc drawBoard
    arg @@boardPointer:dword
    local @@row:dword, @@col:dword
    uses ebx, ecx

    mov ebx, [@@boardPointer]
    mov ecx, GRID_SIZE
@@rowLoop:
    mov [@@row], GRID_SIZE
    sub [@@row], ecx
    push ecx                    
    mov ecx, GRID_SIZE
@@columnLoop:
    mov [@@col], GRID_SIZE
    sub [@@col], ecx
    call drawCell, ebx, [@@row], [@@col]
    inc ebx
    loop @@columnLoop
    pop ecx
    loop @@rowLoop

    ret
endp drawBoard

END