

; BASIC header
;*=$0802
;        byte 1,0,0
;        byte $9e,'6144',0,0,0   ; SYS 2061


*=$c000


main
        sei
        lda $dc0e
        and #$fe
        sta $dc0e   ; disable timer interrupt

        jsr song_irq_start
wait_here
        jmp wait_here
        
        jsr hires_start
        jsr multiply_init
        rts

        lda #$06
        sta scrn_clr_color
        jsr scrn_clr
        rts

refill_screen
        lda fill_val
        inc fill_val
        lda $cb      ; keyboard matrix
        sta scrn_clr_byte
        jsr hires_clear

        rts

        jsr mandala_test

        jmp refill_screen

fill_val
        byte $3f


;-----
        jsr scroller_init
        jsr scrl_seq_base_init
        ;jsr irq_test


        ;jmp yoyo_move

main_loop
        jsr mandala

        jsr erasing_01

        jmp main_loop

        ;jmp loop_start_02










scrl_seq_addr$
        jsr dummy_routine


;frame_no
;        byte $00

; not actually used, just for blank tabl
dummy_routine
        rts


mandala_test

        ldx #0
        ldy #0
        stx angle
        sty angle+1

        ldx #5
        ldy #0
        stx radius
        sty radius+1

        ldx #60
        ldy #0
        stx angle_delta
        sty angle_delta+1

        ldx #2
        ldy #0
        stx radius_delta
        sty radius_delta+1

        ldx #90
        stx angle_ratchet

        ldx #90
        stx radius_ratchet

        ldx #90
        ldy #0
        stx angle_delta2
        sty angle_delta2+1

        ldx #10
        ldy #0
        stx radius_delta2
        sty radius_delta2+1

        ldx #0
        ldy #10
        stx points_count
        sty points_count+1

        ldx #0
        ldy #100
        stx iters_count
        sty iters_count+1

        lda #10
        sta angle_bump

        lda #$25
        sta plot_color


        jsr mandala 

        rts



