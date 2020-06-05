#!/usr/bin/python

from __future__ import print_function

import math

scale_x  = 127.59
scale_y  =  99.49
offset_x = -0.49
offset_y = -0.49

cos_table = []
sin_table = []


def make_tables():
    for binang in range( 0, 256 ):

        ang_rad = binang / 256.0 * 2 * math.pi

        cs = math.cos( ang_rad )
        sn = math.sin( ang_rad )

        cs_scale = cs * scale_x
        sn_scale = sn * scale_y

        cs_scale_rnd = int( round( cs_scale + offset_x, 0 ) )
        sn_scale_rnd = int( round( sn_scale + offset_y, 0 ) )

        if cs_scale_rnd >= 0:
            cs_comp =       cs_scale_rnd
        else:
            cs_comp = 256 + cs_scale_rnd

        if sn_scale_rnd >= 0:
            sn_comp =       sn_scale_rnd
        else:
            sn_comp = 256 + sn_scale_rnd

        cos_table.append( cs_comp )
        sin_table.append( sn_comp )


def print_table( table ):
    count = 0

    for val in table:
        if count == 0:
            print( '\tbyte  ', end='' )
        
        #print( cs_scale_rnd, end='' )
        print( '$' + format( val, '02x' ), end='' )
        
        count = count + 1
        if count >= 16:
            print()
            count = 0
        else:
            print( ', ', end='' )
        
        
make_tables()

print_table( cos_table )
print()
print_table( sin_table )




