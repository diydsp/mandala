


*=$bc00



;------- MULTIPLY ----------------------
;8x8bits -> 16 bits, signed input and output
;x*y -> y(hi) & x(lo)
;
;warning: there are quite a few undeclared
;zero page addresses used by the mulgen subroutine
;
;the routine is based on this equation:
;
; a*b = ((a+b)/2)^2-((a-b)/2)^2
;
;Oswald/Resource

XTMP     = $fb  ;temporary for X reg
RL       = $fc  ;result lo
RH       = $fd  ;result hi
;XTMP     = $e0  ;temporary for X reg
;RL       = $e1  ;result lo
;RH       = $e2  ;result hi

SQRL     = $e000 ;low bytes of: x=(x*x)/4; 512 entry on 16 bits
SQRH     = $e200 ;high bytes
ABS      = $e400 ;x=abs(x)
;SQRL     = $2000 ;low bytes of: x=(x*x)/4; 512 entry on 16 bits
;SQRH     = $2200 ;high bytes
;ABS      = $2400 ;x=abs(x)


        sei; disable ints so zero page unmolested

multiply_init
         JSR MULGEN    ;table setup
         JSR MKABS
        rts

testop
         LDX #$10
         LDY #$20
         JSR MUL      ;a test call to the multiply subroutine
         JMP *
         
;-----------------------------------------------------------

MKABS    LDX #$00     ;generating a table to get the absolute value of signed numbers
ABSLP    TXA
         BPL POS
         EOR #$FF
         CLC
         ADC #$01
POS      STA ABS,X
         DEX
         BNE ABSLP
         RTS

;the multiply routine itself         

MUL      STX XTMP     ;storing X for later use
         TYA
         EOR XTMP     ;getting the sign of the final product
         BMI NEG      ;take another routine if the final product will be negative



         LDA ABS,X    ;this is the (a+b) part, we strip a&b from their signs using the abs table.
         CLC          ;it is safe to force both numbers to be positive knowing the final sign of the product which we will set later
         ADC ABS,Y    ;this is done to avoid overflows, and the extra code/tables needed to handle them.
         STA XTMP

         LDA ABS,X    ;(abs(a)-abs(b)) 
         SEC
         SBC ABS,Y
         TAY

         LDX ABS,Y   ;((a-b)/2)^2 will be always positive so its safe to do abs(a-b)
         LDY XTMP    ;we do this since the sqr table can only handle positive numbers


         ;now we have a+b in Y and a-b in X


                     ;low 8 bits of the product calculated here
         LDA SQRL,Y  ;((a+b)/2)^2
         SEC
         SBC SQRL,X  ;-((a-b)/2)^2
         STA RL
                     ;same as above for high 8 bits
         LDA SQRH,Y
         SBC SQRH,X
         TAY
         LDX RL
         RTS

;case for negative final product, all the same except inverting the result at the end.

NEG      LDA ABS,X     
         CLC
         ADC ABS,Y
         STA XTMP

         LDA ABS,X
         SEC
         SBC ABS,Y
         TAY

         LDX ABS,Y
         LDY XTMP

         LDA SQRL,Y
         SEC
         SBC SQRL,X
         STA RL

         LDA SQRH,Y
         SBC SQRH,X
         STA RH

                   ;inverting the result's sign
         LDA RL
         EOR #$FF
         CLC
         ADC #$01
         STA RL
         LDA RH
         EOR #$FF
         ADC #$00
         STA RH

         LDY RH
         LDX RL
         RTS

;generating a 16 bit table with 512 entrys where x=(x*x)/4

MULGEN   LDA #1
         STA $c0F0
         ;STA $F0
         LDA #0
         STA $c0F1
         ;STA $F1

         LDA #0
         STA $c0F4
         ;STA $F4
         STA $c0F5
         ;STA $F5
         STA $c0F6
         ;STA $F6
         STA SQRL
         STA SQRH

         LDA #<SQRH
         STA $FE
         LDA #>SQRH
         STA $FF

         LDA #<SQRL
         ;STA $c0FA
         STA $FA
         LDA #>SQRL
         ;STA $c0FB
         STA $FB

         LDX #$01
         LDY #$01
FFV2

FFV
         LDA $c0F0
         ;LDA $F0
         CLC
         ADC $c0F4
         ;ADC $F4
         STA $c0F4
         ;STA $F4

         LDA $c0F1
         ;LDA $F1
         ADC $c0F5
         ;ADC $F5
         STA $c0F5
         ;STA $F5

         LDA $c0F6
         ;LDA $F6
         ADC #$00
         STA $c0F6
         ;STA $F6

         LDA $c0F6
         ;LDA $F6
         STA $c0B2
         ;STA $B2
         LDA $c0F5
         ;LDA $F5
         STA $c0B1
         ;STA $B1
         LDA $c0F4
         ;LDA $F4
         STA $c0B0
         ;STA $B0

         LSR $c0B2
         ;LSR $B2
         ROR $c0B1
         ;ROR $B1
         ROR $c0B0
         ;ROR $B0

         LSR $c0B2
         ;LSR $B2
         ROR $c0B1
         ;ROR $B1
         ROR $c0B0
         ;ROR $B0

         LDA $c0B0
         ;LDA $B0
         ;STA ($c0FA),Y
         STA ($FA),Y
         LDA $c0B1
         ;LDA $B1
         STA ($FE),Y

         LDA $c0F0
         ;LDA $F0
         CLC
         ADC #2
         STA $c0F0
         ;STA $F0
         BCC there
         ;BCC *+4
         INC $c0F1
         ;INC $F1


there    INY
         BNE FFV

         LDY #$00
         INC $FF
         INC $FB
         ;INC $c0FB
         DEX
         BPL FFV2

         RTS

