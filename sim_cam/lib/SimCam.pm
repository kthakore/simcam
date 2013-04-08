package SimCam;
use Mojo::Base 'Mojolicious';
use SimCam::Schema;
use Mojolicious::Plugin::Config;
use Mojolicious::Plugin::Session;
use Mojolicious::Plugin::Authentication;


has 'schema' => 
    sub { return  SimCam::Schema->connect('dbi:SQLite:database=simcam.db'); };

# This method will run once at server start
sub startup {
  my $self = shift;


  $self->mode('production');

    $self->plugin(
        'authentication' => {
        'session'     => { 'stash_key' => 'simcam', 'expires' => 2592000 },
            'load_user' => sub {

                my $self   = shift;
                my $uid    = shift;
                my $schema = $self->app->schema;
                my $usrs   = $schema->resultset('Usr');
                my $usr    = $usrs->find( { id => $uid } );
                if ($usr) {
                    return $usr;
                }
                else {
                    return undef;
                }

            },
            'validate_user' => sub {
                my $self   = shift;
                my $schema = $self->app->schema;
                my $email  = shift;

                my $usr =
                  $schema->resultset('Usr')->search( { email => $email } )
                  ->next();
                
            
                if ($usr) {
                    return $usr->id();
                }
                else {
                    $self->app->log->info('Login user not found.');
                    return undef;
                }
              }

        }
    );


  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('front#index');

  $r->post('/login')->to('front#login');

  $r->get('/logout' => sub {  
        my $self = shift;
        my $user = $self->current_user;
        if( $user ) {
            $self->session( expires => 1 );
        }
        return $self->redirect_to('/');
    });


  $r->get('/session/:num/start')->to('session#start');
  $r->get('/session/:num/end')->to('session#end');

  $r->get('/session/:num')->to('session#run');
  $r->post('/session/:num')->to('session#save');


  # API METHODS

  # POST IMAGE IN Base64 or uploads (NI)
  $r->post('/api/image')->to('api#create_image');

  $r->get('/api/image/:id')->to('api#get_image');

  # DIFF IMAGES 
  $r->get('/api/diff/:first/:second')->to('api#get_diff');

  # CHECK GRID IN IMAGE
  $r->get('/api/check/:image')->to('api#get_check');
  $r->get('/api/check')->to('api#get_check');


  # DISTORT AN IMAGE
  $r->get('/api/distort/:image')->to('api#get_distort');
  # DISTORT AN IMAGE
  $r->get('/api/undistort/:image')->to('api#get_undistort');


  # CALIBRATE IMAGES
  $r->get('/api/calibrate')->to('api#get_calibrate'); #EXPECTS LIST OF IMAGES

  $r->websocket('/api/calibration')->to('api#calibration_socket'); 


}

1;
