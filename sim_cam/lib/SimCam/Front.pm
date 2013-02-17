package SimCam::Front;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::JSON;
use DateTime;

sub index {
    my $self = shift;
    my $user = $self->current_user;
   
    if ($user) {
        $self->redirect_to('/session/'.$user->current_session.'/start');
    }
}

1;
