package SimCam::Api;
use Mojo::Base "Mojolicious::Controller";
use Digest::SHA qw/sha1_hex/;
use MIME::Base64;
use Mojo::JSON 'j';
use DateTime;
use File::Slurp;
use Capture::Tiny;
use XML::Simple;
use Data::Dumper;
use Mojo::IOLoop;


my $IMAGE_LOCATION = 'public/uploads/';

sub image_location {
   my $self = shift;
   my $image = shift;

   my $loc = 'public/uploads/'.$image;
   my $log = $self->app->log();
   $log->info('Looking for image at: '.$loc );
   if ( -e $loc ){
	$log->info( 'Found image: '.$image );
	return $image
   } elsif ( -e $loc. '.png' ) {
	$log->info( 'Found image: '.$image.'.png' );

	return $image.'.png';
   } elsif ( -e $loc. '_in.png' ){
	$log->info( 'Found image: '.$image.'_in.png' );

	return $image.'_in.png';
   }
	$log->info( 'Not Found image: '.$image );

   return;

}

sub create_image {
   my $self = shift;
   my $params = $self->req->json;

   $self->app->log->info('Api|Image|called for type: ');
   if( $params->{type} eq 'base64' ) {
       $self->app->log->info('Api|Image|base64');

       my $local_image = $self->store_base64image( $params->{image} ); 
       return $self->render( { json => { img => $local_image } } );
   } elsif ( $params->{type} eq 'raw') {
       $self->app->log->info('Api|Image|upload');
       my $local_image = $self->store_rawimage( $params->{image} ); 
       return $self->render( { json => { img => $local_image } } );
   } else {
       $self->app->log->info('Api|Image|invalid');
       return $self->render( { json => { message => 'Invalid format'}, text=> 'Invalid params', status => 400 } );
   }

}

sub get_image {
    my $self = shift;
    my $id = $self->param('id');

	
    if( my $located = $self->image_location( $id ) ) {
      return  $self->render_static( 'uploads/'. $located );
    }     

        

    return $self->render({ json => {message => 'Invalid Argument'}, text => 'Invalid Argument', status => 400 });
}

sub store_rawimage {
    my $self = shift;
    my $d = shift;
    warn $d;
    my $file_name = sha1_hex( $d );
    my $file_loc = $IMAGE_LOCATION.$file_name;
    File::Slurp::write_file( $file_loc. '.png', $d );
   
    $self->imagemagick_convert(  $file_loc.'.png', $file_loc.'_in.png' );   
    unlink( $file_loc.'.png' );
    return $file_name;

}

sub store_base64image {

    my $self = shift;

    my $uri = shift;
    $uri =~ s/(^.+?,)//;

    my $d = MIME::Base64::decode_base64($uri);
    my $file_name = sha1_hex( $uri );
    my $file_loc = $IMAGE_LOCATION.$file_name;
    File::Slurp::write_file( $file_loc. '.png', $d );
   
    $self->imagemagick_convert(  $file_loc.'.png', $file_loc.'_in.png' );   
    unlink( $file_loc.'.png' );
    return $file_name;

}

sub imagemagick_convert {
    my $self = shift;
    my $first = shift; 
    my $second = shift;

    $self->app->log->info( "Api|imagemagick_convert: running on $first $second" );
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

    if( $merged && $merged !~ 'libdc1394' ){
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

   unless( $image ) {
        my $json = $self->req->json; 
        $type = $json->{type};
        $image = $json->{image};
   }

   if( $type && $type eq 'base64' ){
    $image = $self->store_base64image( $image ) .'_in.png'; 
   } 

   my $located = $self->image_location( $image );
   
   my $out = sha1_hex($located.'_check').'_check.png';

   my $run = '../simcamCV/check public/uploads/'.$located . ' public/uploads/'. $out; 

    $self->app->log->info( $run );
    my $result;
    my ($merged, @result) = Capture::Tiny::capture_merged sub {
       $result = system split(' ', $run);
    };

    if( $merged && $merged !~ 'libdc1394' ){
        $self->app->log->error( "Api|get_check error: $merged" ) if $merged;
        return $self->render( text => 'Error checking image: '. $merged, 
                              json => { message => 'Error checking images: '. $merged }, 
                              status=> 500 );
    }

   return $self->respond_to( {
     json => sub { $self->render_json( { result => $result, out => $out, in => $located } );  },
     text =>  sub { $self->render_static( 'uploads/'.$out); }
 
   });




}

sub get_distort {
   my $self = shift;
   my $params = $self->req->json;

   $params->{t1} = $self->param('t1') unless $params->{t1};
   $params->{t2} = $self->param('t2') unless $params->{t2};
   $params->{t3} = $self->param('t3') unless $params->{t3};
   $params->{r1} = $self->param('r1') unless $params->{r1};
   $params->{r2} = $self->param('r2') unless $params->{r2};
   $params->{r3} = $self->param('r3') unless $params->{r3};
   $params->{t1} = $self->param('t1') unless $params->{t1};
   $params->{t1} = $self->param('t1') unless $params->{t1};
   $params->{cx} = $self->param('cx') unless $params->{cx};
   $params->{cy} = $self->param('cy') unless $params->{cy};
   $params->{fx} = $self->param('fx') unless $params->{fx};
   $params->{fy} = $self->param('fy') unless $params->{fy};
   $params->{image} = $self->param('image');

   my $result = $self->run_distort($params);
  
   return $self->respond_to( {
     json => sub { $self->render_json( $result );  },
     any =>  sub { $self->render_static( 'uploads/'.$result->{out} ); }
 
   });
   

}

sub get_calibrate {
   my $self = shift;
   my $json = $self->req->json; 
 

   my @images = $self->param('images');

   foreach my $image ( @images ) {

       if( my $location = $self->image_location( $image ) ){
	  $image = $IMAGE_LOCATION.$location	
	} else {

	    return $self->render({ json => {message => 'Invalid Argument: '.$image.' not found'}, text => 'Invalid Argument: '.$image.' not found', status => 400 });
	}
   
   }

   if( scalar @images < 4 ){
	    return $self->render({ json => {message => 'Invalid Argument: need more then 4 images'}, text => 'Invalid Argument: need more then 4 images', status => 400 });

   }

   my $job_id = sha1_hex( join(' ', @images ) );

   my $output = 'public/uploads/'. $job_id;
   my $int    = $output .'_int.xml';
   my $dist   = $output .'_dist.xml';

   my @run = ( '../simcamCV/calibrate', $int, $dist, (@images) );

   my $run  = join(' ', @run);

    $self->app->log->info( $run );

    my( $stdout, $stderr, @result) = Capture::Tiny::capture {
        
        `$run`
    };

    if( $stderr ){
        $self->app->log->error( "Api|get_calibrate error: $stderr" );
        return $self->render( text => 'Error calibrating image: '. $stderr, 
                              json => { message => 'Error calibrating images: '. $stderr }, 
                              status=> 500 );
    }

    # CHeck if xml files exist

    if( -e $int && -e $dist ){
        my $xs = XML::Simple->new();
            $self->app->log->info("Api|get_calibrate reading XMLs $dist and $int");
            my $d_data = $xs->XMLin($dist);
            my $f_data = $xs->XMLin($int);

            my @d_keys = keys %{$d_data};
            my @f_keys = keys %{$f_data};
            my $d_cv_data = $d_data->{$d_keys[0]}->{data};

            $d_cv_data =~ s/\s/ /g;

            my $i_cv_data = $f_data->{$f_keys[0]}->{data};

            $i_cv_data =~ s/\s/ /g;
          
            my @d_array = split(' ', $d_cv_data ); 
            my @f_array = split(' ', $i_cv_data );
           
            my $fo = { distortion => \@d_array, intrinsics => \@f_array, job_id => $job_id};

	return	$self->render({
		json => $fo
	});
    }
   else {
	$self->render({ json => { message => "Couldn't calibrate"}, text => "Couldn't calibrate", status => 400 } );

   }


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

    my $image = $params->{image};
    my $image_path = 'public/uploads/'. $image .'_in.png';
    if( my $located = $self->image_location( $image ) ) {
      $image_path = 'public/uploads/'. $located;
    } 

    my $fy = $params->{fy} || $params->{far} || 1000;
    my $fx = $params->{fx} || $params->{near} || 1000;

    my $rune = 'identify -format "%[width] %[height]" '. $image_path;
    my( $merged, $s, @r)  = Capture::Tiny::capture { `$rune`; };
    my @size = split( ' ', $r[0] ); 
    my $cy = $params->{cy} || $size[0] / 2 || 0;
    my $cx = $params->{cx} || $size[1] / 2 || 0;

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

    my $job_id = $image.'_distort_'.sha1_hex($image.'_'.$fx.'_'.$fy.'_'.$cx.'_'.$cy.'_'.$r1.'_'.$r2.'_'.$t1.'_'.$t2.'_'.$r3);

    my $dist_path = 'public/uploads/'.$job_id.'_dist.xml';
    my $int_path = 'public/uploads/'.$job_id.'_int.xml';

    File::Slurp::write_file( $dist_path, $Distortion );
    File::Slurp::write_file( $int_path, $Intrinsics );

  
    my $out_image = 'public/uploads/'.$job_id.'.png';

    my $run  = "../simcamCV/distort $dist_path $image_path $out_image $int_path";

    $self->app->log->info( $run );

    my( $stdout, $stderr, @result) = Capture::Tiny::capture {
        
        `$run`
    };

    if( -f $out_image )
    {
        return { success => 1, out => $job_id.'.png', distortions_xml => $job_id.'_dist.xml', intrinsics_xml => $job_id.'_int.xml', job_id => $job_id };
    }
    else
    {
        return { success => 0, result => { out => $stdout, err => $stderr, res => \@result } , job_id => $job_id};  
    }
}



sub get_undistort {
    my $self = shift;
    my $job_id = $self->param('job_id');
    my $dist =  $job_id . '_dist.xml';
    my $int = $job_id .'_int.xml';
    my $image = $self->image_location($self->param('image'));

    my $dist_path = $IMAGE_LOCATION.$dist;
    my $int_path = $IMAGE_LOCATION.$int;
    my $image_path = $IMAGE_LOCATION.$image;
    my $out_image =  $IMAGE_LOCATION.$job_id. '_correct.png';

   $job_id .= '_correct'; 

    my $run  = "../simcamCV/distort $dist_path $image_path $out_image $int_path";

    $self->app->log->info( $run );

    my( $stdout, $stderr, @result) = Capture::Tiny::capture {
        
        `$run`
    };

    my $r;
    if( -f $out_image )
        {
            $r = { success => 1, out => $job_id.'.png', job_id => $job_id };
        }
        else
        {
            $r = { success => 0, result => { out => $stdout, err => $stderr, res => \@result } , job_id => $job_id};  
        }

    return $self->respond_to( {
         json => sub { $self->render_json( $r );  },
         any =>  sub { $self->render_static( 'uploads/'.$job_id.'.png' ); }
     
       });

}


sub run_calibration {
    my $self = shift;
    my $images = shift;
    my @images = @{$images};
   foreach my $image ( @images ) {

       if( my $location = $self->image_location( $image ) ){
	  $image = $IMAGE_LOCATION.$location	
	} else {

        
	    $self->app->log->error( 'Invalid Argument: '.$image.' not found');
        return;
	}
   
   }

   if( scalar @images < 4 ){
	    $self->app->log->error('Invalid Argument: need more then 4 images');

        return;

   }

   my $job_id = sha1_hex( join(' ', @images ) );

   my $output = 'public/uploads/'. $job_id;
   my $int    = $output .'_int.xml';
   my $dist   = $output .'_dist.xml';

   my @run = ( '../simcamCV/calibrate', $int, $dist, (@images) );

   my $run  = join(' ', @run);

    $self->app->log->info( $run );

    my( $stdout, $stderr, @result) = Capture::Tiny::capture {
        
        `$run`
    };

    if( $stderr && $stderr !~ 'libdc1394' ){
        $self->app->log->error( "Api|get_calibrate error: $stderr" );
        return;       
    }

    # CHeck if xml files exist

    if( -e $int && -e $dist ){
        my $xs = XML::Simple->new();
            $self->app->log->info("Api|get_calibrate reading XMLs $dist and $int");
            my $d_data = $xs->XMLin($dist);
            my $f_data = $xs->XMLin($int);

            my @d_keys = keys %{$d_data};
            my @f_keys = keys %{$f_data};
            my $d_cv_data = $d_data->{$d_keys[0]}->{data};

            $d_cv_data =~ s/\s/ /g;

            my $i_cv_data = $f_data->{$f_keys[0]}->{data};

            $i_cv_data =~ s/\s/ /g;
          
            my @d_array = split(' ', $d_cv_data ); 
            my @f_array = split(' ', $i_cv_data );
           
            my $fo = { distortion => \@d_array, intrinsics => \@f_array, job_id => $job_id};

	return $fo;
     }

    else {
        $self->app->log->error( "Api|get_calibrate error: XML files not created" );    
        return; 
    }
}

sub create_image_socket {
    my $self = shift;
    $self->app->log->debug("WS Connected ");
    Mojo::IOLoop->stream($self->tx->connection)->timeout(300);
    $self->on(message => sub {
        my ($self, $msg) = @_;

        $self->send( $self->store_base64image( j($msg) ));
    
    });
}


sub run_raw_check {
   my $self = shift;
   my $image = shift;
   my $type = shift;


   if( $type && $type eq 'base64' ){
    $image = $self->store_base64image( $image ) .'_in.png'; 
   } 
    $self->app->log->info("RUINNING RUN_CHECK WITH $image");

   my $located = $self->image_location( $image );
   
   my $out = sha1_hex($located.'_check').'_check.png';

   my $run = '../simcamCV/check public/uploads/'.$located . ' public/uploads/'. $out; 

    $self->app->log->info( $run );
    my $result;
    my ($merged, @result) = Capture::Tiny::capture_merged sub {
       $result = system split(' ', $run);
    };

    if( $merged && $merged !~ 'libdc1394' ){
        $self->app->log->error( "Api|get_check error: $merged" ) if $merged;
        return;
        }

   return { result => $result, out => $out, in => $located };

}


sub check_grid_socket {
    my $self = shift;
    $self->app->log->debug("WSCHECKGREIDConnected ");
    Mojo::IOLoop->stream($self->tx->connection)->timeout(300);
    $self->on(message => sub {
        my ($self, $msg) = @_;
        my $req = j($msg);

        if( $req->{image} ) {
            $self->send( j( $self->run_raw_check( $req->{image}, $req->{type} ) ) );
        } else {
            $self->send('no image sent');
        }
    
    });
}

sub get_distort_socket {
    my $self = shift;
    $self->app->log->debug("WS Connected ");
    Mojo::IOLoop->stream($self->tx->connection)->timeout(300);
    $self->on(message => sub {
        my ($self, $msg) = @_;

        my $result = $self->run_distort( j( $msg ) );

        $self->send( j($result) );
    
    });
}

sub calibration_socket {
    my $self = shift;
    $self->app->log->debug("WS Connected ");
    Mojo::IOLoop->stream($self->tx->connection)->timeout(300);
    $self->on(message => sub {
        my ($self, $msg) = @_;

        my $result = $self->run_calibration( j( $msg ) );
        if( ref $result eq 'HASH' ) {

        $self->send( j($result) );

        } else { $self->send( "Calibration didnt happen: $result " ) };
    
    });
}
1;
