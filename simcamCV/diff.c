#include <opencv2/imgproc/imgproc_c.h>
#include <opencv2/highgui/highgui.hpp>

int main ( int argc, char **argv )
{
  // use first camera attached to computer

  // image data structures
  IplImage *img1;   
  IplImage *img2;
  IplImage *imggray1;
  IplImage *imggray2;
  IplImage *imggray3;
        

     // load image one
    img1 = cvLoadImage( argv[1] ); 
   // grayscale buffers
  imggray1 = cvCreateImage( cvGetSize( img1 ), IPL_DEPTH_8U, 1);
  imggray2 = cvCreateImage( cvGetSize( img1 ), IPL_DEPTH_8U, 1);
  imggray3 = cvCreateImage( cvGetSize( img1 ), IPL_DEPTH_8U, 1);

   // convert rgb to grayscale
    cvCvtColor( img1, imggray1, CV_RGB2GRAY );
    
    // load image two
    img2 = cvLoadImage( argv[2] );

    // convert rgb to grayscale
    cvCvtColor( img2, imggray2, CV_RGB2GRAY );
    
    // compute difference
    cvAbsDiff( imggray1, imggray2, imggray3 );
    
    cvSaveImage( argv[3], imggray3 );
   return 0;
}
