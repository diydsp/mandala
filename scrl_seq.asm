*=$5400

scrl_seq_base_init
; scroll seq parameters
        lda #$01
        ldx #$01
        ldy #$01
        jsr scrl_seq_init$
        rts
                        
; these are the functions that get called by the timer
scrl_seq_down_slope
        ;inc $0410
        rts

scrl_seq_up_slope
        ;inc $0411
        jsr scrl_update
        rts

scrl_seq_init$

        sta scrl_seq_low
        stx scrl_seq_high
        sty scrl_seq_ctr
        
        ; initial call vector
        lda #<scrl_seq_down
        ldx #>scrl_seq_down
        jmp scrl_seq_addr_write

        rts


scrl_seq_addr_write
        sta scrl_seq_addr$+1
        stx scrl_seq_addr$+2
        ;lda #<scrl_seq_up
        ;sta stimulus_seq_addr+1
        ;lda #>scrl_seq_up
        ;sta stimulus_seq_addr+2

        rts
scrl_reinit
        ; re-load
        lda scrl_seq_high
        sta scrl_seq_ctr
        
        ; action
        jsr scrl_seq_down_slope

        ; change call vector
        lda #<scrl_seq_up
        ldx #>scrl_seq_up
        jmp scrl_seq_addr_write

; sequencer function
scrl_seq_down

        ; log
        ;lda scanline
        ;sta scanline_log
        ;inc scanline_log        
        
        dec scrl_seq_ctr
        beq scrl_reinit
        rts







scrl_reinit_up
        ; reload
        lda scrl_seq_low
        sta scrl_seq_ctr

        ; action
        jsr scrl_seq_up_slope

        ; change call vector
        lda #<scrl_seq_down
        ldx #>scrl_seq_down
        jmp scrl_seq_addr_write

        rts

scrl_seq_up

        ;lda scaline
        ;sta scanline_log
        ;inc scanline_log
        
        dec scrl_seq_ctr
        beq scrl_reinit_up
        rts


scrl_seq_low
        byte $00
scrl_seq_high
        byte $00
scrl_seq_ctr
        byte $00








