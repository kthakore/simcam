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

sub run_distort {
    my $self = shift;
    my $params = shift;

    my $t1= $params->{t1} || 0.0;
    my $t2= $params->{t2} || 0.0;
    my $r1= $params->{r1} || 0.0;
    my $r2= $params->{r2} || 0.0;
    my $r3= $params->{r3} || 0.0;

    my $Distortion = '<?xml version="1.0"?>
        <opencv_storage>
        <Distortion type_id="opencv-matrix">
        <rows>5</rows>
        <cols>1</cols>
        <dt>f</dt>
        <data>
        '. $r1 .' '.$r2.' '.$t1.' '.$t2.' '.$r3.
        '</data></Distortion>
        </opencv_storage>';


    my $fy = $params->{fy} || $params->{far} || 3000;
    my $fx = $params->{fx} || $params->{far} || 3000;
    my $cy = $params->{cy} || $params->{u} /2 || 300;
    my $cx = $params->{cx} || $params->{v} /2 || 240;

    my $image = $params->{image} || 'in.png';


    my $Intrinsics = '<?xml version="1.0"?>
        <opencv_storage>
        <Intrinsics type_id="opencv-matrix">
        <rows>3</rows>
        <cols>3</cols>
        <dt>f</dt>
        <data>
        '.$fx.' 0. '.$cx.' 0. '.$fy.' '.$cy.' 0.
        0. 1.</data></Intrinsics>
        </opencv_storage>';

    my $job_id = $image.'_distort_'.$fx.'_'.$fy.'_'.$cx.'_'.$cy.'_'.$r1.'_'.$r2.'_'.$t1.'_'.$t2.'_'.$r3;

    my $dist_path = 'public/uploads/'.$job_id.'_dist.xml';
    my $int_path = 'public/uploads/'.$job_id.'_int.xml';

    File::Slurp::write_file( $dist_path, $Distortion );
    File::Slurp::write_file( $int_path, $Intrinsics );

   
    my $out_image = 'public/uploads/'.$job_id.'.png';

    my $run  = "../simcamCV/distort $dist_path $image $out_image $int_path";

    $self->app->log->info( $run );

    my( $stdout, $stderr, @result) = Capture::Tiny::capture {
        
        `$run`
    };

    if( -f $out_image )
    {
        return { success => 1, out => $out_image, distortions_xml => $dist_path, intrinsics_xml => $int_path, job_id => $job_id };
    }
    else
    {
        return { success => 0, result => { out => $stdout, err => $stderr, res => \@result } , job_id => $job_id};  
    }
}

1;
