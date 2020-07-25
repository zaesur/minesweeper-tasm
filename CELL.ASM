IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "cell.inc"
INCLUDE "rand.inc"

;=============================================================================
; CODE
;=============================================================================
CODESEG

proc validateIndices
    arg @@rowIndex:dword, @@columnIndex
    mov eax, 0

    cmp [@@rowIndex], 0
    jl @@skip
    cmp [@@rowIndex], GRID_SIZE
    jge @@skip
    cmp [@@columnIndex], 0
    jl @@skip
    cmp [@@columnIndex], GRID_SIZE
    jge @@skip
    mov eax, 1

@@skip:
    ret
endp validateIndices

proc getCell
    arg @@boardPointer:dword, @@rowIndex:dword, @@columnIndex:dword
    uses eax, ecx

    ; EAX <- (rowIndex * gridSize) + columnIndex
    mov eax, [@@rowIndex]
    mov ecx, GRID_SIZE
    mul ecx
    add eax, [@@columnIndex]

    ; EBX <- boardPointer + (EAX * cellSize)
    mov ecx, SIZE Cell
    mul ecx
    mov ebx, [@@boardPointer]
    add ebx, eax

    ret
endp getCell

proc incCellCount
    arg @@boardPointer:dword, @@rowIndex:dword, @@columnIndex:dword
    uses eax, ebx

    ; check if the indices are within boundaries
    call validateIndices, [@@rowIndex], [@@columnIndex]
    cmp eax, 0
    je @@skip

    ; increment the cell count
    call getCell, [@@boardPointer], [@@rowIndex], [@@columnIndex]
    inc [(Cell ptr ebx).count]

@@skip:
    ret
endp incCellCount

proc placeMines
    arg @@boardPointer:dword, @@numberOfMines:dword
    local @@x, @@y
    uses eax, ebx, ecx, edx

    ; initialize the RNG
    call rand_init
    
    ; iterate the number of mines
    mov ecx, [@@numberOfMines]
    jecxz @@skip
@@placeMine:
    ; generate a random x and y coordinate
    call rand16
    xor edx, edx
    mov bx, GRID_SIZE
    div bx
    mov [@@x], edx
    call rand16
    div bx
    mov [@@y], edx
    
    ; get the cell at (x, y)
    call getCell, [@@boardPointer], [@@x], [@@y]

    ; if the cell already contains a mine, try again
    cmp [(Cell ptr ebx).isMine], 1
    je @@placeMine

    ; else place the mine and increment its neighbours
    mov [(Cell ptr ebx).isMine], 1
    ; TODO: increment the neighbours
    loop @@placeMine

@@skip:
    ret
endp placeMines

proc revealCell
    arg @@boardPointer:dword, @@rowIndex:dword, @@columnIndex:dword
    uses eax, ebx, ecx
    
    ; get the cell in EBX
    call getCell, [@@boardPointer], [@@rowIndex], [@@columnIndex]

    ; check if the cell has already been revealed, else reveal
    cmp [(Cell ptr ebx).isRevealed], 1
    je @@skip
    mov [(Cell ptr ebx).isRevealed], 1

    ; TODO: if there are no neighbouring mines, flood the neighbouring cells
    
@@skip:
    ret
endp revealCell

END