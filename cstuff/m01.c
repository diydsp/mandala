#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include <c64.h>
#include <_vic2.h>
#include <_sid.h>

void hmm( void )
{
  uint8_t *scr   = (uint8_t*) 0x0400;  // screen
  *(scr + 40 * 0 ) = 0;
}

int main (int argc, char *argv[])
{
  unsigned char *chars = (uint8_t*) 0x2000;  // char memory
  uint8_t       *scr   = (uint8_t*) 0x0400;  // screen

  //COLOR_RAM[0] = 5;
  VIC.bgcolor[0] = 1;
  VIC.bgcolor[21] = 5;
  VIC.bgcolor[2] = 14;
  VIC.bgcolor[3] = 8;

  //VIC.ctrl2 |= 0x10;  // set multicolor mode
  //VIC.addr   = ( VIC.addr & 0xf0 ) | 0x08;    // set pagenum

  *( chars + 0 ) = 0;
  
  while(1)
  {
    COLOR_RAM[ 40*0 + 0 ] = 0;
  }
  
  return 0;
}
