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
    arg @@row:dword, @@col:dword
    mov eax, 0

    cmp [@@row], 0
    jl @@skip
    cmp [@@row], GRID_SIZE
    jge @@skip
    cmp [@@col], 0
    jl @@skip
    cmp [@@col], GRID_SIZE
    jge @@skip
    mov eax, 1

@@skip:
    ret
endp validateIndices

proc getCell
    arg @@boardPointer:dword, @@row:dword, @@col:dword
    uses eax, ecx

    ; EAX <- (rowIndex * gridSize) + columnIndex
    mov eax, [@@row]
    mov ecx, GRID_SIZE
    mul ecx
    add eax, [@@col]

    ; EBX <- boardPointer + (EAX * cellSize)
    mov ecx, SIZE Cell
    mul ecx
    mov ebx, [@@boardPointer]
    add ebx, eax

    ret
endp getCell

proc incCellCount
    arg @@boardPointer:dword, @@row:dword, @@col:dword
    uses eax, ebx

    ; check if the indices are within boundaries
    call validateIndices, [@@row], [@@col]
    cmp eax, 0
    je @@skip

    ; increment the cell count
    call getCell, [@@boardPointer], [@@row], [@@col]
    inc [(Cell ptr ebx).count]

@@skip:
    ret
endp incCellCount

proc incNeighbours
    arg @@boardPointer:dword, @@row:dword, @@col:dword
    uses ecx
    
    ; start from (x-1, y-1)
    dec [@@row]
    dec [@@col]

    mov ecx, 3
@@outerloop:
    push ecx
    push [@@row]
    mov ecx, 3
@@innerloop:
    call incCellCount, [@@boardPointer], [@@row], [@@col]
    inc [@@row]
    loop @@innerloop
    pop [@@row]
    pop ecx
    inc [@@col]
    loop @@outerloop

    ret
endp incNeighbours

proc placeMines
    arg @@boardPointer:dword
    local @@row:dword, @@col:dword
    uses eax, ebx, ecx, edx

    ; initialize the RNG
    call rand_init
    
    ; iterate the number of mines
    mov ecx, MINE_COUNT
    jecxz @@skip
@@placeMine:
    ; generate a random x and y coordinate
    call rand16
    xor edx, edx
    mov bx, GRID_SIZE
    div bx
    mov [@@row], edx
    call rand16
    div bx
    mov [@@col], edx
    
    ; get the cell at (x, y)
    call getCell, [@@boardPointer], [@@row], [@@col]

    ; if the cell already contains a mine, try again
    cmp [(Cell ptr ebx).isMine], 1
    je @@placeMine

    ; else place the mine and increment its neighbours
    mov [(Cell ptr ebx).isMine], 1
    call incNeighbours, [@@boardPointer], [@@row], [@@col]
    loop @@placeMine

@@skip:
    ret
endp placeMines

proc revealCell
    arg @@boardPointer:dword, @@row:dword, @@col:dword
    uses eax, ebx, ecx

    call validateIndices, [@@row], [@@col]
    cmp eax, 0
    je @@skip
    
    ; get the cell in EBX
    call getCell, [@@boardPointer], [@@row], [@@col]

    ; check if the cell has already been revealed, else reveal
    cmp [(Cell ptr ebx).isRevealed], 1
    je @@skip
    mov [(Cell ptr ebx).isRevealed], 1

    ; if there are no neighbouring mines (count = 0), flood the neighbouring cells
    cmp [(Cell ptr ebx).count], 0
    jne @@skip
    
    dec [@@row]
    dec [@@col]

    mov ecx, 3
@@outerloop:
    push ecx
    push [@@row]
    mov ecx, 3
@@innerloop:
    call revealCell, [@@boardPointer], [@@row], [@@col]
    inc [@@row]
    loop @@innerloop
    pop [@@row]
    pop ecx
    inc [@@col]
    loop @@outerloop

@@skip:
    ret
endp revealCell

END