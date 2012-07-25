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

}


1;
