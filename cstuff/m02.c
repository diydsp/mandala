#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include <c64.h>
#include <_vic2.h>
#include <_sid.h>

#pragma optimize(off)

// global variable and functions
void (*demo_main)( void );
void (*mandala_draw)( void );
void (*hires_clear)( void );
void (*scrn_clr)( void );
void (*hplot_set_mode)( void );
void (*hplot_unset_mode)( void );
  
uint8_t *mandala_base = (uint8_t*)0xb900;  // mandala_base
uint8_t *angle_bump     ;
uint8_t *points_count   ;
uint8_t *iters_count    ;
uint8_t *scrn_clr_color ;
uint8_t *scrn_clr_byte  ;
uint8_t *plot_color     ;
uint8_t *angle          ;
uint8_t *angle_delta    ;
uint8_t *radius         ;
uint8_t *radius_delta   ;
uint8_t *angle_ratchet  ;
uint8_t *radius_ratchet ;
uint8_t *angle_delta2   ;
uint8_t *radius_delta2  ;

uint8_t *border_col     = (uint8_t *)0xd020;

void funcs_init( void )
{
  demo_main        = (void*)0xc000;
  mandala_draw     = (void*)0xb920;
  hires_clear      = (void*)0xb018;
  scrn_clr         = (void*)0xb020;
  hplot_set_mode   = (void*)0xb028;
  hplot_unset_mode = (void*)0xb030;

  mandala_base = (uint8_t*)0xb900;  // mandala_base
  angle_bump     = mandala_base + 3;
  points_count   = mandala_base + 4;
  iters_count    = mandala_base + 6;
  scrn_clr_color = mandala_base + 8;
  scrn_clr_byte  = mandala_base + 9;
  plot_color     = mandala_base + 11;
  angle          = mandala_base + 12;
  angle_delta    = mandala_base + 14;
  radius         = mandala_base + 16;
  radius_delta   = mandala_base + 18;
  angle_ratchet  = mandala_base + 20;
  radius_ratchet = mandala_base + 21;
  angle_delta2   = mandala_base + 22;
  radius_delta2  = mandala_base + 23;  
}

void basic_config( void )
{
  *border_col       = 0x00;
  *scrn_clr_byte    = 0x00;  // used in hires_clear
  *scrn_clr_color   = 0x00;  // used in color_map clear
  *plot_color       = 0x10;  // high nybble is set col, low nybble clear
  
  *points_count     = 0;
  *(points_count+1) = 8;
  *iters_count      = 0;
  *(iters_count+1)  = 10;
  
  *angle            = 45;
  *(angle+1)        = 0;
  *radius           = 50;
  *(radius+1)       = 0;
  
  *angle_delta      = 1;
  *(angle_delta+1)  = 0;
  *radius_delta     = 1;  // per point
  *(radius_delta+1) = 0;

  *angle_ratchet    = 5;
  *radius_ratchet   = 10;  // draw the next ones wit this delta

  *angle_delta2      = 0;
  *(angle_delta2+1)  = 0;
  *radius_delta2     = 0;
  *(radius_delta2+1) = 0;
  
  *angle_bump        = 5;  // adds at end of each iteration
}

void simple_spiral( void )
{
  uint8_t m1,m2;
  uint8_t temp;

  for(m1 = 0;m1<10;m1++){
    for(m2=0;m2<10;m2++){
      *points_count     = 0;
      *(points_count+1) = 8;
      *iters_count      = 0;
      *(iters_count+1)  = 20;
      
      *angle_delta = 32;
      *radius_delta = m2;
      (*hplot_set_mode)();
      *angle =0;
      *radius=50;
      //(*mandala_draw)();
      mandala_draw();

      (*hplot_unset_mode)();
      *angle =0;
      *radius=50;
      mandala_draw();
      //(*mandala_draw)();
      //(*hires_clear)();
    }
    *plot_color += 0x10;
  }
      
  //*angle=0;
  //*radius = 150;
  //*scrn_clr_color++;
  //*scrn_clr_byte    = 0;
  //*scrn_clr_color++;
  //*scrn_clr_byte++;
  //*scrn_clr_byte    = 0;
  //*angle_delta++;
}

int main ()
{
  
  __asm__  ("sei");
   
  funcs_init();

  basic_config();  // starting config

  scrn_clr();    // text screen, uses scrn_clr_color
  hires_clear(); // hires screen, uses scrn_clr_byte
  demo_main();   // multiply init, hires_start

  while( 1 ) {
    simple_spiral();
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
