package SimCam::Session;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::JSON;
use DateTime;

our $MaxSession = 7;

sub start {
    my $self = shift;

    my $user = $self->current_user;

    if( $user) {

        #get the current_session
        my $s_num = $user->current_session;
        $s_num = 0 unless $s_num;

        #Create a session if it doesn exist

        my $schema = $self->app->schema();
        my $se_rs = $schema->resultset('Session');

        my $session = $se_rs->search({ usr_id => $user->id, milestone => $s_num})->next();

        if( $session ) {
            #session already exists just show it then
            $self->app->log->info("Session start to session/$s_num");

            return $self->redirect_to('/session/'.$s_num);
        } else {

            $se_rs->create({
                usr_id => $user->id,
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


sub run {
    my $self        = shift;
    my $s_num = $self->param('num');

    my $user = $self->current_user;

    if( $user ) {


        my $schema = $self->app->schema();
        my $se_rs = $schema->resultset('Session');

        if( $s_num != $user->current_session ) {
            if( $user->study eq 'CV' && $s_num < $user->current_session && $s_num >= 0){
    
                $self->app->log->info("Valid change back of session $s_num");
                $user->update({ current_session => $s_num });

            }
            return $self->redirect_to( '/session/'.$user->current_session );
        } 
        my $dir = 'templates/session/'. $user->study.'/';
        my @files = <$dir/*.html.ep>;
        my $count = scalar @files;

        if ( $s_num > ($count - 1) ){
            $s_num = $count - 1;
            $self->app->log->info("Valid force of session last: $s_num");
            $user->update({ current_session => $s_num });
        }

        my $session = $se_rs->search({ usr_id => $user->id, milestone => $s_num})->next();
        
        if( $session ) {

            $self->render({ user => $user, session => $session, sessions => $count} );

        } else {
            $self->app->log->info("Redirecting session $s_num to start");

            return $self->redirect_to('/session/'.$s_num.'/start');
        }

    } else {
        $self->redirect_to('/');
    }

}

sub save {
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

        my $session = $rs_session->search({ usr_id => $user->id, milestone => $user->current_session })->next();

        my $js = Mojo::JSON->decode( $session->json_store() );

        $js->{params} = $pp_eq;

        $session->update({ json_store => Mojo::JSON->encode( $js ) } );

        #TODO: Ask for session end

        return $self->redirect_to('/session/'.$session_num .'/end');

    } else {
        $self->redirect_to('/');
    }

}



sub end {
    my $self = shift;

    my $user = $self->current_user;

    if( $user ) {
    
        my $schema = $self->app->schema;
        my $rs_session = $schema->resultset('Session');

        my $session = $rs_session->search({ usr_id => $user->id, milestone => $user->current_session });

        $session->update({ end_time => DateTime->now() } );

        my $dir = 'templates/session/'. $user->study.'/';
        my @files = <$dir/*.html.ep>;
        my $count = scalar @files;

        $self->app->log->info("End: Found $count files more");

        if( $user->current_session < $count ) {
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


1;
