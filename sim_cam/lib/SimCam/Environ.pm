package SimCam::Environ;
use Mojo::Base 'Mojolicious::Controller';
use Digest::SHA qw/sha_hex/;

sub noise {
    my $self = shift;

    $self->render({ json => {} } );
}

sub noiseid {
    my $self  = shift;
    my $alpha = $self->param('alpha');
    my $type  = $self->param('type');

    $self->render({ json => { alpha => $alpha, type => $type } } );
}

sub distort {
    my $self = shift;
    my $params = $self->req->json;

    my $t1= $patams->{t1} || 0.0;
    my $t2= $patams->{t2} || 0.0;
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

    my $dist_fh = IO::File->new("> $dist_path" );

    if( defined $dist_fh )
    {
        print $dist_fh $Distortion;
        $dist_fh->close();
    }

    my $int_fh = IO::File->new("> $int_path" );

    if( defined $int_fh )
    {
        print $int_fh $Intrinsics;
        $int_fh->close();
    }

    

}


1;
