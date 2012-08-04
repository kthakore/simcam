package SimCam::Db;
use Mojo::Base 'Mojolicious::Controller';

sub save {
    my $self = shift;
    my $params = $self->req->json();
    my $d = $self->app->kdb->{d};
    my $uuid = $d->store( $params );

    $params->{image} = $params->{final_image};

    $params->{id} = $uuid;
    $self->render({ json => $params });
}

sub get_camera {
    my $self = shift;
    my $id = $self->param('id');
    my $d = $self->app->kdb->{d};

    my $found =  $d->lookup( $id );

    $self->render({json => $found } );

}

1;
