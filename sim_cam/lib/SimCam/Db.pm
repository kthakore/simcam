package SimCam::Db;
use Mojo::Base 'Mojolicious::Controller';

sub save {
    my $self = shift;
    my $params = $self->req->json();
    my $d = $self->app->kdb->{d};
    my $uuid = $d->store( $params );
    
    $params->{id} = $uuid;
    $self->render({ json => $params });
}


1;
