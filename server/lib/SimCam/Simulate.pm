package SimCam::Simulate;
use strict;
use warnings;

# Add noise to an image 
sub noise {
    my( $image, $amount, $type, $output ) = @_;

   `../simcamCV/noise $image $amount $type $output`;
}

sub encoded_noise {
    my( $image 

}

1;
