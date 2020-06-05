#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include <c64.h>
#include <_vic2.h>
#include <_sid.h>
/*
#include "../cc65/include/c64.h"
#include "../cc65/include/_vic2.h"
#include "../cc65/include/_sid.h"
*/

// direction, length
int16_t patt[20] = { 0, 8, 1, 7, 2, 6, 3, 5};
int8_t patt_pos = 0;
int8_t patt_len = 8;
int8_t patt_steps_left = 3;
int8_t pos_x = 20, pos_y=12;

void worm_render( void )
{
  switch( patt[ patt_pos ] )
  {
  case 0: pos_x++; if(pos_x>39){pos_x=0;} break;
  case 1: pos_y--; if(pos_y<0){pos_y=24;} break;
  case 2: pos_x--; if(pos_x<0){pos_x=39;} break;
  case 3: pos_y++; if(pos_y>25){pos_y=0;} break;
  }
  
  patt_steps_left--;
  if( patt_steps_left < 0 )
  {
    patt_pos+=2;

    if( patt_pos >= patt_len )
    {
      patt_pos = 0;
    }

    patt_steps_left = patt[ patt_pos + 1 ];
  }  
    
}

		     
void rect1(uint8_t sx, uint8_t sy, uint8_t wid, uint8_t hei, uint8_t val,
	   uint8_t dx, uint8_t dy)
{
  uint8_t px, py;
  uint8_t *scr   = (uint8_t*) 0x0400;  // screen
  
  for( py = 0; py < hei; py++ ){
    for( px = 0; px < wid; px++ ){
      *(scr + 40 * (sy + py) + ( sx + px ) ) = val + px*dx + py*dy;
    }
  }
}

int main (int argc, char *argv[])
{
  unsigned char* chars = (uint8_t*) 0x2000;
  uint8_t *scr   = (uint8_t*) 0x0400;  // screen
  uint16_t idx;
  uint8_t incr = 0;
  uint8_t xpos=1,ypos=1;
  int8_t dx=1,dy=1;
  uint8_t charset_idx = 0;
  uint8_t tmp;
  
  printf( "val: %d", atoi( argv[ 1 ] ) );

  //COLOR_RAM[0] = 5;
  VIC.bgcolor[0] = 1;
  VIC.bgcolor[21] = 5;
  VIC.bgcolor[2] = 14;
  VIC.bgcolor[3] = 8;

  //VIC.ctrl2 |= 0x10;  // set multicolor mode
  VIC.addr   = ( VIC.addr & 0xf0 ) | 0x08;    // set pagenum

  // region 1
  //for( idx = 0; idx < 256; idx++ )  {    *( scr + idx ) = idx;  }
  for( idx = 0; idx < 256*8; idx++ )  {    *( chars + idx ) = idx & 0xff;  }
  
  while(1)
  {
    worm_render();

    rect1(pos_x,pos_y,2,2, incr, 1, 1);
    incr = ( incr + 1 ) & 0xf;
    COLOR_RAM[ 40*pos_y + pos_x ] = incr;

    // replot rectangle
    //rect1(xpos,ypos,5,5, incr, 1, 1);
    //incr++;

    // make start pos bounce
    xpos+=dx;if(xpos>34 || xpos<1){xpos-=2*dx;dx=-dx;}
    ypos+=dy;if(ypos>19 || ypos<1){ypos-=2*dy;dy=-dy;}

    // mod part of charset
    for( idx = 0; idx < 16*8; idx++ ){
      *( chars + charset_idx*8 + idx ) = (charset_idx*8 + idx + incr) & 0xff;
      //tmp = *( chars + charset_idx*8 + idx );
      //*( chars + charset_idx*8 + idx ) = tmp + 1;
    }
    //charset_idx += 16;

  }
  
  return 0;
}
