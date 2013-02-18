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

sub login {
    my $self = shift;
    my $u    = $self->param('email');
    my $study = $self->param('study');

    my $e = '';
    if ( $self->authenticate( lc($u) ) ) {
        $self->redirect_to('/session');
    }
    else {


        my $schema = $self->app->schema();

        my $rs_usr = $schema->resultset('Usr');

        my $type;

        my $d_types =  $rs_usr->count({
            type => 'D' 
        });
        my $s_types =  $rs_usr->count({
            type => 'S' 
        });
        my $sh_types =  $rs_usr->count({
            type => 'SH' 
        });
    
        if ( $d_types < $s_types || $d_types < $sh_types ) {
            $type = 'D';
        } elsif ( $s_types < $d_types || $s_types < $sh_types ) {
            $type = 'S';
        } elsif ( $sh_types < $d_types || $sh_types > $s_types ) {
            $type = 'SH';
        } else {
            my @types = ( 'SH', 'S', 'D' ); 
            $type = $types[ rand @types ];
        }
        $study = 'CV' unless $study;

        $rs_usr->create( {
            email => $u,
            type => $type,
            current_session => 0,
            json_store => '{}',
            study => $study
        } );

        $self->authenticate( lc( $u ) );   

        $self->redirect_to('/session/0/start');
    }


}

1;
