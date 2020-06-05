100 poke s+8, 16: rem screen clear color
110 poke s+9, 0: rem scren clear byte (hires)

120 poke s+3, 85: poke s+5, 3 : rem angle add, num points
130 poke s+6, 127: rem radius
140 poke s+7, 127: rem num iterations

150 poke s+11, 64: rem plot color
160 poke s+12, 0: poke s+13, 0: rem angle 
170 poke s+16,50: poke s+17, 0: rem radius
180 poke s+14, 1: poke s+15, 0: rem angle delta
190 poke s+18, 0: poke s+19, 64: rem radius delta
195 poke s+20,20: poke s+21, 0 : rem ratchet angle, radius

200 sys ia:sys ih: sys sc:sys hc
205 goto 790

599 rem polygon.  angle add, num points
600 xx = 1 + int(rnd(1)*7): on xx gosub 620,620,630,640,650,660,670
605 return
610 poke s+3, 85: poke s+5, 3 : return
620 poke s+3, 64: poke s+5, 4 : return
630 poke s+3, 51: poke s+5, 5 : return
640 poke s+3, 43: poke s+5, 6 : return
650 poke s+3, 32: poke s+5, 8 : return
660 poke s+3, 28: poke s+5, 9 : return
670 poke s+3, 21: poke s+5, 12 : return

790 gosub 670 : rem polygon
791 poke s+20,16 : rem ratchet angle
792 pokes+11,16* 5 : rem color
795 poke s+18,   0: poke s+19, 0: rem radius delta
798 poke s+14,   0: poke s+15, 0: rem angle delta
799 poke s+12,0 : rem angle
800 gosub 820
810 poke s+14, 255: poke s+15, 0: rem angle delta
812 pokes+11,16* 2: rem color
814 poke s+12,0 : rem angle
815 gosub 820
818 end

820 for t=0to64step16
830 pokes+16,0: rem angle, radius
835 sysma
840 next 
850 return

