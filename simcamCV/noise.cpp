//
// Simple retro-style photo effect done by adding noise to
// the luminance channel and reducing intensity of the chroma channels
//

// include standard OpenCV headers, same as before
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <stdio.h>

// all the new API is put into "cv" namespace. Export its content
using namespace cv;

// enable/disable use of mixed API in the code below.
#define DEMO_MIXED_API_USE 1

int main( int argc, char** argv )
{
    const char* imagename = argc > 1 ? argv[1] : "lena.jpg";

    double alpha = argc > 2 ? atof( argv[2] ) : 0.4;

    int type = argc > 3 ? atoi( argv[3] ) : 0;

    const char* outimage = argc > 4 ? argv[4] : "out.jpg";
    // Ptr<T> is safe ref-conting pointer class

    // cv::Mat replaces the CvMat and IplImage, but it's easy to convert
    // between the old and the new data structures
    // (by default, only the header is converted and the data is shared)
    Mat img = imread( imagename );


    // another Mat constructor; allocates a matrix of the specified
        // size and type
    Mat noise = imread( imagename ); //(img.size(), CV_8U);

    // fills the matrix with normally distributed random values;
    // there is also randu() for uniformly distributed random numbers.
    // Scalar replaces CvScalar, Scalar::all() replaces cvScalarAll().
    if( type > 0 )
    {
        randu(noise, Scalar::all(128), Scalar::all(20));
    }
    else
    {
        randn(noise, Scalar::all(128), Scalar::all(20));

    }

     double beta; double input;
    beta = (1.0 - alpha );

    Mat dst; 

    addWeighted( img, beta, noise, alpha, 0.0, dst );

    imwrite( outimage, dst );

    return 0;
    // all the memory will automatically be released
    // by vector<>, Mat and Ptr<> destructors.
}
