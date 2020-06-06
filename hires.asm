


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

        jsr hcol_plot  ; fill in the color portion!

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
        byte $e020, $e160, $e2a0, $e3e0
        byte $e520, $e660, $e7a0, $e8e0
        byte $eA20, $eB60, $eCa0, $eDe0
        byte $eF20, $f060, $f1a0, $f2e0
        byte $f420, $f560, $f6a0, $f7e0
        byte $f920, $fA60, $fBa0, $fCe0
        byte $fe20
table2
        byte $80, $40, $20, $10, $08, $04, $02, $01

; text screen for color memory in bitmap mode
tab_scr        
        byte $cc04, $cc2c, $cc54, $cc7c
        byte $ccA4, $ccCc, $ccF4, $cd1c
        byte $cd44, $cd6c, $cd94, $cdBc
        byte $cdE4, $ce0c, $ce34, $ce5c
        byte $ce84, $ceAc, $ceD4, $ceFc
        byte $cf24, $cf4c, $cf74, $cf9c
        byte $cfc4

;     byte $414, $43c, $464, $48c
;       byte $4b4, $4dc, $504, $52c
;       byte $554, $57c, $5a4, $5cc
;       byte $5f4, $61c, $644, $66c
;       byte $694, $6bc, $6e4, $70c
;       byte $734, $75c, $784, $7ac
;       byte $7d4

hires_start


        ; set the vic base address to $c000
        lda $dd00
        and #$fc
        ora #$00   ; page 0= $c000
        sta $dd00

        ; set the VM13 bit in $d018, (53272) memory points
        ; bitmap at $e000
        ; screenmem (for colors) at $cc00
        lda $d018
        lda #$38
        sta $d018
        

       ; switch to hires mode
        lda 53265   ; $d011
        ora #$20
        sta 53265

        ; bank out the BASIC ROM, so hires screen can start at $a000
        lda $01
        and #$f8   ;we turn off BASIC, char rom and kernal
        
        sta $01    ;the cpu now sees RAM everywhere except at $d000-$dfff, where still the registers of
                   ;SID/VICII/etc are visible

        rts



; fill text screen with scrn_clr_color
scrn_clr
        ldx #$00
        lda scrn_clr_color
scrn_clr_loo
        sta $cc00,x
        sta $ccfa,x
        sta $cdf4,x
        sta $ceee,x
        dex
        bne scrn_clr_loo
        rts

; fill hires screen with scrn_clr_color
hires_clear
        ; clear screen
        ldx #$00
        lda scrn_clr_byte

hires_clear_lp
        sta $e000,x
        sta $e100,x
        sta $e200,x
        sta $e300,x
        sta $e400,x
        sta $e500,x
        sta $e600,x
        sta $e700,x
        sta $e800,x
        sta $e900,x
        sta $ea00,x
        sta $eb00,x
        sta $ec00,x
        sta $ed00,x
        sta $ee00,x
        sta $ef00,x
        sta $f000,x
        sta $f100,x
        sta $f200,x
        sta $f300,x
        sta $f400,x
        sta $f500,x
        sta $f600,x
        sta $f700,x
        sta $f800,x
        sta $f900,x
        sta $fa00,x
        sta $fb00,x
        sta $fc00,x
        sta $fd00,x
        sta $fe00,x
        sta $ff00,x
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

