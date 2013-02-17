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


  $self->mode('development');

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
  $r->get('/')->to('front#index');


  # API METHODS

  # POST IMAGE IN Base64 or uploads (NI)
  $r->post('/api/image')->to('api#image');



}

1;
