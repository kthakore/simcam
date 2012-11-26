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
        $self->redirect_to('/session/'.$user->current_session.'/start');
    }
    else {

        $self->render( template => 'root/login' );
    }
}


sub login {
    my $self = shift;
    my $u    = $self->param('email');

    my $e = '';
    if ( $self->authenticate( lc($u) ) ) {
        $self->redirect_to('/session/0/start');
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

        $rs_usr->create( {
            email => $u,
            type => $type,
            current_session => 0,
            json_store => '{}'
        } );

        $self->authenticate( lc( $u ) );   

        $self->redirect_to('/session/0/start');
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
            $self->app->log->info("Session start to session/$s_num");

            return $self->redirect_to('/session/'.$s_num);
        } else {

            $se_rs->create({
                usr => $user->id,
                milestone => $s_num,
                start_time => DateTime->now(), 
                json_store => '{}'
            });

            $self->app->log->info("Session start to session/$s_num after Create");

           return  $self->redirect_to('/session/'.$s_num );
        } 

    } else {
        $self->redirect_to('/');
    }

}


sub run_session {
    my $self        = shift;
    my $s_num = $self->param('num');

    my $user = $self->current_user;

    if( $user ) {


        my $schema = $self->app->schema();
        my $se_rs = $schema->resultset('Session');

        if( $s_num != $user->current_session ) {
            return $self->redirect_to( '/session/'.$user->current_session );
        } 

        my $session = $se_rs->search({ usr => $user->id, milestone => $s_num})->next();
        
        if( $session ) {

            $self->render({ user => $user, session => $session} );

        } else {
            $self->app->log->info("Redirecting session $s_num to start");

            return $self->redirect_to('/session/'.$s_num.'/start');
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

        my $schema = $self->app->schema;
        my $rs_session = $schema->resultset('Session');

        my $session = $rs_session->search({ usr => $user->id, milestone => $user->current_session })->next();

        my $js = Mojo::JSON->decode( $session->json_store() );

        $js->{params} = $pp_eq;

        $session->update({ json_store => Mojo::JSON->encode( $js ) } );

        #TODO: Ask for session end

        return $self->redirect_to('/session/'.$session_num .'/end');

    } else {
        $self->redirect_to('/');
    }

}



sub end_session {
    my $self = shift;

    my $user = $self->current_user;

    if( $user ) {
    
        my $schema = $self->app->schema;
        my $rs_session = $schema->resultset('Session');

        my $session = $rs_session->search({ usr => $user->id, milestone => $user->current_session });

        $session->update({ end_time => DateTime->now() } );

        if( $user->current_session < 4 ) {
            my $next_session = $user->current_session + 1;
            $user->update({ current_session => $next_session });
            $self->app->log->info("Redirecting end to start session $next_session");
            return $self->redirect_to('/session/'.$next_session.'/start');
        } else {
            return $self->render( user => $user );

        }

        

    } else {

        return $self->redirect_to('/');

    }

}

# Util

1;

