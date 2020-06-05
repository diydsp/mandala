10 print "testing"

15 poke 53280,0
20 ia = 20496 : rem init all
30 ih = 20480 : rem into hires
40 sc = 20488 : rem scrn clear color
50 ma = 22816 : rem mandala
60 eh = 23040 : rem end hires
70 hc = 20504 : rem hires clear 
80 s = 22784 : rem variables for mandala

100 poke s+8, 16: rem screen clear color
110 poke s+9, 0: rem scren clear byte (hires)

120 poke s+3, 85: poke s+5, 3 : rem angle add, num points
130 rem poke s+6, 127: rem radius
140 poke s+7, 127: rem num iterations

150 poke s+11, 64: rem plot color
160 poke s+12, 0: poke s+13, 0: rem angle 
170 poke s+16,50: poke s+17, 0: rem radius
180 poke s+14, 0: poke s+15, 0: rem angle delta
190 poke s+18, 0: poke s+19, 0: rem radius delta
195 poke s+20, 0: poke s+21, 0 : rem ratchet angle, radius

197 sys ia:sys ih: sys sc:sys hc

