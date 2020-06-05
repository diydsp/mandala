*=$5500

; not perfect, needs some work when x is near 0.
col_next

        ; decrement col_pos
        ldx col_pos
        bne col_pos_dec
        ldx col_max      ; reload to max value
col_pos_dec
        dex
        stx col_pos

        lda col_data,x
        sta col_cur
        
        ; data must be found in higher bits
        asl
        asl
        asl
        asl
        sta $590b  ; store directly into color draw variable!
        ;jmp col_next  ; uncomment for debugging

        rts


col_cur
        byte 1
col_pos
        byte 0  ; current, max_len, including zero
col_max
        byte 25
col_data
        byte $6,$9,$b,$2, $4,$8,$e,$a, $5,$3,$f,$7, $1
        byte $7,$f,$3,$5, $a,$e,$8,$4, $2,$b,$9,$6
