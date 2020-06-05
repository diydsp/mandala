#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include <c64.h>
#include <_vic2.h>
#include <_sid.h>


int main ()
{
  void (*demo_main)( void );
  void (*mandala_draw)( void );
  void (*hires_clear)( void );
  void (*scrn_clr)( void );
  
  uint8_t *mandala_base = (uint8_t*)0x5900;  // mandala_base
  uint8_t *angle_bump     = mandala_base + 3;
  uint8_t *points_count   = mandala_base + 4;
  uint8_t *iters_count    = mandala_base + 6;
  uint8_t *scrn_clr_color = mandala_base + 8;
  uint8_t *scrn_clr_byte  = mandala_base + 9;
  uint8_t *plot_color     = mandala_base + 11;
  uint8_t *angle          = mandala_base + 12;
  uint8_t *angle_delta    = mandala_base + 14;
  uint8_t *radius         = mandala_base + 16;
  uint8_t *radius_delta   = mandala_base + 18;
  uint8_t *angle_ratchet  = mandala_base + 20;
  uint8_t *radius_ratchet = mandala_base + 21;
  uint8_t *angle_delta2   = mandala_base + 22;
  uint8_t *radius_delta2  = mandala_base + 23;

  demo_main    = (void*)0xc000;
  mandala_draw = (void*)0x5920;
  hires_clear  = (void*)0x5018;
  scrn_clr     = (void*)0x5020;
  
  *scrn_clr_color   = 0x10;  // upper nybble is set color, up = set
  *scrn_clr_byte    = 0x0f;  // lower nybble is color & val?
  *plot_color       = 2;
  
  *points_count     = 0;
  *(points_count+1) = 50;
  *iters_count      = 0;
  *(iters_count+1)  = 50;
  
  *angle            = 0;
  *(angle+1)        = 0;
  *radius           = 100;
  *(radius+1)       = 0;
  
  *angle_delta      = 1;
  *(angle_delta+1)  = 0;
  *radius_delta     = 1;  // per point
  *(radius_delta+1) = 1;

  *angle_ratchet    = 0;
  *radius_ratchet   = 5;  // draw the next ones wit this delta

  *angle_delta2      = 0;
  *(angle_delta2+1)  = 0;
  *radius_delta2     = 0;
  *(radius_delta2+1) = 0;
  
  *angle_bump        = 1;  // adds at end of each iteration

  (*scrn_clr)();    // text screen, uses scrn_clr_col?
  (*hires_clear)(); // hires screen, uses scrn_clr_byte?
  (*demo_main)();   // multiply init, hires_start
  

  while( 1 )
  {
    *angle = 25;
    *radius = 150;
    //*scrn_clr_color   = 5;
    //*scrn_clr_byte    = 0;
    //*scrn_clr_color++;
    //*scrn_clr_byte++;
    //*scrn_clr_byte    = 0;
    //(*hires_clear)();
    //*angle_delta++;
    (*mandala_draw)();
  }
  
  return 0;
}

void hmm( void )
{
  //uint8_t *scr   = (uint8_t*) 0x0400;  // screen
  //*(scr + 40 * 0 ) = 0;
  
  //unsigned char *chars = (uint8_t*) 0x2000;  // char memory
  uint8_t       *scr   = (uint8_t*) 0x0400;  // screen

  //COLOR_RAM[0] = 5;
  VIC.bgcolor[0] = 1;
  VIC.bgcolor[21] = 5;
  VIC.bgcolor[2] = 14;
  VIC.bgcolor[3] = 8;

  //VIC.ctrl2 |= 0x10;  // set multicolor mode
  //VIC.addr   = ( VIC.addr & 0xf0 ) | 0x08;    // set pagenum

  //*( chars + 0 ) = 0;
  
  while(1)
  {
    COLOR_RAM[ 40*0 + 0 ] = 0;
  }

}
