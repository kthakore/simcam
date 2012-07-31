package SimCam::Environ;
use Mojo::Base 'Mojolicious::Controller';

sub noise {
    my $self = shift;
    
    $self->render({ json => {} } );
}

sub noiseid {
    my $self  = shift;
    my $alpha = $self->param('alpha');
    my $type  = $self->param('type');

    $self->render({ json => { alpha => $alpha, type => $type } } );
}

sub distort {
    my $self = shift;

    my $Distortion = '<?xml version="1.0"?>
<opencv_storage>
<Distortion type_id="opencv-matrix">
  <rows>5</rows>
  <cols>1</cols>
  <dt>f</dt>
  <data>
    1.18015432e+00 -1.81575623e+02 3.04214712e-02 -3.06403786e-02
    1.41363682e+04</data></Distortion>
</opencv_storage>';


}


1;
