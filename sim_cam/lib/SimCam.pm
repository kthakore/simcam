package SimCam;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;


  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/' => sub { shift->render_static('/index.html') });
  $r->get('/counter')->to('calibrate#counter');

  # Noise
  $r->post('/noise')->to('environ#noise');
  $r->post('/distort')->to('environ#distort');
  $r->post('/get_image')->to('environ#get_image');

  $r->post('/combine')->to('environ#combine');

  # TODO:
  # $r->post('/calibrate');
  # $r->register('/register');



  
}

1;
