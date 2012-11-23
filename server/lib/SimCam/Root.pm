package SimCam::Root;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON;

use DateTime;

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

    if( $user) {

        #get the current_session
        my $s_num = $user->current_session;
        $s_num = 0 unless $s_num;

        #Create a session if it doesn exist

        my $schema = $self->app->schema();
        my $se_rs = $schema->resultset('Session');

        my $session = $se_rs->search({ usr => $user->id, milestone => $s_num})->next();

        if( $session ) {
            #session already exists just show it then

            return $self->redirect_to('/session/'.$s_num);
        } else {

            $se_rs->create({
                usr => $user->id,
                start_time => DateTime->now(), 
                json_store => '{}'
            });

           return  $self->redirect_to('/session/'.$s_num );
        } 

    } else {
        $self->redirect_to('/');
    }

}


sub login {
    my $self = shift;
    my $u    = $self->param('email');

    my $e = '';
    if ( $self->authenticate( lc($u) ) ) {
        $self->redirect_to('/session/start');
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
    
        if ( $d_types < $s_types && $d_types < $sh_types ) {
            $type = 'D';
        } elsif ( $s_types < $d_types && $s_types < $sh_types ) {
            $type = 'S';
        } elsif ( $sh_types < $d_types && $sh_types > $s_types ) {
            $type = 'SH';
        } else {
            my @types = ( 'SH', 'S', 'D' ); 
            $type = $types[ rand @types ];
        }

        $rs_usr->create( {
            email => $u,
            type => $type,
            current_session => 0,
            json_store => '{}'
        } );

        $self->authenticate( lc( $u ) );   

        $self->redirect_to('/session/start');
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
    my $s_num = $self->param('num');

    my $user = $self->current_user;

    if( $user ) {


        my $schema = $self->app->schema();
        my $se_rs = $schema->resultset('Session');

        my $session = $se_rs->search({ usr => $user->id, milestone => $s_num})->next();
        
        if( $session ) {

            $self->render({ user => $user, session => $session} );

        } else {
            return $self->redirect_to('/session/start');
        }

    } else {
        $self->redirect_to('/');
    }

}

sub save_session {
    my $self        = shift;
    my $session_num = $self->param('num');

    my $user = $self->current_user;

    if( $user ) {

        my @names = $self->param;

        my $pp_eq = {};
        foreach my $name (@names) {

            $pp_eq->{$name} = $self->param($name);

        }

        $self->render( { json => $pp_eq } );
    } else {
        $self->redirect_to('/');
    }

}

# Util

1;

