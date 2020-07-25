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
    arg @@x:dword, @@y
    mov eax, 0

    cmp [@@x], 0
    jl @@skip
    cmp [@@x], GRID_SIZE
    jge @@skip
    cmp [@@y], 0
    jl @@skip
    cmp [@@y], GRID_SIZE
    jge @@skip
    mov eax, 1

@@skip:
    ret
endp validateIndices

proc getCell
    arg @@boardPointer:dword, @@x:dword, @@y:dword
    uses eax, ecx

    ; EAX <- (rowIndex * gridSize) + columnIndex
    mov eax, [@@x]
    mov ecx, GRID_SIZE
    mul ecx
    add eax, [@@y]

    ; EBX <- boardPointer + (EAX * cellSize)
    mov ecx, SIZE Cell
    mul ecx
    mov ebx, [@@boardPointer]
    add ebx, eax

    ret
endp getCell

proc incCellCount
    arg @@boardPointer:dword, @@x:dword, @@y:dword
    uses eax, ebx

    ; check if the indices are within boundaries
    call validateIndices, [@@x], [@@y]
    cmp eax, 0
    je @@skip

    ; increment the cell count
    call getCell, [@@boardPointer], [@@x], [@@y]
    inc [(Cell ptr ebx).count]

@@skip:
    ret
endp incCellCount

proc incNeighbours
    arg @@boardPointer:dword, @@x:dword, @@y:dword
    uses ecx
    
    ; start from (x-1, y-1)
    dec [@@x]
    dec [@@y]

    mov ecx, 3
@@outerloop:
    push ecx
    push [@@x]
    mov ecx, 3
@@innerloop:
    call incCellCount, [@@boardPointer], [@@x], [@@y]
    inc [@@x]
    loop @@innerloop
    pop [@@x]
    pop ecx
    inc [@@y]
    loop @@outerloop

    ret
endp incNeighbours

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
    call incNeighbours, [@@boardPointer], [@@x], [@@y]
    loop @@placeMine

@@skip:
    ret
endp placeMines

proc revealCell
    arg @@boardPointer:dword, @@x:dword, @@y:dword
    uses eax, ebx, ecx

    call validateIndices, [@@x], [@@y]
    cmp eax, 0
    je @@skip
    
    ; get the cell in EBX
    call getCell, [@@boardPointer], [@@x], [@@y]

    ; check if the cell has already been revealed, else reveal
    cmp [(Cell ptr ebx).isRevealed], 1
    je @@skip
    mov [(Cell ptr ebx).isRevealed], 1

    ; if there are no neighbouring mines (count = 0), flood the neighbouring cells
    cmp [(Cell ptr ebx).count], 0
    jg @@skip
    dec [@@x]
    call revealCell, [@@boardPointer], [@@x], [@@y]
    add [@@x], 2
    call revealCell, [@@boardPointer], [@@x], [@@y]
    dec [@@x]
    dec [@@y]
    call revealCell, [@@boardPointer], [@@x], [@@y]
    add [@@y], 2
    call revealCell, [@@boardPointer], [@@x], [@@y]

@@skip:
    ret
endp revealCell

END