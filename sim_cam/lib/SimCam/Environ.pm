package SimCam::Environ;
use Mojo::Base 'Mojolicious::Controller';
use Digest::SHA qw/sha1_hex/;
use Capture::Tiny qw/:all/;
use MIME::Base64;
use File::Slurp;
use JSON;
use XML::Simple;


sub noise {
    my $self = shift;
    my $params = $self->req->json;

    $params->{image} = $self->_get_image( $params->{image} );

    $self->render({ json => $self->_run_noise( $params ) } );
}


sub distort {
    my $self = shift;
    my $params = $self->req->json;
 
    $params->{image} = $self->_get_image( $params->{image} );

    $self->render({ json =>   $self->_run_distort( $params )} );
   
}


sub combine {
    my $self = shift;
    my $params = $self->req->json;

    $params->{image} = 'public/job_images/'.$self->_get_image( $params->{image} ).'_in.png';

    my $noise_res =  $self->_run_noise( $params );

    $params->{image} =  'public/'.$noise_res->{out};
    
    my $dist_res = $self->_run_distort( $params );

    $self->render({ json => $dist_res } );

}   


sub get_image {
    my $self = shift;
    my $params = $self->req->json;
    
    $self->render( { json => { img => $self->_get_image( $params->{image} ) } } ); 

}

sub _get_image {
    my $self = shift;
    my $uri = shift;
    my $d = decode_base64($uri);
        my $file_name = sha1_hex(time);
        my $file_loc = 'public/job_images/'.$file_name.'_in.png';
        write_file( $file_loc , $d );

    return $file_loc;
}



sub _run_noise {
    my $self = shift;
    my  $params = shift;
    
    my $image = $params->{image};
    my $alpha = $params->{alpha} || 0.00;
    my $type = $params->{type};
    my $job_id = sha1_hex( localtime. $alpha. $type );

    my $out = 'public/job_images/'.$job_id.'_noise.png';

    my( $stdout, $stderr, @result) = capture {
        `simcamCV/noise $image $alpha $type $out`
    };

    if( -f $out )
    {
        return { success => 1, job_id => $job_id, out => 'job_images/'.$job_id.'_noise.png' };        
    }
    else
    {   

        return { success => 0, job_id => $job_id, result => { out => $stdout, err => $stderr, res => \@result} };

    }

}

sub _run_distort {
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

    my $fy = $params->{fy} || 3000;
    my $fx = $params->{fx} || 3000;
    my $cy = $params->{cy} || 300;
    my $cx = $params->{cx} || 240;

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

    my $job_id = sha1_hex( localtime. $r1 . $r2. $t1. $t2. $r3 );

    my $dist_path = '/tmp/'.$job_id.'_dist.xml';
    my $int_path = '/tmp/'.$job_id.'_int.xml';

    write_file( $dist_path, $Distortion );
    write_file( $int_path, $Intrinsics );

   
    my $out_image = 'public/job_images/'.$job_id.'.png';

    my( $stdout, $stderr, @result) = capture {
        `simcamCV/distort $dist_path $image $out_image`
    };

    if( -f $out_image )
    {
        return { success => 1, out => 'job_images/'.$job_id.'.png', job_id => $job_id };
    }
    else
    {
        return { success => 0, result => { out => $stdout, err => $stderr, res => \@result } , job_id => $job_id};  
    }
}

1;
