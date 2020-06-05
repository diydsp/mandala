 *=$5100

        
 

scroller_init

        lda #<scroll_text
        sta scrl_read_byte+1
        lda #>scroll_text
        sta scrl_read_byte+2

        rts



scrl_update

        ; shift chars
        jsr scrl_shift

        ; draw column
        jsr scrl_rend_colm

        rts

scrl_colm
        byte 1   ; (reverse) column rendering, 7-0
scrl_char_idx
        byte 0   ; which PETSCI char rendering, 0-255
scrl_char
        byte 0,0,0,0, 0,0,0,0  ; entire character




scrl_clr_pix = $20
scrl_set_pix = 160

scrl_pix_set
        byte $51
scrl_pix_clr
        byte $20

scrl_rend_colm

        lda scrl_colm
        cmp #$03
        bne one_col_at_time
        ;jsr snd_ungate

one_col_at_time
        ; one column at a time
        ldx scrl_colm
        dex
        stx scrl_colm
        beq fetch_new_char
scrl_char_ok

        ; move through 8 rows
        ;ldy #scrl_clr_pix        ; char drawn for clear pixel
        ldy scrl_pix_clr
        rol scrl_char
        bcc scrl_bit_clr0
        ;ldy #scrl_set_pix        ; char drawn for set pixel
        ldy scrl_pix_set
scrl_bit_clr0
        sty $06cf     ; 1024 + 40 * 17 + 39

        ;ldy #scrl_clr_pix        ; char drawn for clear pixel
        ldy scrl_pix_clr
        rol scrl_char+1
        bcc scrl_bit_clr1
        ;ldy #scrl_set_pix        ; char drawn for set pixel
        ldy scrl_pix_set
scrl_bit_clr1
        sty $06f7    ; 1024 + 40 * 17 + 39

        ;ldy #scrl_clr_pix        ; char drawn for clear pixel
        ldy scrl_pix_clr
        rol scrl_char+2
        bcc scrl_bit_clr2
        ;ldy #scrl_set_pix        ; char drawn for set pixel
        ldy scrl_pix_set
scrl_bit_clr2
        sty $071f    ; 1024 + 40 * 17 + 39

        ;ldy #scrl_clr_pix        ; char drawn for clear pixel
        ldy scrl_pix_clr
        rol scrl_char+3
        bcc scrl_bit_clr3
        ;ldy #scrl_set_pix        ; char drawn for set pixel
        ldy scrl_pix_set
scrl_bit_clr3
        sty $0747    ; 1024 + 40 * 17 + 39

        ;ldy #scrl_clr_pix        ; char drawn for clear pixel
        ldy scrl_pix_clr
        rol scrl_char+4
        bcc scrl_bit_clr4
        ;ldy #scrl_set_pix        ; char drawn for set pixel
        ldy scrl_pix_set
scrl_bit_clr4
        sty $076f    ; 1024 + 40 * 17 + 39

        ;ldy #scrl_clr_pix        ; char drawn for clear pixel
        ldy scrl_pix_clr
        rol scrl_char+5
        bcc scrl_bit_clr5
        ;ldy #scrl_set_pix        ; char drawn for set pixel
        ldy scrl_pix_set
scrl_bit_clr5
        sty $0797    ; 1024 + 40 * 17 + 39

        ;ldy #scrl_clr_pix        ; char drawn for clear pixel
        ldy scrl_pix_clr
        rol scrl_char+6
        bcc scrl_bit_clr6
        ;ldy #scrl_set_pix        ; char drawn for set pixel
        ldy scrl_pix_set
scrl_bit_clr6
        sty $07bf    ; 1024 + 40 * 17 + 39

        ;ldy #scrl_clr_pix        ; char drawn for clear pixel
        ldy scrl_pix_clr
        rol scrl_char+7
        bcc scrl_bit_clr7
        ;ldy #scrl_set_pix        ; char drawn for set pixel
        ldy scrl_pix_set
scrl_bit_clr7
        sty $07e7    ; 1024 + 40 * 17 + 39

        rts
        

char_rom_addr
        byte 0,0

char_temp_char
        byte 0

; fetch new char, writes char to scrl_char
fetch_new_char
        jsr please_scrl_read_byte ; returns in acc
        bne nrml_print_char
        jmp scrl_ctrl_found

        ; otherwise normal printed character
        ; render alphabet idx into 8-byte char data via Char ROM 
nrml_print_char

        sta char_temp_char
        ;jsr sound_tone
        lda char_temp_char

        sta scrl_char_idx

        ; using idx, get the 8-byte character data
        sta char_rom_addr      ; low_byte
        ldx #$00
        stx char_rom_addr+1    ; high byte

        ; multiply byte 8
        clc
        rol char_rom_addr
        rol char_rom_addr+1
        clc
        rol char_rom_addr
        rol char_rom_addr+1
        clc
        rol char_rom_addr
        rol char_rom_addr+1

        ; add base addr $d000 (char rom addr)
        lda #$00
        clc
        adc char_rom_addr
        sta char_rom_addr
        lda #$d0
        adc char_rom_addr+1
        sta char_rom_addr+1

        ; modify read instruction
        lda char_rom_addr  ; low byte
        sta char_rom_read+1
        lda char_rom_addr+1 ; high byte
        sta char_rom_read+2

        ; fetch 8 bytes of char data
        lda #$33   ; point to char rom at $d000
        sta $01
        ;sei        ; disable ints during copying

        ldx #$08
scrl_char_fetch_byte
        dex
char_rom_read
        lda char_rom_addr,x
        sta scrl_char,x
        txa    ; update flags
        beq scrl_char_fetch_done
        jmp scrl_char_fetch_byte
scrl_char_fetch_done

        ;cli        ; restore ints after copying
        lda #$35   ; point to mem at $d000
        sta $01

        lda #$08          ; reload column idx
        sta scrl_colm

        jsr incr_scrl_pos

        jmp scrl_char_ok

; read current byte of scroll text
please_scrl_read_byte   
scrl_read_byte
        lda scroll_text  ; gets modified in-place
        rts

; increment position in scroll text
incr_scrl_pos
        clc
        lda scrl_read_byte+1   ; lo byte
        adc #$01
        sta scrl_read_byte+1
        lda scrl_read_byte+2
        adc #$00
        sta scrl_read_byte+2
        rts

; temp storage for calling subroutine
reg_tmp
        byte 0, 0, 0; acc,x,y

scrl_ctrl_found

        ; lo-byte target address
        jsr incr_scrl_pos
        jsr please_scrl_read_byte
        sta scrl_seq_call+1  ; lo-byte
       
        ; hi-byte target address
        jsr incr_scrl_pos
        jsr please_scrl_read_byte
        sta scrl_seq_call+2  ; lo-byte

        ; accumulator value
        jsr incr_scrl_pos
        jsr please_scrl_read_byte
        sta reg_tmp

        ; x register value
        jsr incr_scrl_pos
        jsr please_scrl_read_byte
        sta reg_tmp+1

        ; y register value
        jsr incr_scrl_pos
        jsr please_scrl_read_byte
        sta reg_tmp+2

        lda scrl_seq_call+1   ; development verification
        ldx scrl_seq_call+2
        lda reg_tmp           ; recall three regs
        ldx reg_tmp+1
        ldy reg_tmp+2

        ; uncomment to make actual subroutine jsr call, modified by above
        jsr please_scrl_seq_call

        ; point to next byte in sequence
        jsr incr_scrl_pos
        
        ; keep looking for more chars (could drop of too much CPU)
        jmp fetch_new_char

please_scrl_seq_call
scrl_seq_call
        jsr scrl_seq_call        ; gets modified by above code
        rts

                


scrl_shift
        ldy #39
        ldx #$00
scrl_shift_loop
        lda $6a9,x
        sta $6a8,x
        lda $6d1,x
        sta $6d0,x
        lda $6f9,x
        sta $6f8,x
        lda $721,x
        sta $720,x
        lda $749,x
        sta $748,x
        lda $771,x
        sta $770,x
        lda $799,x
        sta $798,x
        lda $7c1,x
        sta $7c0,x
        inx
        dey
        bne scrl_shift_loop

        rts



set_bg_fg_col
        sta $d020
        stx $d021
        rts

reset_scroll_text
        lda #<scroll_text
        sta scrl_read_byte+1
        lda #>scroll_text
        sta scrl_read_byte+2
        rts


color_row_start_lows
        byte $a8,$d0,$f8,$20, $48,$70,$98,$c0
color_row_start_his
        byte $da,$da,$da,$db, $db,$db,$db,$db 
color_mem_hline_col
        byte 0

; a = color
; x = row number
; y = countdown
color_mem_hline        

        ; save val
        sta color_mem_hline_col
        
        ; modify address
        lda color_row_start_lows,x
        sta color_byte_write+1
        lda color_row_start_his,x
        sta color_byte_write+2

        ; loop through whole row
        ;ldx #40
cbyte_next
        dey
        lda color_mem_hline_col
color_byte_write
        sta $d800,y
        tya
        bne cbyte_next
        rts




clr_screen
        ldx #$fa     ;   250 x4 -> 1000 chars on screen    

clear01
        sta $0400,x     ; 400 default screen memory
        sta $04fa,x
        sta $05f4,x
        sta $06ee,x

        dex
        bne clear01
        rts


set_plot_chars
        sta scrl_pix_set
        stx scrl_pix_clr
        rts

set_snd_root
        ;sta snd_root
        rts

set_snd_chord
        ;sta snd_chord+1
        ;stx snd_chord+2
        ;sty snd_chord+3
        rts


scroll_text
        byte '   '
        ;byte '-     -    -   -  - -- -  -   -    -  '
        ;byte 0, <color_mem_hline, >color_mem_hline, 14, 0, 40
        ;byte 0, <color_mem_hline, >color_mem_hline, 14, 1, 40
        ;byte 0, <color_mem_hline, >color_mem_hline, 14, 2, 40
        ;byte 0, <color_mem_hline, >color_mem_hline, 14, 3, 40
        ;byte 0, <color_mem_hline, >color_mem_hline, 14, 4, 40
        ;byte 0, <color_mem_hline, >color_mem_hline, 14, 5, 40
        ;byte 0, <color_mem_hline, >color_mem_hline, 14, 6, 40
        ;byte 0, <color_mem_hline, >color_mem_hline, 14, 7, 40
        ;byte 0, <set_plot_chars, >set_plot_chars, 160, 32, 0
        ;byte 0, <set_snd_root,   >set_snd_root, 7, 0, 0
        ;byte 0, <set_snd_chord,  >set_snd_chord, 4, 7, 10
        byte '    hello     '

        byte 0, <clr_screen, >clr_screen, $20, 0, 0
        byte 'b y e !                            '

        byte 0, <reset_scroll_text, >reset_scroll_text, 0,0,0
        

