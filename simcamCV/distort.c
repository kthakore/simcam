#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/imgproc/imgproc_c.h>
#include <opencv2/highgui/highgui.hpp>

#include <stdio.h>


int main( int argc, char * argv[] )
{
	if( argc < 4 )
		fprintf( stderr, "Invalid amount of parameters");
	const char* distortions = argv[1];

	const char* in_image = argv[2];

	const char* out_image = argv[3];

	const char* intrinsics = argv[4];

	printf( std


	CvMat *intrinsic = (CvMat*)cvLoad( intrinsics);
	CvMat *distortion = (CvMat*)cvLoad( distortions );


	IplImage *image = cvLoadImage( in_image );

	cvSaveImage( out_image , image);

	IplImage* mapx = cvCreateImage( cvGetSize( image ), IPL_DEPTH_32F, 1 );
	IplImage* mapy = cvCreateImage( cvGetSize( image ), IPL_DEPTH_32F, 1 );
	cvInitUndistortMap( intrinsic, distortion, mapx, mapy );
	IplImage *t = cvCloneImage( image );
	cvRemap( t, image, mapx, mapy ); // undistort image
	cvReleaseImage( &t );

	cvSaveImage( out_image , image);

}
