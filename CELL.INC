GRID_SIZE EQU 6

STRUC Cell
    isMine db 0
    isRevealed db 0
    count db 0
ENDS Cell

GLOBAL	placeMines:PROC, \
        revealCell:PROC