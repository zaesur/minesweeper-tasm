; CONSTANTS
VMEM EQU 0A0000h
SCRW EQU 320
SCRH EQU 200
SPRITE_HEIGHT EQU 8
SPRITE_WIDTH EQU 8

; COLOURS
FG EQU 067h
MG EQU 0AFh
BG EQU 0F7h
C1 EQU 02Fh
C2 EQU 02Dh
C3 EQU 02Bh
C4 EQU 029h
C5 EQU 027h
C6 EQU 025h
C7 EQU 023h
C8 EQU 021h

; EXPORTS
GLOBAL	setVideoMode:PROC, \
        waitForSpecificKeystroke:PROC, \
        terminateProcess:PROC, \
        drawBoard:PROC

; SPRITES
DATASEG
        unrevealed db\
                FG, FG, FG, FG, FG, FG, FG, FG,\
                FG, MG, MG, MG, MG, MG, MG, MG,\
                FG, MG, MG, MG, MG, MG, MG, MG,\
                FG, MG, MG, MG, MG, MG, MG, MG,\
                FG, MG, MG, MG, MG, MG, MG, MG,\
                FG, MG, MG, MG, MG, MG, MG, MG,\
                FG, MG, MG, MG, MG, MG, MG, MG,\
                FG, MG, MG, MG, MG, MG, MG, MG

        empty db\
                BG, BG, BG, BG, BG, BG, BG, BG,\
                BG, MG, MG, MG, MG, MG, MG, MG,\
                BG, MG, MG, MG, MG, MG, MG, MG,\
                BG, MG, MG, MG, MG, MG, MG, MG,\
                BG, MG, MG, MG, MG, MG, MG, MG,\
                BG, MG, MG, MG, MG, MG, MG, MG,\
                BG, MG, MG, MG, MG, MG, MG, MG,\
                BG, MG, MG, MG, MG, MG, MG, MG
    
        one db\
                BG, BG, BG, BG, BG, BG, BG, BG,\
                BG, MG, MG, MG, MG, MG, MG, MG,\
                BG, MG, MG, C1, C1, MG, MG, MG,\
                BG, MG, MG, MG, C1, MG, MG, MG,\
                BG, MG, MG, MG, C1, MG, MG, MG,\
                BG, MG, MG, MG, C1, MG, MG, MG,\
                BG, MG, MG, C1, C1, C1, MG, MG,\
                BG, MG, MG, MG, MG, MG, MG, MG
        
        two db\
                BG, BG, BG, BG, BG, BG, BG, BG,\
                BG, MG, MG, MG, MG, MG, MG, MG,\
                BG, MG, C2, C2, C2, MG, MG, MG,\
                BG, MG, MG, MG, MG, C2, MG, MG,\
                BG, MG, MG, C2, C2, MG, MG, MG,\
                BG, MG, C2, MG, MG, MG, MG, MG,\
                BG, MG, C2, C2, C2, C2, MG, MG,\
                BG, MG, MG, MG, MG, MG, MG, MG

        three db\
                BG, BG, BG, BG, BG, BG, BG, BG,\
                BG, MG, MG, MG, MG, MG, MG, MG,\
                BG, MG, C3, C3, C3, MG, MG, MG,\
                BG, MG, MG, MG, MG, C3, MG, MG,\
                BG, MG, MG, C3, C3, MG, MG, MG,\
                BG, MG, MG, MG, MG, C3, MG, MG,\
                BG, MG, C3, C3, C3, MG, MG, MG,\
                BG, MG, MG, MG, MG, MG, MG, MG
        
        four db\
                BG, BG, BG, BG, BG, BG, BG, BG,\
                BG, MG, MG, MG, MG, MG, MG, MG,\
                BG, MG, C4, MG, C4, MG, MG, MG,\
                BG, MG, C4, MG, C4, MG, MG, MG,\
                BG, MG, C4, MG, C4, MG, MG, MG,\
                BG, MG, C4, C4, C4, C4, MG, MG,\
                BG, MG, MG, MG, C4, MG, MG, MG,\
                BG, MG, MG, MG, MG, MG, MG, MG

        five db\
                BG, BG, BG, BG, BG, BG, BG, BG,\
                BG, MG, MG, MG, MG, MG, MG, MG,\
                BG, MG, C5, C5, C5, C5, MG, MG,\
                BG, MG, C5, MG, MG, MG, MG, MG,\
                BG, MG, C5, C5, C5, MG, MG, MG,\
                BG, MG, MG, MG, MG, C5, MG, MG,\
                BG, MG, C5, C5, C5, MG, MG, MG,\
                BG, MG, MG, MG, MG, MG, MG, MG
        
        six db\
                BG, BG, BG, BG, BG, BG, BG, BG,\
                BG, MG, MG, MG, MG, MG, MG, MG,\
                BG, MG, MG, C6, C6, MG, MG, MG,\
                BG, MG, C6, MG, MG, MG, MG, MG,\
                BG, MG, C6, C6, C6, MG, MG, MG,\
                BG, MG, C6, MG, MG, C6, MG, MG,\
                BG, MG, MG, C6, C6, MG, MG, MG,\
                BG, MG, MG, MG, MG, MG, MG, MG
        
        seven db\
                BG, BG, BG, BG, BG, BG, BG, BG,\
                BG, MG, MG, MG, MG, MG, MG, MG,\
                BG, MG, C7, C7, C7, C7, MG, MG,\
                BG, MG, MG, MG, MG, C7, MG, MG,\
                BG, MG, MG, MG, C7, MG, MG, MG,\
                BG, MG, MG, C7, MG, MG, MG, MG,\
                BG, MG, MG, C7, MG, MG, MG, MG,\
                BG, MG, MG, MG, MG, MG, MG, MG
        
        eight db\
               BG, BG, BG, BG, BG, BG, BG, BG,\
               BG, MG, MG, MG, MG, MG, MG, MG,\
               BG, MG, MG, C8, C8, MG, MG, MG,\
               BG, MG, C8, MG, MG, C8, MG, MG,\
               BG, MG, MG, C8, C8, MG, MG, MG,\
               BG, MG, C8, MG, MG, C8, MG, MG,\
               BG, MG, MG, C8, C8, MG, MG, MG,\
               BG, MG, MG, MG, MG, MG, MG, MG