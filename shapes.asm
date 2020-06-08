*=$9600


; s+14 = $590e
; s+15 = $590f
; s+18 = $5912
; s+19 = $5913

ANG_DELT   = $990e
ANG_DELT_L = $990f
RAD_DELT   = $9912
RAD_DELT_L = $9913

MANDALA_DRAW    = $9920

shape_square
        jsr shape_out
        jsr MANDALA_DRAW
        jsr shape_cw
        jsr MANDALA_DRAW
        jsr shape_in
        jsr MANDALA_DRAW
        jsr shape_ccw
        jsr MANDALA_DRAW
        rts
        
shape_diamond
        jsr shape_out
        jsr MANDALA_DRAW
        jsr shape_cw
        jsr MANDALA_DRAW
        jsr shape_in
        jsr MANDALA_DRAW
        jsr shape_ccw
        jsr MANDALA_DRAW
        rts


; ang_delt, ang_delt_low, radius_delt, radius_delt_low
mouse_outwards
        byte 0,0,1,0
mouse_clockwise
        byte 1,0,0,0
mouse_inwards
        byte 0,0,$ff,0
mouse_counterclockwise
        byte $ff,0,0,0

; diamond
mouse_45
        byte 1,0,1,0
mouse_135
        byte $ff,0,1,0
mouse_225
        byte $ff,0,$ff,0
mouse_315
        byte 1,0,$ff,0

; uses these two zero-pages, $fc-$fd, could interfere with multiply routine!
PTR_SHAPE       = $fc  ;result lo
shape_config
        ldy #$00
        lda ($fc),y
        sta ANG_DELT
        iny
        lda ($fc),y
        STA ANG_DELT_L
        iny
        lda ($fc),y
        sta RAD_DELT
        iny
        lda ($fc),y
        sta RAD_DELT_L
        rts

shape_out
        lda #<mouse_outwards
        sta $fc
        lda #>mouse_outwards
        sta $fd
        jsr shape_config
        rts

shape_cw
        lda #<mouse_clockwise
        sta $fc
        lda #>mouse_clockwise
        sta $fd
        jsr shape_config
        rts

shape_in
        lda #<mouse_inwards
        sta $fc
        lda #>mouse_inwards
        sta $fd
        jsr shape_config
        rts

shape_ccw
        lda #<mouse_counterclockwise
        sta $fc
        lda #>mouse_counterclockwise
        sta $fd
        jsr shape_config
        rts



shape_list
        byte <shape_square, >shape_diamond


