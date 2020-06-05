
250 goto 400

300 for x=1to20
310 poke s+16, int(rnd(1)*127): poke s+17, 0: rem radius
320 poke s+11, int(rnd(1)*16)*16: rem plot color
330 gosub 1200
340 poke s+12, int(rnd(1)*256): poke s+13, 0: rem angle 
350 poke s+7, 3+int(rnd(1)*10): rem num iterations "shape size"
360 r = 1 + int(rnd(1)*2): on r gosub 1300, 1500
370 next
375 sys hc
380 goto300

400 ra = 120 
402 rem poke s+24, 4: poke s+25, 0: rem delta2
405 sh = 1 + int(rnd(1)*2):
410 co =     int(rnd(1)*16)*16
420 an =     int(rnd(1)*256)
430 si = 3 + int(rnd(1)*10)
440 xx = 1 + int(rnd(1)*7): 
455 sys 21760: rem color sequencer
458 rem sys 22992: rem radius delta2 incr
460 poke s+16, ra: poke s+17, 0: rem radius
470 rem poke s+11, co: rem plot color
480 poke s+12, an: poke s+13, 0: rem angle 
490 poke s+7,  si: rem num iterations "shape size"
500 gosub 1200: rem xx, angular
510 on sh gosub 600, 1500 : rem shape
520 ra = ra - si: if ra > 10 goto 455 : rem or 460 or 410
530 sys hc
540 goto 400

600 sys 22016: rem square

1200 rem polygon.  angle add, num points
1210 on xx gosub 1230,1240,1250,1260,1270,1280,1290
1220 return
1230 poke s+3, 85: poke s+5, 3 : return
1240 poke s+3, 64: poke s+5, 4 : return
1250 poke s+3, 51: poke s+5, 5 : return
1260 poke s+3, 43: poke s+5, 6 : return
1270 poke s+3, 32: poke s+5, 8 : return
1280 poke s+3, 28: poke s+5, 9 : return
1290 poke s+3, 21: poke s+5, 12 : return

1500 rem diamond
1510 poke s+14,   1: poke s+15, 0: rem angle delta
1520 poke s+18,   1: poke s+19, 0: rem radius delta
1530 sys ma
1540 poke s+14, 255: poke s+15, 0: rem angle delta
1550 poke s+18,   1: poke s+19, 0: rem radius delta
1560 sys ma
1570 poke s+14, 255: poke s+15, 0: rem angle delta
1580 poke s+18, 255: poke s+19, 0: rem radius delta
1590 sys ma
1600 poke s+14,   1: poke s+15, 0: rem angle delta
1610 poke s+18, 255: poke s+19, 0: rem radius delta
1620 sys ma
1630 return
