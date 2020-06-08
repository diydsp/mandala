*=$b800

tmp_xy
        byte 0,0

yoyo_move
        jsr yoyo1   ; compute positions


        ; do the plotting
        ldy my_xy
        ldx cos_table,y
        ldy my_xy+1
        jsr mul     ; result in y:x
        txa         ; 2x to shift decimal point 
        rol
        tya
        rol

        clc
        adc #128           ; shift to middle of screen
        tax
        sta tmp_xy


        ldy my_xy
        ldx sin_table,y
        ldy my_xy+1
        jsr mul
        txa         ; 2x to shift decimal point 
        rol
        tya
        rol

        clc
        adc #100           ; shift to middle of screen 
        tay
                
        ldx tmp_xy
        jsr hplotxy

        jmp yoyo_move


        
        

my_xy
        byte 0,0 

delta_pos
        byte 1, 1

yoyo1

        ; increment positions
        lda my_xy
        clc
        adc delta_pos
        sta my_xy


        lda my_xy+1
        clc
        adc delta_pos+1
        sta my_xy+1


        ; check bounds
        lda my_xy
        sec
        sbc #127
        bvc lbl_1
        eor #$80
lbl_1
        bpl too_high

        lda my_xy
        sec
        sbc #-127
        bvc lbl_2
        eor #$80
lbl_2
        bmi too_low

its_equal_ok
        jmp done1

too_low
        lda #$01
        sta delta_pos
        jmp done1
        
too_high
        lda #$ff
        sta delta_pos
done1




yoyo2
        lda my_xy+1
        sec
        sbc #99
        bvc lbl_12
        eor #$80
lbl_12
        bpl too_high2

        lda my_xy+1
        sec
        sbc #-99
        bvc lbl_22
        eor #$80
lbl_22
        bmi too_low2

its_equal_ok2
        jmp done2

too_low2
        lda #$01
        sta delta_pos+1
        jmp done2
        
too_high2
        lda #$ff
        sta delta_pos+1
done2


        rts




