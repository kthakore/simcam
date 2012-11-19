package SimCam::Root;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub index {
  my $self = shift;

  # Render template "root/index.html.ep" with message
  $self->render(
    message => 'Welcome to the Mojolicious real-time web framework!');
}

# This action will render a template
sub index_cardiac {
  my $self = shift;

  # Render template "root/index.html.ep" with message
  $self->render(
    message => 'Welcome to the Mojolicious real-time web framework!');
}


sub login {
  my $self = shift;

  # Render template "root/login.html.ep" with message
  $self->render(
    message => 'Welcome to the Mojolicious real-time web framework!');
}


1;

