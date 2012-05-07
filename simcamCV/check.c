#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/imgproc/imgproc_c.h>
#include <opencv2/highgui/highgui.hpp>

#include <stdio.h>

int main (int argc, char * argv[] )
{
    printf( "Args: %d\n", argc);

    if(argc < 2)
        return 0;
   
    const char* loc = argv[1]; 

    printf( "Processing: %s\n", loc );
    int n_boards = 0;
    const int board_dt = 20;
    int board_w;
    int board_h;


    board_w = 8; // Board width in squares
	board_h = 5; // Board height 
	int board_n = board_w * board_h;
	CvSize board_sz = cvSize( board_w, board_h );



}
