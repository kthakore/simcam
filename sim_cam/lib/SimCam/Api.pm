package SimCam::Api;
use Mojo::Base "Mojolicious::Controller";
use Digest::SHA qw/sha1_hex/;
use MIME::Base64;
use Mojo::JSON;
use DateTime;
use File::Slurp;
use Capture::Tiny;


my $IMAGE_LOCATION = 'public/uploads/';

sub image {
   my $self = shift;
   my $params = $self->req->json;

   $self->app->log->info('Api|Image|called');
   if( $params->{type} eq 'base64' ) {
       $self->app->log->info('Api|Image|base64');

       my $local_image = $self->store_base64image( $params->{image} ); 
       return $self->render( { json => { img => $local_image } } );
   } elsif ( $params->{type} eq 'upload') {
       $self->app->log->info('Api|Image|upload');

       return $self->render( { json => { message => 'Upload not implemented yet.' }, status => 501 } );

   } else {
       $self->app->log->info('Api|Image|invalid');
       return $self->render( { json => { message => 'Invalid format'}, text=> 'Invalid params', status => 400 } );
   }

}

sub store_base64image {

    my $self = shift;

    my $uri = shift;
    $uri =~ s/(^.+?,)//;

    my $d = MIME::Base64::decode_base64($uri);
    my $file_name = sha1_hex( $uri );
    my $file_loc = $IMAGE_LOCATION.$file_name;
    File::Slurp::write_file( $file_loc, $d );
   
    $self->imagemagick_convert(  $file_loc, $file_loc.'_in.png' );   
    return $file_name;

}

sub imagemagick_convert {
    my $self = shift;
    my $first = shift; 
    my $second = shift;

    my ($merged, @result) = Capture::Tiny::capture_merged sub {

       `convert $first $second`;

    };

    if( $merged ){
        $self->app->log->error( "Api|imagemagick_convert error: $merged" ) if $merged;
        return -1;
    }

    return 1;
}

1;
