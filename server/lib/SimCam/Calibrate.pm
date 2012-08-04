package SimCam::Calibrate;
use Mojo::Base 'Mojolicious::Controller';
use MIME::Base64;
use File::Slurp;
use JSON;
use XML::Simple;


# This action will render a template
sub root {
  my $self = shift;

  # Render template "example/welcome.html.ep" with message
  $self->render(
    json => 'Welcome to the Mojolicious real-time web framework!');
}

sub counter {
  my $self = shift;

  $self->render( json => $self->session->{counter}++ );

}


1;
