#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include <c64.h>
#include <_vic2.h>
#include <_sid.h>

//#pragma optimize(off)

// external variable and functions
void (*demo_main)( void );
void (*song_irq_start)( void );

void (*mandala_draw)( void );
void (*hires_clear)( void );
void (*scrn_clr)( void );
void (*hplot_set_mode)( void );
void (*hplot_unset_mode)( void );

// internal
void (*shape_func)(void);

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
  
  *angle            = 45; // current angle
  *(angle+1)        = 0;
  *radius           = 50;
  *(radius+1)       = 0;
  
  *angle_delta      = 1;
  *(angle_delta+1)  = 0;
  *radius_delta     = 1;  // per point
  *(radius_delta+1) = 0;

  *angle_ratchet    = 5;  // applied after all iterations
  *radius_ratchet   = 10; 

  *angle_delta2      = 0;  // not immediately used
  *(angle_delta2+1)  = 0;
  *radius_delta2     = 0;
  *(radius_delta2+1) = 0;
  
  *angle_bump        = 5;  // every every pixel, used to make equilaterals
}


uint8_t incr_sub_pal(void )
{
  uint8_t ret_val =0;
  // incr sub palette
  if( pal_sub_step++ >= pal_sub_len ){
    pal_sub_step = 0;
    ret_val = 1;
    *plot_color = pal_02[ pal_step ] << 4;
    pal_step++;
    if( pal_step >= pal_len ){pal_step = 0;}
  }
  return ret_val;
}
// end of helper funcs

// start of demo effeocts
void clear_black( uint8_t loops_max )
{
  uint8_t loops;
 
  // init gfx conditions
  *scrn_clr_color = 0xb0;  // dk gray on blk
  //*scrn_clr_color = 0x5b;  // gren fg, dk grey bg
  *scrn_clr_byte  = 0x01;     // slight blip

  // loops
  for(loops=0;loops<loops_max;loops++){
    hires_clear();
    scrn_clr();
  }
}

void simple_sweep( uint8_t loops_max )
{
  uint8_t loops;

  // init gfx conditions
  *scrn_clr_color = 0x20;  // gren fg, dk grey bg
  *scrn_clr_byte  = 0;     // slight blip for visibility
  hires_clear();
  scrn_clr();
  
  // config
  hplot_set_mode();
  *(angle)          = 128;
  *(radius)         = 10;
  *(points_count+1) = 1;  *angle_bump = 0;  // single point
  *angle_delta = 0; *radius_delta = 1;   // after all points
  *(iters_count+1)  = 100;
  *angle_ratchet    =  0; *radius_ratchet = -100; // called after all iters
  *plot_color = 0x20;

  // loop
  for(loops=0;loops<loops_max;loops++){
    //if( (loops&0x30) == 0x30){ hires_clear(); }
    mandala_draw();
    *(angle) += 2;
    if( (*angle) < 2 ){ *(angle) = 128; }
  }
}

void stars( uint8_t loops_max )
{
  uint8_t m2;
  uint8_t loop;
  uint8_t ang_start;
  uint8_t rad_start;
  
  // init gfx conditions
  *scrn_clr_color = 0x20;  // gren fg, dk grey bg
  *scrn_clr_byte  = 0;     // slight blip for visibility
  hires_clear();
  scrn_clr();
  pal_sub_step = 0; pal_sub_len = 1;
  pal_step     = 0; pal_len     = 25;
  *plot_color = pal_02[ pal_step ] << 4;
  
  // config mandala
  *(points_count+1) = 8;  *angle_bump = 32;  // octagon
  *(iters_count+1)  = 20;
  *angle_ratchet    =  0; *radius_ratchet =  0; // called after all iters
  ang_start = 0;
  rad_start = 50;
  
  // loop
  for(loop=0;loop<loops_max;loop++)
  {
    for(m2=0;m2<10;m2++){
      
      *radius_delta = m2;

      hplot_set_mode();
      *angle  = ang_start;
      *radius = rad_start;
      mandala_draw();
    
      hplot_unset_mode();
      *angle  = ang_start;
      *radius = rad_start;
      //mandala_draw();

      incr_sub_pal();
    }
  }
      
}


void polar_triangle( void )
{
  // polar triangle
  *angle_delta  = 1;        *radius_delta = 1;
  mandala_draw();
  *angle_delta  = -2;       *radius_delta = 0;
  mandala_draw();
  *angle_delta  = 1;        *radius_delta = 0xff;
  mandala_draw();
}


void polar_square( void )
{
  // polar triangle
  *angle_delta  = 1;        *radius_delta = 0;
  mandala_draw();
  *angle_delta  = 0;        *radius_delta = 1;
  mandala_draw();
  *angle_delta  = -1;       *radius_delta = 0;
  mandala_draw();
  *angle_delta  = 0;        *radius_delta = -1;
  mandala_draw();
}

void polar_diamond( void )
{
  *angle_delta  = 1;        *radius_delta = 1;
  mandala_draw();
  *angle_delta  = -1;        *radius_delta = 1;
  mandala_draw();
  *angle_delta  = -1;       *radius_delta = -1;
  mandala_draw();
  *angle_delta  = 1;        *radius_delta = -1;
  mandala_draw();
}

void polar_hexagon( void )
{
  *angle_delta  = 1;        *radius_delta = 0;
  mandala_draw();
  *angle_delta  = 1;        *radius_delta = 1;
  mandala_draw();
  *angle_delta  = -1;       *radius_delta = 1;
  mandala_draw();
  *angle_delta  = -1;        *radius_delta = 0;
  mandala_draw();
  *angle_delta  = -1;       *radius_delta = -1;
  mandala_draw();
  *angle_delta  = 1;        *radius_delta = -1;
  mandala_draw();
}


// begin mandala1
void mandala1( uint8_t loops_max, uint8_t mode, uint8_t rad_start, uint8_t ang_start, uint8_t iters, uint8_t plot_col )
{
  uint8_t loop;
  
  // config
  *(iters_count+1)  = iters;
  *plot_color = plot_col;

  switch(mode)
  {
  case 1:  // leave trails
  hires_clear();
  for( loop=0;loop < loops_max; loop++ ){
    
    hplot_set_mode();
    *angle = ang_start;       *radius = rad_start;
    shape_func();
    //polar_triangle();
    
    // modulation
    ang_start += 5;
  }
  break;
  
  case 2:  // clear trails
  hplot_unset_mode();
  *plot_color = 0x70;  // yellow
  for( loop=0;loop < loops_max; loop++ ){
    
    hplot_set_mode();
    *angle = ang_start;       *radius = rad_start;
    shape_func();
    //polar_triangle();

    hplot_unset_mode();
    *angle = ang_start;       *radius = rad_start;
    shape_func();
    //polar_triangle();

    // modulation
    ang_start += 5;
  }
  break;
  
  }
  
}
//end mandala1

void bg_sweep( void )
{
  uint8_t loops;
  uint8_t temp;
  
  *scrn_clr_byte    = 0x01;  // used in hires_clear
  
  for( loops=0;loops<50;loops++)
  {
    temp = *scrn_clr_byte;
    if( temp == 0x80 ){ *scrn_clr_byte = 0x01;}
    else { *scrn_clr_byte = temp << 1; }
    hires_clear();
  }
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


  *angle_delta  = 0;  *radius_delta = 2;   
  *(points_count+1) = 10;  *angle_bump = 26;  // 10-side
  start_angle = 0;
  *(iters_count+1)  = 5;
  for(m2=20;m2<55;m2+=5){
    for(m1 = 0;m1<10;m1+=1){
      *angle = start_angle + m1;
      *radius = m2;
      mandala_draw();
    }
    incr_sub_pal();
    start_angle-=9;
  }

  *angle_delta  = 0;  *radius_delta = 2;  
  *(points_count+1) = 6;  *angle_bump = 43;  // 6-side
  start_angle = 0;
  *(iters_count+1)  = 3;
  for(m2=60;m2<75;m2+=5){
    for(m1 = 0;m1<10;m1+=1){
      *angle = start_angle + m1;
      *radius = m2;
      mandala_draw();
    }
    incr_sub_pal();
    start_angle-=4;
  }

  hplot_set_mode();
  *angle_delta  = 0; *radius_delta = 1;  
  *(points_count+1) = 5;  *angle_bump = 51;  // 5-side
  start_angle = 0;
  *(iters_count+1)  = 6;
  for(m2=80;m2<95;m2+=10){
    for(m1 = 0;m1<10;m1+=1){
      *angle = start_angle + m1;
      *radius = m2;
      mandala_draw();
    }
    incr_sub_pal();
    start_angle+=4;
  }


  *angle_delta  = 0;  *radius_delta = 2;  
  *(points_count+1) = 6;  *angle_bump = 43;  //  6-side
  start_angle = 0;
  *(iters_count+1)  = 3;
  for(m2=100;m2<127;m2+=5){
    for(m1 = 0;m1<10;m1+=2){
      *angle = start_angle + m1;
      *radius = m2;
      mandala_draw();
    }
    incr_sub_pal();
    start_angle-=9;
  }
  
}


void spiral2( uint8_t loops_max )
{
  uint8_t loops;
  uint8_t start_angle = 0;
  
  hplot_set_mode(); // foreground
  *(points_count+1) =  6; *(angle_bump)   = 42;    // hex pattern
  *angle_delta      =  3; *radius_delta   =  -1; // called after all points
  *angle_ratchet    =  1; *radius_ratchet =  80; // called after all iters
  *(iters_count+1)  = 80;
  *(radius) = 127;
  pal_sub_len=10;
  
  for(loops=0;loops< loops_max;loops++)
  {
    hplot_set_mode(); // foreground
    *(angle)=start_angle;
    *angle_delta      =  1; *radius_delta   =  -1; // called after all points
    mandala_draw();

    // make symmetrical copy
    *(angle)=start_angle;
    *angle_delta      =  -1; *radius_delta   =  -1; // called after all points
    mandala_draw();

    hplot_unset_mode(); // background    
    *(angle)=start_angle;
    *angle_delta      =  1; *radius_delta   =  -1; // called after all points
    mandala_draw();

    // make symmetrical copy
    *(angle)=start_angle;
    *angle_delta      =  -1; *radius_delta   =  -1; // called after all points
    mandala_draw();

    
    start_angle+=1;

    //spiral2();
    if( incr_sub_pal() ){ hires_clear();  }
    //incr_sub_pal();
    //hires_clear();
  }
      
}



int main ()
{
  uint8_t count;
  char SPT[]="Black Lives Matter!!!";
  uint8_t loops;
  uint8_t index;
  
  // bg, fg, cursor colors
  *(uint8_t *)0xd020=0;
  *(uint8_t *)0xd021=0;
  *(uint8_t *)646=1;    // white cursors

  // string effect
  //for( count = 0; count < 39; count++ ){ out_str[count]=' ';}
  //out_str[39] = '\r';
  for( count = 0; count < 20; count++ ){
    //index = *(uint8_t*)0xd012;
    //index &= 0x3f;
    //while(index>39){index-=39;}
    //out_str[ index ] = SPT[index];
    //printf( "%s\n", out_str );
    printf( "%c",147);
    printf( "%s\n", SPT );
  }

  funcs_init();

  demo_main();   // multiply init, hires_start
  

  basic_config();  // starting pattern config

  scrn_clr();    // text screen, uses scrn_clr_color
  hires_clear(); // hires screen, uses scrn_clr_byte

  song_irq_start();

  // palette config
  pal_step=0;
  pal_len=32;
  pal_sub_step=0;
  pal_sub_len=3;
  
  
  while( 1 ) {

    //clear_black(70);

    //simple_sweep( 64 );

    //stars( 5 );

    // geometry
    // init gfx conditions
    hplot_set_mode();
    *scrn_clr_color = 0x20;  // gren fg, dk grey bg
    *scrn_clr_byte  = 0;     // slight blip for visibility
    scrn_clr();
    pal_sub_step = 0; pal_sub_len = 1;
    pal_step     = 2; pal_len     = 25;
    //*plot_color = pal_02[ pal_step ] << 4;
    *(points_count+1) = 3;  *angle_bump = 85;  // triangle
    *angle_ratchet    =  0; *radius_ratchet = 0; // called after all iters
    shape_func = (void*)polar_triangle;
    shape_func = (void*)polar_square;
    //shape_func = (void*)polar_diamond;
    shape_func = (void*)polar_hexagon;


    // loops, mode, rad_st, ang_st, iters, plot_color
    mandala1( 30, 1, 50, 0, 20, 0x10 );
    mandala1( 30, 2, 80, 0, 20, 0x20 );
    mandala1( 30, 2, 20, 0, 20, 0x30 );

    //mandala1( 10, 1, 50, 0, 20, 0x5 );  
    
  }

  if( 0 ){
    bg_sweep();
    
    spiral2( 4 );

    for(loops=0;loops<50;loops++)
    {
      *radius = 100;    circle();
      *radius = 80;    circle();
      *radius = 60;    circle();
      *radius = 40;    circle();
      *angle = *angle+32;
      incr_sub_pal();
      //if( incr_sub_pal() ){ hires_clear();  }
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

    
  }
  
  return 0;
}

