#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/imgproc/imgproc_c.h>
#include <opencv2/highgui/highgui.hpp>

#include <stdio.h>


int n_boards = 0;
const int board_dt = 10;
int board_w;
int board_h;

int main(int argc, char * argv[])
{
	int corner_count;
	int successes = 0;
	int step, frame = 0;

	const char* intrinsics_path = argv[1];
	const char* distortions_path = argv[2];
	int total = argc - 3 ; 
	int start = 3;

	const char* loc = argv[start] ;

	board_w = 7; // Board width in squares
	board_h = 4; // Board height 
	n_boards = total; // Number of boards
	int board_n = board_w * board_h;
	CvSize board_sz = cvSize( board_w, board_h );
	// Allocate Sotrage
	CvMat* image_points		= cvCreateMat( n_boards*board_n, 2, CV_32FC1 );
	CvMat* object_points		= cvCreateMat( n_boards*board_n, 3, CV_32FC1 );
	CvMat* point_counts		= cvCreateMat( n_boards, 1, CV_32SC1 );
	CvMat* intrinsic_matrix		= cvCreateMat( 3, 3, CV_32FC1 );
	CvMat* distortion_coeffs	= cvCreateMat( 5, 1, CV_32FC1 );

	CvPoint2D32f* corners = new CvPoint2D32f[ board_n ];

	IplImage *image = cvLoadImage( loc );
	//IplImage *image = cvQueryFrame(capture);

	IplImage *gray_image = cvCreateImage( cvGetSize( image ), 8, 1 );

	// Capture Corner views loop until we've got n_boards
	// succesful captures (all corners on the board are found)

	while( start < total ){
		// Skp every board_dt frames to allow user to move chessboard
		//		if( frame++ % board_dt == 0 ){
		// Find chessboard corners:
		int found = cvFindChessboardCorners( image, board_sz, corners,
				&corner_count, CV_CALIB_CB_ADAPTIVE_THRESH | CV_CALIB_CB_FILTER_QUADS );


		// Get subpixel accuracy on those corners
		cvCvtColor( image, gray_image, CV_BGR2GRAY );
		cvFindCornerSubPix( gray_image, corners, corner_count, cvSize( 11, 11 ), 
				cvSize( -1, -1 ), cvTermCriteria( CV_TERMCRIT_EPS+CV_TERMCRIT_ITER, 30, 0.1 ));

		// Draw it
		cvDrawChessboardCorners( image, board_sz, corners, corner_count, found );
		if( found )
		{            
			cvSaveImage( "/tmp/grid_save.png", image);  
		}

		// If we got a good board, add it to our data
		if( corner_count == board_n ){
			step = successes*board_n;
			for( int i=step, j=0; j < board_n; ++i, ++j ){
				CV_MAT_ELEM( *image_points, float, i, 0 ) = corners[j].x;
				CV_MAT_ELEM( *image_points, float, i, 1 ) = corners[j].y;
				CV_MAT_ELEM( *object_points, float, i, 0 ) = j/board_w;
				CV_MAT_ELEM( *object_points, float, i, 1 ) = j%board_w;
				CV_MAT_ELEM( *object_points, float, i, 2 ) = 0.0f;
			}
			CV_MAT_ELEM( *point_counts, int, successes, 0 ) = board_n;
			successes++;
		}
		//		} 


		if( start < total )
		{
			start++; 
		}
		else if ( start == total )
		{
			start = 1;
			//  return -1;
		}

		loc = argv[start] ;

		image = cvLoadImage( loc );
	} // End collection while loop

	// Allocate matrices according to how many chessboards found
	CvMat* object_points2 = cvCreateMat( successes*board_n, 3, CV_32FC1 );
	CvMat* image_points2 = cvCreateMat( successes*board_n, 2, CV_32FC1 );
	CvMat* point_counts2 = cvCreateMat( successes, 1, CV_32SC1 );

	// Transfer the points into the correct size matrices
	for( int i = 0; i < successes*board_n; ++i ){
		CV_MAT_ELEM( *image_points2, float, i, 0) = CV_MAT_ELEM( *image_points, float, i, 0 );
		CV_MAT_ELEM( *image_points2, float, i, 1) = CV_MAT_ELEM( *image_points, float, i, 1 );
		CV_MAT_ELEM( *object_points2, float, i, 0) = CV_MAT_ELEM( *object_points, float, i, 0 );
		CV_MAT_ELEM( *object_points2, float, i, 1) = CV_MAT_ELEM( *object_points, float, i, 1 );
		CV_MAT_ELEM( *object_points2, float, i, 2) = CV_MAT_ELEM( *object_points, float, i, 2 );
	}

	for( int i=0; i < successes; ++i ){
		CV_MAT_ELEM( *point_counts2, int, i, 0 ) = CV_MAT_ELEM( *point_counts, int, i, 0 );
	}
	cvReleaseMat( &object_points );
	cvReleaseMat( &image_points );
	cvReleaseMat( &point_counts );

	// At this point we have all the chessboard corners we need
	// Initiliazie the intrinsic matrix such that the two focal lengths
	// have a ratio of 1.0

	CV_MAT_ELEM( *intrinsic_matrix, float, 0, 0 ) = 1.0;
	CV_MAT_ELEM( *intrinsic_matrix, float, 1, 1 ) = 1.0;

	// Calibrate the camera
	cvCalibrateCamera2( object_points2, image_points2, point_counts2, cvGetSize( image ), 
			intrinsic_matrix, distortion_coeffs, NULL, NULL, CV_CALIB_FIX_ASPECT_RATIO ); 

	// Save the intrinsics and distortions
	cvSave( intrinsics_path, intrinsic_matrix );
	cvSave( distortions_path, distortion_coeffs );


	return 1;
}
