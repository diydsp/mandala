#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include <c64.h>
#include <_vic2.h>
#include <_sid.h>

//#pragma optimize(off)

// global variable and functions
void (*demo_main)( void );
void (*song_irq_start)( void );

void (*mandala_draw)( void );
void (*hires_clear)( void );
void (*scrn_clr)( void );
void (*hplot_set_mode)( void );
void (*hplot_unset_mode)( void );
  
uint8_t *mandala_base = (uint8_t*)0x9900;  // mandala_base
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

uint8_t pal_01[] = {0,0,6,9,0xb,2,4,8,0xe,0xa,5,3,0xf,7,1,1, //16step,b->w->b
                    1,1,7,0xf,3,5,0xa,0xe,8,4,2,0xb,9,6,0,0 }; 
uint8_t pal_02[] = {2,9,0xa,         // red, pink   // 25-step, rainbow
		    7,7,7,      // yel
		    5,5,5,5,   // grn
		    3,3,3,3,   // cyan
		    0xe,6,6,6,0xe,  // blue
		    4,4,4,4,  // purp
		    0xa,2};   // red, pink    
uint8_t pal_step, pal_len;
uint8_t pal_sub_step, pal_sub_len;

void funcs_init( void )
{
  demo_main        = (void*)0xc000;
  song_irq_start   = (void*)0xc100;
  mandala_draw     = (void*)0x9920;
  hires_clear      = (void*)0x9018;
  scrn_clr         = (void*)0x9020;
  hplot_set_mode   = (void*)0x9028;
  hplot_unset_mode = (void*)0x9030;

  mandala_base = (uint8_t*)0x9900;  // mandala_base
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


void hexa1( void )
{
  *radius_delta = 1;
  *angle_delta  = 0;
  *angle_bump = 42;
  *(points_count+1) = 6;
  *(iters_count+1)  =24;
  
  mandala_draw();
}

void circle( void )
{
  *radius_delta = 1;
  *angle_delta  = 0;
  *angle_bump = 1;
  *(points_count+1) = 40;
  *(iters_count+1)  = 3;
  
  mandala_draw();

  
}
	    

void penta1( void )
{
  uint8_t m1,m2;
  uint8_t start_angle;

  *radius_delta = 2;
  *angle_delta  = 0;
  *angle_bump = 26;
  start_angle = 0;
  *(points_count+1) = 10;
  *(iters_count+1)  = 5;
  for(m2=20;m2<60;m2+=5){
    for(m1 = 0;m1<10;m1+=1){
      *angle = start_angle + m1;
      *radius = m2;
      mandala_draw();
    }
    *plot_color += 0x10;
    start_angle-=9;
  }

  *radius_delta = 2;
  *angle_delta  = 0;
  *angle_bump = 43;
  start_angle = 0;
  *(points_count+1) = 6;
  *(iters_count+1)  = 3;
  for(m2=60;m2<80;m2+=5){
    for(m1 = 0;m1<10;m1+=1){
      *angle = start_angle + m1;
      *radius = m2;
      mandala_draw();
    }
    *plot_color += 0x10;
    start_angle-=4;
  }

  hplot_set_mode();
  *radius_delta = 1;
  *angle_delta  = 0;
  *angle_bump = 51;
  *radius=50;
  start_angle = 0;
  *(points_count+1) = 5;
  *(iters_count+1)  = 6;

  for(m2=80;m2<110;m2+=10){
    for(m1 = 0;m1<10;m1+=1){
      *angle = start_angle + m1;
      *radius = m2;
      mandala_draw();
    }
    *plot_color += 0x10;
    start_angle+=4;
  }


  *radius_delta = 2;
  *angle_delta  = 0;
  *angle_bump = 32;
  start_angle = 0;
  *(points_count+1) = 6;
  *(iters_count+1)  = 3;
  for(m2=100;m2<127;m2+=5){
    for(m1 = 0;m1<10;m1+=2){
      *angle = start_angle + m1;
      *radius = m2;
      mandala_draw();
    }
    *plot_color += 0x10;
    start_angle-=9;
  }
  
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
      hplot_set_mode();
      *angle =0;
      *radius=50;
      mandala_draw();

      hplot_unset_mode();
      *angle =0;
      *radius=50;
      mandala_draw();
    }
    hires_clear();
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


uint8_t incr_sub_pal(void )
{
  uint8_t ret_val =0;
  // incr sub palette
  if( pal_sub_step++ >= pal_sub_len ){
    pal_sub_step = 0;
    ret_val = 1;
    *plot_color = pal_01[ pal_step ] << 4;
    pal_step++;
    if( pal_step >= pal_len ){pal_step = 0;}
  }
  return ret_val;
}

int main ()
{
  uint8_t count;
  char out_str[39];
  const char SPT[40]="Music: Shortcut by Stephen paul taylor\n";
  uint8_t loops;
  uint8_t index;
  
  // bg, fg, cursor colors
  *(uint8_t *)0xd020=0;
  *(uint8_t *)0xd021=0;
  *(uint8_t *)646=1;    // white cursors

  // string effect
  for( count = 0; count < 39; count++ ){ out_str[count]=' ';}
  out_str[39] = '\n';
  for( count = 0; count < 69; count++ ){
    index = *(uint8_t*)0xd012;
    index &= 0x3f;
    while(index>39){index-=39;}
    out_str[ index ] = SPT[index];
    printf( "%s\n", out_str );
  }

  funcs_init();

  demo_main();   // multiply init, hires_start
  

  basic_config();  // starting pattern config

  scrn_clr();    // text screen, uses scrn_clr_color
  hires_clear(); // hires screen, uses scrn_clr_byte

  song_irq_start();

  pal_step=0;
  pal_len=32;
  pal_sub_step=0;
  pal_sub_len=3;
  
  
  while( 1 ) {

    for(loops=0;loops<50;loops++)
    {
      *radius = 100;    circle();
      *radius = 80;    circle();
      *radius = 60;    circle();
      *radius = 40;    circle();
      *angle = *angle+32;
      if( incr_sub_pal() ){ hires_clear();  }
    }
    
    for(loops=0;loops<100;loops++)
    {
      hexa1();
      *angle = *angle+4;
      *radius-=8;
      if( incr_sub_pal() ){ hires_clear();  }
    }
    hires_clear();

    for(loops=0;loops<1;loops++)
    {
      penta1();
      if( incr_sub_pal() ){ hires_clear();  }      
    }
    hires_clear();

    for(loops=0;loops<1;loops++)
    {
      simple_spiral();
      if( incr_sub_pal() ){ hires_clear();  }
    }
    hires_clear();
    
  }
  
  return 0;
}

