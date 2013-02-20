package SimCam::Api;
use Mojo::Base "Mojolicious::Controller";
use Digest::SHA qw/sha1_hex/;
use MIME::Base64;
use Mojo::JSON;
use DateTime;
use File::Slurp;
use Capture::Tiny;


my $IMAGE_LOCATION = 'public/uploads/';

sub create_image {
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

sub get_image {
    my $self = shift;
    my $id = $self->param('id');

    my $loc =  $IMAGE_LOCATION.$id.'_in.png';

    if( -e $loc ){

        return $self->render_static( 'uploads/'.$id  );

    } 

    return $self->render({ json => {message => 'Invalid Argument'}, text => 'Invalid Argument', status => 400 });
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

sub get_diff {
    my $self = shift;
    my $first = $self->param('first');
    my $second = $self->param('second');

    my $first_file_loc = $IMAGE_LOCATION.$first.'_in.png';
    my $second_file_loc = $IMAGE_LOCATION.$second.'_in.png';
    my $out_file_loc = $IMAGE_LOCATION.$first.'_'.$second.'_diff.png';

     $self->app->log->info(" ../simcamCV/diff  $first_file_loc $second_file_loc $out_file_loc");
    my ($merged, @result) = Capture::Tiny::capture_merged sub {

       `../simcamCV/diff $first_file_loc $second_file_loc $out_file_loc`;

    };

    if( $merged ){
        $self->app->log->error( "Api|get_diff error: $merged" ) if $merged;
        return $self->render( text => 'Error differencing images: '. $merged, 
                              json => { message => 'Error differencing images: '. $merged }, 
                              status=> 500 );
    }

    return $self->render_static( 'uploads/'.$first.'_'.$second.'_diff.png') ;

}

sub get_check {
   my $self = shift;
   my $image = $self->param('image'); 
   my $type = $self->param('type');

   if( $type && $type eq 'base64' ){
	my $image = $self->store_base64image( $image ); 
   }

   my $run = '../simcamCV/check public/uploads/'.$image.'_in.png public/uploads/'.$image.'_check.png'; 

      $self->app->log->info( $run );
    my $result;
    my ($merged, @result) = Capture::Tiny::capture_merged sub {
       $result = system split(' ', $run);
    };

    if( $merged ){
        $self->app->log->error( "Api|get_check error: $merged" ) if $merged;
        return $self->render( text => 'Error checking image: '. $merged, 
                              json => { message => 'Error checking images: '. $merged }, 
                              status=> 500 );
    }


    return $self->render( html => '<a href="uploads/'.$image.'_check.png" />', 
			  text => "Result: $result, Image: $image ", 
			  json => { image => $image.'_check.png', result => $result}   );




}

sub get_distort {
   my $self = shift;
   my $image = $self->param('image'); 

}

sub get_calibrate {
   my $self = shift;
   my $json = $self->req->json; 
 

   my @images = $json->{images};



}

1;
