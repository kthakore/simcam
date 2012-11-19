package SimCam::Root;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub index {
    my $self = shift;

    my $user = $self->current_user;

    # Render template "root/index.html.ep" with message
    if ($user) {
        $self->redirect_to('/start');
    }
    else {
        $self->render( template => 'root/login' );
    }
}

sub login {
    my $self = shift;
    my $u    = $self->param('email');

    warn $u;

    my $e = '';
    if ( $self->authenticate($u) ) {
        $self->redirect_to('/start');
    }
    else {
        $self->redirect_to('/');
    }

}

sub logout {
    my $self = shift;
    my $user = $self->current_user;

    if( $user )
    {
      $self->session(expires => 1);
       
    }
    $self->redirect_to('/');

}

sub start {
    my $self = shift;
    my $user = $self->current_user;

    $self->render( { text => 'Hi' } );


}

1;

