GRID_SIZE EQU 8
MINE_COUNT EQU 10

STRUC Cell
    isMine db 0
    isRevealed db 0
    count db 0
ENDS Cell

GLOBAL	placeMines:PROC, \
        getCell:PROC, \
        revealCell:PROC, \
        revealMines:PROC