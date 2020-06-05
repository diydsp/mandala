
200 poke s+3, 32: poke s+5, 8 : rem angle add, num points
220 poke s+7, 1: rem num iterations

230 poke s+11, 7*16: rem plot color
240 poke s+12, 0: poke s+13, 0: rem angle 
250 poke s+16,100: poke s+17, 0: rem radius
260 poke s+14, 0: poke s+15, 0: rem angle delta
270 poke s+18, 0: poke s+19, 0: rem radius delta
280 poke s+20, 0: poke s+21, 0 : rem ratchet angle, radius
290 sys ma

295 goto 345
300 poke s+7, 3: rem num iterations
305 poke s+11, 7*16: rem plot color
310 gosub 410
315 poke s+7, 5: rem num iterations
320 poke s+11, 8*16: rem plot color
325 gosub 410
330 poke s+7, 7: rem num iterations
335 poke s+11, 9*16: rem plot color
340 gosub 410
345 poke s+7, 8: rem num iterations
350 poke s+11,10*16: rem plot color
355 gosub 410
390 end

410 for ra = 120 to 20 step -10
420 poke s+16,ra:gosub 1320:
425 pokes+18,3:sysma:next:rem offset radii

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
 