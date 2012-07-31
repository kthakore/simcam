#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/imgproc/imgproc_c.h>
#include <opencv2/highgui/highgui.hpp>

#include <stdio.h>


int main( int argc, char * argv[] )
{
    const char* distortions = argc > 1 ? argv[1] : "Distortions.xml";

    const char* in_image = argc > 2 ? argv[2] : "in.png";

    const char* out_image = argc > 3 ? argv[3] : "out.png";

    const char* intrinsics = argc > 4 ? argv[4] : "Intrinsics.xml";


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
