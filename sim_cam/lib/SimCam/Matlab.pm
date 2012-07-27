package SimCam::Matlab;
use IO::File;

sub run_matlab {

    my $script = shift; 

    my $matlab = 'matlab';

    my $run = "cd /tmp; $matlab -nodesktop -nosplash -r $script";
    warn $run;

    my $result = `$run`;

    warn $foo;    
}

sub run_matlab_script {

    my $script = shift;

    my $fh = IO::File->new( "> /tmp/script.m" );

    if( defined $fh ) {
        print $fh " 1 + 1\nexit";
        $fh->close;
    } 
    run_matlab( 'script' );
}

1;
