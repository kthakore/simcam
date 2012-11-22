package SimCam::Root;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON;

# This action will render a template
sub index {
    my $self = shift;

    my $user = $self->current_user;

    # Render template "root/index.html.ep" with message
    if ($user) {
        $self->redirect_to('/session/start');
    }
    else {
        $self->render( template => 'root/login' );
    }
}


sub start_session {
    my $self = shift;

    my $user = $self->current_user;

    $self->render( user => $user );

}


sub login {
    my $self = shift;
    my $u    = $self->param('email');

    my $e = '';
    if ( $self->authenticate( lc($u) ) ) {
        $self->redirect_to('/session/start');
    }
    else {
        $self->redirect_to('/');
    }

}

sub logout {
    my $self = shift;
    my $user = $self->current_user;

    if ($user) {
        $self->session( expires => 1 );

    }
    $self->redirect_to('/');

}
sub end_session {
    my $self = shift;

    my $user = $self->current_user;

    $self->render( user => $user );

}


sub run_session {
    my $self        = shift;
    my $session_num = $self->param('num');

    my $user = $self->current_user;

    $self->render( session => $session_num, user => $user  );

}

sub save_session {
    my $self        = shift;
    my $session_num = $self->param('num');

    my $user = $self->current_user;

    my @names = $self->param;

    my $pp_eq = {};
    foreach my $name (@names) {

        $pp_eq->{$name} = $self->param($name);

    }

    $self->render( { json => $pp_eq } );

}

# Util

1;

