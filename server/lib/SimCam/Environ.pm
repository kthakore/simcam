package SimCam::Environ;
use Mojo::Base 'Mojolicious::Controller';
use Digest::SHA qw/sha1_hex/;
use Capture::Tiny qw/:all/;
use MIME::Base64;
use File::Slurp;
use JSON;
use XML::Simple;
use utf8;
use Data::Dumper;

sub cleanup {
    my $self = shift;
    my $obj = $self->param('obj');
    my $rmed = "rm public/$obj";
    warn $rmed;
    #`$rmed`;
    $self->render({json => { } });

}

sub register {
    my $self = shift;
    my $params = $self->req->json;

    my $image = 'public/'.$params->{final_image}; 
       `cp $image register/1.png`;
     `cd register; matlab -nosplash -nodesktop -r ecc_demo; cp out.png ../public/out.png`; 
 
    $self->render({json => { out => 'public/out.png' } });

}

sub calibrate {
    my $self = shift;
    my $params = $self->req->json;
    my $checked_images = $params->{checked};
    if (  $#{$checked_images} < 1 )
    {
        $self->render({ json => { message => "Need at least 2 found pattern images to calibrate"}, status => 400 } );
    }
    else {
        my @run = ('../simcamCV/calibrate', ( "/tmp/Intrinsics.xml", "/tmp/Distortion.xml", @{$checked_images}) );
        $self->app->log->info( join(' ', @run ) );

        my $status = system @run;

        if( $status == 256 )
        {
            my $xs = XML::Simple->new();
            my $d_data = $xs->XMLin("/tmp/Distortion.xml");
            my $f_data = $xs->XMLin("/tmp/Intrinsics.xml");


            my $d_cv_data = $d_data->{Distortion}->{data};

            $d_cv_data =~ s/\s/ /g;

            my $i_cv_data = $f_data->{Intrinsics}->{data};

            $i_cv_data =~ s/\s/ /g;
          
            my @d_array = split(' ', $d_cv_data ); 
            my @f_array = split(' ', $i_cv_data );
           
            my $last = pop @{$checked_images};
            my $distorted =   $self->_run_undistort( { image => $last, dist => '/tmp/Distortion.xml', int => '/tmp/Intrinsics.xml'} );
            warn $params->{diff};
        
            my $diff = $self->_run_diff( $params->{diff}, $distorted->{out} ); 

            my $img_out_diff = $diff->{out};
            $diff->{mean} = `convert public/$img_out_diff -format "%[fx:mean]" info:`;
            $diff->{std} =  `convert public/$img_out_diff -format "%[fx:standard_deviation]" info:`;

            $distorted->{diff} = $diff;

            my $fo = { distortion => \@d_array, intrinsics => \@f_array, undistorted => $distorted };
            $self->render({ json => $fo } );

        }
        else
        {

            $self->render({ json => { message => "Couldn't calibrate"}, status => 400 } );

        }
    }


}

sub check {
    my $self = shift;
    my $params = $self->req->json;
    my $image = $params->{image};
    

    my $checked = system '../simcamCV/check', 'public/'.$image,  'public/found_'.$image; 
    $self->render({ json => { checked => $checked, image => 'found_'.$image } });

}


sub noise {
    my $self = shift;
    my $params = $self->req->json;

    $params->{image} = $self->_get_image( $params->{image} );
    my $noise = $self->_run_noise( $params ); 
    $self->app->log->info( Dumper $noise);

    $self->render({ json => $noise} );
}


sub distort {
    my $self = shift;
    my $params = $self->req->json;
 
    $params->{image} = $self->_get_image( $params->{image} );

    my $distorted =   $self->_run_distort( $params );
    #unlink( $params->{image});
    $self->render({ json => $distorted } );
   
}


sub combine {
    my $self = shift;
    my $params = $self->req->json;

    

    $params->{image} = $self->_get_image( $params->{image} );

    my $noise_res =  $self->_run_noise( $params );

    #unlink( $params->{image});

    $params->{image} =  'public/'.$noise_res->{out};
    my $dist_res = $self->_run_distort( $params );

    if( $params->{save_noise} )
    {
          $dist_res->{save_noise} = $noise_res->{out};       
    }


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
    $uri =~ s/(^.+?,)//; 

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
    my $type = $params->{noise_type} || 1;

        $type = 1 if ($type && $type =~ 'Uniform' );
        $type = 0 if ($type && $type =~ 'Normal' );


    my $job_id = sha1_hex( localtime. $alpha. $type );

    if ($alpha > 1.00) { $alpha = 1.00 };

    my $out = 'public/job_images/'.$job_id.'_noise.png';

    my $run = "../simcamCV/noise foo.jpg $alpha $type $out";

    my( $stdout, $stderr, @result) = capture {

        `convert $image foo.jpg`;
        `$run`;

    };

    if( -f $out )
    {
        return { alpha => $alpha, success => 1, job_id => $job_id, out => 'job_images/'.$job_id.'_noise.png' };        
    }
    else
    {   

        return { success => 0, job_id => $job_id, result => { out => $stdout, err => $stderr, res => \@result} };

    }

}
sub _run_diff {
    my $self = shift;
    my $image0 = shift;
    my $imaget = shift;
    my $job_id = sha1_hex( localtime.rand);
 
    my $out_image = 'public/job_images/'.$job_id.'.png';

    my $run  = "../simcamCV/diff public/$image0 public/$imaget $out_image ";
    my( $stdout, $stderr, @result) = capture {
        
        `$run`
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
sub _run_undistort {
    my $self = shift;
    my $params = shift;

    my $image = $params->{image};
    my $dist_path = $params->{dist};
    my $int_path = $params->{int};
    my $job_id = sha1_hex( localtime.rand);
 
    my $out_image = 'public/job_images/'.$job_id.'.png';

    my $run  = "../simcamCV/distort $dist_path $image $out_image $int_path";
    my( $stdout, $stderr, @result) = capture {
        
        `$run`
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

    my $job_id = sha1_hex( localtime. $r1 . $r2. $t1. $t2. $r3. rand);

    my $dist_path = '/tmp/'.$job_id.'_dist.xml';
    my $int_path = '/tmp/'.$job_id.'_int.xml';

    write_file( $dist_path, $Distortion );
    write_file( $int_path, $Intrinsics );

   
    my $out_image = 'public/job_images/'.$job_id.'.png';

    my $run  = "../simcamCV/distort $dist_path $image $out_image $int_path";

    $self->app->log->info( $run );


    my( $stdout, $stderr, @result) = capture {
        
        `$run`
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
