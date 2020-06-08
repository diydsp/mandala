


*=$9000

into_hires
        jsr hires_start
        rts
*=$9008
        lda scrn_clr_color
        jsr scrn_clr
        rts

*=$9010
init_things
        jsr multiply_init
        rts

*=$9018
        jsr hires_clear
        rts

*=$9020
        jsr scrn_clr
        rts

*=$9028
        jsr hplot_set_mode
        rts

*=$9030
        jsr hplot_unset_mode
        rts

*=$9a00   ; 0x104 bytes long

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

; config hplotxy to set or unset value
hplot_set_mode ; default, turns pix on via: ora table2,y
        lda #$19
        sta read_pix+3  ; opcode ora $xxxx,y
        lda #<table2
        sta read_pix+4  ; table2 lo byte
        lda #>table2
        sta read_pix+5  ; table2 hi byte
        rts

hplot_unset_mode  ; turns pix off via: and table3,y
        lda #$39
        sta read_pix+3  ; opcode and $xxxx,y
        lda #<table3
        sta read_pix+4  ; table2 lo byte
        lda #>table3
        sta read_pix+5  ; table2 hi byte
        rts

; hires drawing routine!
hplotxy
        stx coord
        sty coord+1

        jsr hcol_plot  ; fill in the color portion!
        ldx coord

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
        byte $4020, $4160, $42a0, $43e0
        byte $4520, $4660, $47a0, $48e0
        byte $4A20, $4B60, $4Ca0, $4De0
        byte $4F20, $5060, $51a0, $52e0
        byte $5420, $5560, $56a0, $57e0
        byte $5920, $5A60, $5Ba0, $5Ce0
        byte $5e20
table2
        byte $80, $40, $20, $10, $08, $04, $02, $01  ; foregronud
table3
        byte $7f, $bf, $df, $ef, $f7, $fb, $fd, $fe  ; background

; text screen for color memory in bitmap mode
tab_scr        
        byte $6004, $602c, $6054, $607c
        byte $60A4, $60Cc, $60F4, $611c
        byte $6144, $616c, $6194, $61Bc
        byte $61E4, $620c, $6234, $625c
        byte $6284, $62Ac, $62D4, $62Fc
        byte $6324, $634c, $6374, $639c
        byte $63c4

;     byte $414, $43c, $464, $48c
;       byte $4b4, $4dc, $504, $52c
;       byte $554, $57c, $5a4, $5cc
;       byte $5f4, $61c, $644, $66c
;       byte $694, $6bc, $6e4, $70c
;       byte $734, $75c, $784, $7ac
;       byte $7d4

hires_start


        ; set the vic base address to $4000
        lda $dd00
        and #$fc
        ora #$02   ;  $4000
        sta $dd00

        ;  VM13 bit in $d018, (53272) memory points
        ; bitmap at $400
        ; screenmem (for colors) at $cc00
        lda $d018
        lda #$80
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
        sta $6000,x
        sta $60fa,x
        sta $61f4,x
        sta $62ee,x
        dex
        bne scrn_clr_loo
        rts

; fill hires screen with scrn_clr_color
hires_clear
        ; clear screen
        ldx #$00
        lda scrn_clr_byte

hires_clear_lp
        sta $4000,x
        sta $4100,x
        sta $4200,x
        sta $4300,x
        sta $4400,x
        sta $4500,x
        sta $4600,x
        sta $4700,x
        sta $4800,x
        sta $4900,x
        sta $4a00,x
        sta $4b00,x
        sta $4c00,x
        sta $4d00,x
        sta $4e00,x
        sta $4f00,x
        sta $5000,x
        sta $5100,x
        sta $5200,x
        sta $5300,x
        sta $5400,x
        sta $5500,x
        sta $5600,x
        sta $5700,x
        sta $5800,x
        sta $5900,x
        sta $5a00,x
        sta $5b00,x
        sta $5c00,x
        sta $5d00,x
        sta $5e00,x
        sta $5f00,x
        dex
        bne hires_clear_lp
        
        rts


; use raster value to slowly erase screen?!?!
erasing_01
        ldx $d012
        stx erase_me+1

        lda #$00
erase_me
        ;sta $a000,x
        ;sta $a100,x
        ;sta $a200,x
        ;sta $a300,x
        ;sta $a400,x
        ;sta $a500,x
        ;sta $a600,x
        ;sta $a700,x
        ;sta $a800,x
        ;sta $a900,x
        ;sta $aa00,x
        ;sta $ab00,x
        ;sta $ac00,x
        ;sta $ad00,x
        ;sta $ae00,x
        ;sta $af00,x
        ;sta $b000,x
        ;sta $b100,x
        ;sta $b200,x
        ;sta $b300,x
        ;sta $b400,x
        ;sta $b500,x
        ;sta $b600,x
        ;sta $b700,x
        ;sta $b800,x
        ;sta $b900,x
        ;sta $ba00,x
        ;sta $bb00,x
        ;sta $bc00,x
        ;sta $bd00,x
        ;sta $be00,x
        ;sta $bf00,x

        rts

