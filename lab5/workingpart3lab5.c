/* This files provides address values that exist in the system */

#define SDRAM_BASE            0xC0000000
#define FPGA_ONCHIP_BASE      0xC8000000
#define FPGA_CHAR_BASE        0xC9000000

/* Cyclone V FPGA devices */
#define LEDR_BASE             0xFF200000
#define HEX3_HEX0_BASE        0xFF200020
#define HEX5_HEX4_BASE        0xFF200030
#define SW_BASE               0xFF200040
#define KEY_BASE              0xFF200050
#define TIMER_BASE            0xFF202000
#define PIXEL_BUF_CTRL_BASE   0xFF203020
#define CHAR_BUF_CTRL_BASE    0xFF203030

/* VGA colors */
#define WHITE 0xFFFF
#define YELLOW 0xFFE0
#define RED 0xF800
#define GREEN 0x07E0
#define BLUE 0x001F
#define CYAN 0x07FF
#define MAGENTA 0xF81F
#define GREY 0xC618
#define PINK 0xFC18
#define ORANGE 0xFC00

#define ABS(x) (((x) > 0) ? (x) : -(x))

/* Screen size. */
#define RESOLUTION_X 320
#define RESOLUTION_Y 240

/* Constants for animation */
#define BOX_LEN 2
#define NUM_BOXES 8

#define FALSE 0
#define TRUE 1

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
// Begin part3.c code for Lab 7


volatile int pixel_buffer_start; // global variable
void clear_screen();
void swap(int* x, int* y);
void wait_for_sync();
void draw_line(int x0, int y0, int x1, int y1, short int colour);
void plot_pixel(int x, int y, short int line_color);

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    // declare other variables(not shown)
    // initialize location and direction of rectangles(not shown)
	int N =8;
	int X_box [N], Y_box[N];
	int colour[N];
	int dx[N], dy[N];
	short int colourlist[10] = {0xF800, 0x07E0, 0x001F, 0xFFE0, 0xF81F, 0x07FF, 0x011F, 0xFF00, 0x8F00, 0xF700 };
	int i;
	for ( i=0; i<N; i++){
	dx[i] = ((rand()%2)*2)-1;
	dy[i] = ((rand()%2)*2)-1;
	X_box[i] = (rand()%319);
	Y_box[i] = (rand()%239);
	colour[i] = colourlist[rand()%10];
    }
	srand (time(0));
    /* set front pixel buffer to start of FPGA On-chip memory */
    *(pixel_ctrl_ptr + 1) = 0xC8000000; // first store the address in the 
                                        // back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_sync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer
    /* set back pixel buffer to start of SDRAM memory */
    *(pixel_ctrl_ptr + 1) = 0xC0000000;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    while (1)
    {
        /* Erase any boxes and lines that were drawn in the last iteration */
        //...maybe make a for loop and just like we draw lines and boxes we draw 
		//it but with black so they get erased..?
		clear_screen();

		 /* for( i=0; i<N-1; i++){
		plot_pixel(X_box[i], Y_box[i], 0);
		plot_pixel(X_box[i]+1, Y_box[i], colour[i]);	
		plot_pixel(X_box[i], Y_box[i]+1, colour[i]);
		plot_pixel(X_box[i]+1, Y_box[i]+1, colour[i]);
			
		//dx[i] = ((rand()%2)*2)-1;
	    //dy[i] = ((rand()%2)*2)-1;	
		//if (i<=7) 
			draw_line(X_box[i], Y_box[i], X_box[i+1], Y_box[i+1],0);
		
        }*/
		//int diff=1;

	   for( i=0; i<N; i++){
		plot_pixel(X_box[i], Y_box[i], colour[i]);
		plot_pixel(X_box[i]+1, Y_box[i], colour[i]);	
		plot_pixel(X_box[i], Y_box[i]+1, colour[i]);
		plot_pixel(X_box[i]+1, Y_box[i]+1, colour[i]);
			
		//dx[i] = ((rand()%2)*2)-1;
	    //dy[i] = ((rand()%2)*2)-1;
}	
		

            for (i=0; i<N-1; i++){
				
			draw_line(X_box[i], Y_box[i], X_box[i+1], Y_box[i+1],colour[i]);
			
			if(X_box[i]==0)
				dx[i]=1;
			if(X_box[i]==319)
				dx[i]=-1;
			if(Y_box[i]==0)
				dy[i]=1;
			if(Y_box[i]==239)
				dy[i]=-1;
			
			Y_box[i]= Y_box[i]+dy[i];
			X_box[i]= X_box[i]+dx[i];
        	}
		
		//speghetti code for box 7 
			draw_line(X_box[0], Y_box[0], X_box[7], Y_box[7],colour[7]);
		
			if(X_box[7]==0)
				dx[7]=1;
			if(X_box[7]==319)
				dx[7]=-1;
			if(Y_box[7]==0)
				dy[7]=1;
			if(Y_box[7]==239)
				dy[7]=-1;
			
			Y_box[7]= Y_box[7]+dy[7];
			X_box[7]= X_box[7]+dx[7];
        // code for drawing the boxes and lines (not shown)
        // code for updating the locations of boxes (not shown)

        wait_for_sync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}

// code for subroutines (not shown)

void swap(int* x, int* y)
{
    int temp = *x;
	*x=*y;
	*y=temp;
}


void wait_for_sync()
{
	volatile int* pixel_ctrl_ptr = (int *)0xff203020;
	volatile int*status = (int *)0xff20302c;
	*pixel_ctrl_ptr = 1;
	
	while(*status & 0b1)
	{
		status = status;
	}
	
	return ;
}


void draw_line(int x0, int y0, int x1, int y1, short int colour)
{
  bool is_steep = abs(y1 - y0) > abs(x1 - x0);
	

  if (is_steep) 
  {
   swap(&x0, &y0);
   swap(&x1, &y1);
  }
 if (x0 > x1) {
 swap(&x0, &x1);
 swap(&y0, &y1);
}
 int deltax = x1 - x0;
 int deltay = abs(y1 - y0);
 int error = -(deltax / 2);
 int y = y0;
	int y_step=-1;
 if (y0 < y1)
	 y_step = 1; 

int x;
    for ( x = x0; x <= x1; ++x)
    {
        if (is_steep)
        {
            plot_pixel(y, x, colour);
        }
        else
        {
            plot_pixel(x, y, colour);
        }
       error = error + deltay;
      if (error > 0) {
      y = y + y_step;
      error = error - deltax	;
	  }
   }
}

void clear_screen()
{
        int y, x;

        for (x = 0; x < 320; x++)
                for (y = 0; y < 240; y++)
                        plot_pixel (x, y, 0);
}

void plot_pixel(int x, int y, short int line_color)
{
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}