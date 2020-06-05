


*=$5000

into_hires
        jsr hires_start
        rts
*=$5008
        lda scrn_clr_color
        jsr scrn_clr
        rts

*=$5010
init_things
        jsr multiply_init
        rts

*=$5018
        jsr hires_clear
        rts

*=$5020
        jsr scrn_clr
        rts


*=$5a00   ; 0x104 bytes long

hires_end
        lda 53265
        and #$df
        sta 53265

        lda 53272
        and #$f7
        sta 53272

        rts

; color in color memory aka screen mem for hires
hcol_plot
        ; get base addr from table
        lda coord+1 ;y coord turns into row
        lsr
        lsr  ; only two shifts because table is two byte addrs
        and #$fe
        tay
        lda tab_scr,y
        sta write_col+1
        lda tab_scr+1,y
        sta write_col+2
        
        lda coord; x coord
        lsr
        lsr
        lsr
        tax

        lda plot_color
write_col
        sta $ffff,x
        rts

; hires drawing routine!

hplotxy
        stx coord
        sty coord+1

        ;jsr hcol_plot  ; fill in the color portion!

        ;get base addr from table
        lda coord+1
        lsr
        lsr
        and #$3e
        tay
        lda table1,y
        sta read_pix+1
        sta write_pix+1
        lda table1+1,y
        sta read_pix+2
        sta write_pix+2

        ; generate offset
        lda coord+1
        and #$07
        sta tmp
        lda coord
        and #$f8
        ora tmp
        tax

        ; generate bitmsk
        lda coord
        and #$07
        tay

        ; perform screen update
read_pix
        lda $a0a0,x
        ora table2,y
write_pix
        sta $a0a0,x
        
        rts

coord
        byte 96, 50

tmp
        byte 0


; start address of the 25 rows

; shifted right by 32 + 128 = 160 pixels to mid-screen
; for use with signed 7-bit numbers

; row starts of hires screen
; shifted to right by 32 bytes (32pix) to center 256 pixel image
table1
        byte $8020, $8160, $82a0, $83e0
        byte $8520, $8660, $87a0, $88e0
        byte $8A20, $8B60, $8Ca0, $8De0
        byte $8F20, $9060, $91a0, $92e0
        byte $9420, $9560, $96a0, $97e0
        byte $9920, $9A60, $9Ba0, $9Ce0
        byte $9e20
table2
        byte $80, $40, $20, $10, $08, $04, $02, $01

; text screen for color memory in bitmap mode
tab_scr        
        byte $a404, $a42c, $a454, $a47c
        byte $a4A4, $a4Cc, $a4F4, $a51c
        byte $a544, $a56c, $a594, $a5Bc
        byte $a5E4, $a60c, $a634, $a65c
        byte $a684, $a6Ac, $a6D4, $a6Fc
        byte $a724, $a74c, $a774, $a79c
        byte $a79c

;     byte $414, $43c, $464, $48c
;       byte $4b4, $4dc, $504, $52c
;       byte $554, $57c, $5a4, $5cc
;       byte $5f4, $61c, $644, $66c
;       byte $694, $6bc, $6e4, $70c
;       byte $734, $75c, $784, $7ac
;       byte $7d4

hires_start

        ; bank out the BASIC ROM, so hires screen can start at $a000
        lda $01
        and #$fe   ;we turn off the BASIC here
        
        sta $01    ;the cpu now sees RAM everywhere except at $d000-$dfff, where still the registers of
                   ;SID/VICII/etc are visible
                  ; and e000-ffff where the kernal is visible

        ; set the vic base address to $8000
        lda $dd00
        and #$fc
        ora #$01    ; page 2 = $8000
        sta $dd00

        ; set the VM13 bit in $d018, (53272) memory points
        ; bitmap at $a000
        ; screenmem (for colors) at $ac00
        lda $d018
        lda #$90
        sta $d018
        

       ; switch to hires mode
        lda 53265   ; $d011
        ora #$20
        sta 53265

        ; set character set (this is prob unnecessary)
        ;llda 53272   ; $d018
        ;ora #$08
        ;sta 53272

        rts



; fill text screen with scrn_clr_color
scrn_clr
        ldx #$00
        lda scrn_clr_color
scrn_clr_loo
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        dex
        bne scrn_clr_loo
        rts

; fill hires screen with scrn_clr_color
hires_clear
        ; clear screen
        ldx #$00
        lda scrn_clr_byte

hires_clear_lp
        sta $8000,x
        sta $8100,x
        sta $8200,x
        sta $8300,x
        sta $8400,x
        sta $8500,x
        sta $8600,x
        sta $8700,x
        sta $8800,x
        sta $8900,x
        sta $8a00,x
        sta $8b00,x
        sta $8c00,x
        sta $8d00,x
        sta $8e00,x
        sta $8f00,x
        sta $9000,x
        sta $9100,x
        sta $9200,x
        sta $9300,x
        sta $9400,x
        sta $9500,x
        sta $9600,x
        sta $9700,x
        sta $9800,x
        sta $9900,x
        sta $9a00,x
        sta $9b00,x
        sta $9c00,x
        sta $9d00,x
        sta $9e00,x
        sta $9f00,x
        dex
        bne hires_clear_lp
        
        rts


; use raster value to slowly erase screen?!?!
erasing_01
        ldx $d012
        stx erase_me+1

        lda #$00
erase_me
        sta $a000,x
        sta $a100,x
        sta $a200,x
        sta $a300,x
        sta $a400,x
        sta $a500,x
        sta $a600,x
        sta $a700,x
        sta $a800,x
        sta $a900,x
        sta $aa00,x
        sta $ab00,x
        sta $ac00,x
        sta $ad00,x
        sta $ae00,x
        sta $af00,x
        sta $b000,x
        sta $b100,x
        sta $b200,x
        sta $b300,x
        sta $b400,x
        sta $b500,x
        sta $b600,x
        sta $b700,x
        sta $b800,x
        sta $b900,x
        sta $ba00,x
        sta $bb00,x
        sta $bc00,x
        sta $bd00,x
        sta $be00,x
        sta $bf00,x

        rts

