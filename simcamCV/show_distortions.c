#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/imgproc/imgproc_c.h>
#include <opencv2/highgui/highgui.hpp>

#include <stdio.h>


int main(int argc, char * argv[])
{

    const char* loc = "undistort.jpg";


    IplImage*	image = cvLoadImage(loc);//cvQueryFrame( capture );

	cvNamedWindow( "Calibration" );
	// Allocate Sotrage
	CvMat* intrinsic_matrix		= cvCreateMat( 3, 3, CV_32FC1 );
	CvMat* distortion_coeffs	= cvCreateMat( 5, 1, CV_32FC1 );

	// Example of loading these matrices back in
	CvMat *intrinsic = (CvMat*)cvLoad( "Intrinsics.xml" );
	CvMat *distortion = (CvMat*)cvLoad( "Distortion.xml" );

	// Build the undistort map that we will use for all subsequent frames
	IplImage* mapx = cvCreateImage( cvGetSize( image ), IPL_DEPTH_32F, 1 );
	IplImage* mapy = cvCreateImage( cvGetSize( image ), IPL_DEPTH_32F, 1 );
	cvInitUndistortMap( intrinsic, distortion, mapx, mapy );

	// Run the camera to the screen, now showing the raw and undistorted image
	cvNamedWindow( "Undistort" );
		IplImage *t = cvCloneImage( image );
		cvShowImage( "Calibration", image ); // Show raw image
		cvRemap( t, image, mapx, mapy ); // undistort image
		cvReleaseImage( &t );
		cvShowImage( "Undistort", image ); // Show corrected image

        cvSaveImage( "distorted.jpg", image);



	return 0;
}
