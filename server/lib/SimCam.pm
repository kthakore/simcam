package SimCam;
use Mojo::Base 'Mojolicious';
use KiokuDB;
use KiokuDB::Backend::Files;


has 'kdb' => sub { 

    my $d =  KiokuDB->connect(
            "dbi:SQLite:dbname=simcam.db"
             );
    return { d => $d, scope =>  $d->new_scope };
};

# This method will run once at server start
sub startup {
    my $self = shift;


# Router
    my $r = $self->routes;

# Normal route to controller
    $r->get('/')->to('root#index');
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
    $r->post('/save')->to('db#save');
    $r->get('/camera/:id')->to('db#get_camera');
    $r->get('/cameras')->to('db#cameras');



# TODO:
# $r->post('/calibrate');
# $r->register('/register');




}

1;
