

*=$5900


my_xy
        byte 0,0

angle_tmp
        byte 0   ; s+2
angle_bump
        byte 10  ; s+3
points_count
        byte 0,4;  current, max, points within single iteration  ; s+4, s+5
iters_count
        byte 0,10; current, max, total iterations with multiple points each

scrn_clr_color
        byte $01
scrn_clr_byte
        byte $00
old_base_angle_add ; not used anymore
        byte $00
plot_color
        byte $25

; new school
angle
        byte 0,0
angle_delta
        byte 0,0
radius
        byte 0,0
radius_delta
        byte 0,0
angle_ratchet
        byte 0
radius_ratchet
        byte 0
radius_delta2
        byte 0,0
angle_delta2
        byte 0,0

*=$5920
mandala

        lda angle
        sta angle_tmp

        ; number of iters_count
        lda iters_count+1
        sta iters_count

mandala_outer
        ; number of points in e.g. star
        lda points_count+1
        sta points_count

mandala_sub
        ldy angle_tmp
        ldx cos_table,y
        ldy radius
        jsr mul     ; result in y:x
        txa         ; 2x to shift decimal point 
        rol
        tya
        rol

        clc
        adc #128           ; shift to middle of screen
        tax
        sta my_xy


        ldy angle_tmp
        ldx sin_table,y
        ldy radius
        jsr mul
        txa         ; 2x to shift decimal point 
        rol
        tya
        rol

        clc
        adc #100           ; shift to middle of screen 
        tay
                
        ldx my_xy
        jsr hplotxy

        ; advance to next point
        lda angle_tmp
        clc
        adc angle_bump
        sta angle_tmp

        
        ; more points left?
        dec points_count
        bne mandala_sub

        ; ready for next time
        jsr radius_delta_incr

        ; more iters left?
        dec iters_count
        bne mandala_outer

        ; ratchet/save iterated values for next call
        clc
        lda angle_tmp
        adc angle_ratchet
        sta angle

        clc
        lda radius_ratchet
        adc radius
        sta radius

        rts


radius_delta_incr
        clc
        lda radius+1
        adc radius_delta+1
        sta radius+1
        lda radius
        adc radius_delta
        sta radius

        clc
        lda angle+1
        adc angle_delta+1
        sta angle+1
        lda angle
        adc angle_delta
        sta angle
        sta angle_tmp
        rts
*=$59d0
radius_delta2_incr
        clc
        lda radius+1
        adc radius_delta2+1
        sta radius+1
        lda radius
        adc radius_delta2
        sta radius

        clc
        lda angle+1
        adc angle_delta2+1
        sta angle+1
        lda angle
        adc angle_delta2
        sta angle
        sta angle_tmp
        rts
