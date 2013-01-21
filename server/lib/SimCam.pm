package SimCam;
use Mojo::Base 'Mojolicious';
use SimCam::Schema;
use Mojolicious::Plugin::Config;
use Mojolicious::Plugin::Session;
use Mojolicious::Plugin::Authentication;
use Digest::SHA qw(sha1_hex);
use Authen::Passphrase::SaltedSHA512;
use Data::Dumper;
use DateTime;

has 'schema' =>
  sub { return SimCam::Schema->connect('dbi:SQLite:database=simcam.db'); };

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->config(hypnotoad => {listen => ['http://*:5000']});

    $self->mode('production');

# Router
    $self->plugin(
        'authentication' => {
            session     => { 'stash_key' => 'simcam', 'expires' => 2592000 },
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
                    warn 'not validate';
                    return undef;
                }
              }

        }
    );

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/')->to('root#index');
    $r->post('/login')->to('root#login');
    $r->get('/logout')->to('root#logout');


    $r->get('/session/:num/start')->to('root#start_session');
    $r->get('/session/:num/end')->to('root#end_session');

    $r->get('/session/:num')->to('root#run_session');
    $r->post('/session/:num')->to('root#save_session');


    $r->get('/counter')->to('calibrate#counter');

    # Noise
    $r->post('/noise')->to('environ#noise');
    $r->post('/distort')->to('environ#distort');
    $r->post('/get_image')->to('environ#get_image');

    $r->post('/combine')->to('environ#combine');
    $r->put('/combine')->to('environ#combine');

    $r->post('/check')->to('environ#check');
    $r->post('/calibrate')->to('environ#calibrate');
    $r->post('/register')->to('environ#register');
    $r->put('/register')->to('environ#register');

    $r->any('/cleanup')->to('environ#cleanup');

    # Save
    $r->post('/save')->to('camera#save');
    $r->get('/camera/:id')->to('camera#get_camera');
    $r->get('/cameras')->to('camera#cameras');


    $r->any('/parse' => sub {
            my $self = shift;
    $self->res->headers->header( 'Access-Control-Allow-Origin' => '*' );
    $self->res->headers->header(
        'Access-Control-Allow-Methods' => 'PUT, GET, DELETE, POST, OPTIONS' );
    $self->res->headers->header( 'Access-Control-Max-Age' => '1728000' );
    $self->res->headers->header(
        'Access-Control-Allow-Headers' => 'Content-Type' );

            my $req = $self->req;
            my $json = $req->json;
            warn Dumper $req;
            return $self->render( {json => {} } );
        });

    # TODO:
    # $r->post('/calibrate');
    # $r->register('/register');

}

1;
