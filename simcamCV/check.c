#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/imgproc/imgproc_c.h>
#include <opencv2/highgui/highgui.hpp>

#include <stdio.h>

int main (int argc, char * argv[] )
{

	if(argc < 3)
	{
		fprintf( stderr, "Invalid number of arguments");
		return 0;
	}
	const char* loc = argv[1]; 
	const char* loc2 = argv[2];
	int n_boards = 0;
	int board_dt = 10;
	int board_w;
	int board_h;
	int corner_count = -1;


	board_w = 7; // Board width in squares
	board_h = 4; // Board height 
	int board_n = board_w * board_h;
	CvSize board_sz = cvSize( board_w, board_h );
	CvMat* image_points		= cvCreateMat( n_boards*board_n, 2, CV_32FC1 );
	CvMat* object_points		= cvCreateMat( n_boards*board_n, 3, CV_32FC1 );
	CvMat* point_counts		= cvCreateMat( n_boards, 1, CV_32SC1 );
	CvMat* intrinsic_matrix		= cvCreateMat( 3, 3, CV_32FC1 );
	CvMat* distortion_coeffs	= cvCreateMat( 5, 1, CV_32FC1 );

	CvPoint2D32f* corners = new CvPoint2D32f[ board_n ];

	IplImage *image = cvLoadImage( loc );

	IplImage *gray_image = cvCreateImage( cvGetSize( image ), 8, 1 );


	int found = cvFindChessboardCorners( image, board_sz, corners,
			&corner_count );


	// Get subpixel accuracy on those corners
	cvCvtColor( image, gray_image, CV_BGR2GRAY );
	cvFindCornerSubPix( gray_image, corners, corner_count, cvSize( 11, 11 ), 
			cvSize( -1, -1 ), cvTermCriteria( CV_TERMCRIT_EPS+CV_TERMCRIT_ITER, 30, 0.1 ));

	// Draw it
	cvDrawChessboardCorners( image, board_sz, corners, corner_count, found );
	cvSaveImage( loc2, image );

	if( found )
	{
		return 1;
	}
	return 0;

}
