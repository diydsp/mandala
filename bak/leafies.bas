
200 poke s+3, 51: poke s+5, 5 : rem angle add, num points
220 poke s+7, 4: rem num iterations

230 poke s+11, 7*16: rem plot color
240 poke s+12,  0: poke s+13, 0: rem angle 
250 poke s+16,110: poke s+17, 0: rem radius
260 poke s+14,  0: poke s+15, 0: rem angle delta
270 poke s+18,  0: poke s+19, 0: rem radius delta
280 poke s+20,  0: poke s+21, 0 : rem ratchet angle, radius
290 poke s+22,  0: poke s+23, 0 : rem radius delta2
300 poke s+24,  8: poke s+25, 0 : rem angle delta2
310 co = 1

390 for ra = 120 to 30 step -10
400 poke s+16, ra
410 for x = 1 to 5
420 gosub 1320
425 poke s+24,  8: poke s+25, 0 : rem angle delta2
430 sys 22992: rem increment angle and delta
440 co = co + 1: poke s+11,16*(co and 15): rem color
450 next
460 poke s+24, 256-8*4: poke s+25, 0 : rem angle delta2
470 sys 22992
475 co = co - 3
480 next
490 end

1320 poke s+14,   0: poke s+15,  0: rem angle delta
1330 poke s+18,   1: poke s+19,  0: rem radius delta
1340 sys ma
1350 poke s+14,   1: poke s+15,  0: rem angle delta
1360 poke s+18,   0: poke s+19,  0: rem radius delta
1370 sys ma
1380 poke s+14,   0: poke s+15,  0: rem angle delta
1390 poke s+18, 255: poke s+19,  0: rem radius delta
1400 sys ma
1410 poke s+14, 255: poke s+15,  0: rem angle delta
1420 poke s+18,   0: poke s+19,  0: rem radius delta
1430 sys ma
1440 return
