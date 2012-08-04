package SimCam::Matlab;
use IO::File;
use Capture::Tiny qw/capture/;
use Data::Dumper;
use Devel::Peek;

sub process_ans  {
    my @result = @_;

    my $ans = '';
    my $flag = 0;

    my $ans; my $length = scalar @result; 
        my @results;

    foreach my $l (  0..$length )
    {
       my $i = $length - $l;

        my $line = $result[$i];
        unless( $line =~ /^ans/ )
        {
           push( @results,  $line );
        }
        else {
            return join(" ", reverse( @results ) );
        }
    }    
}



sub run_matlab {

    my $script = shift; 

    my $matlab = 'matlab';

    my $run = "cd /tmp; $matlab -nodesktop -nosplash -r $script";
    my $result = `$run`;

    my ( $stdout, $stderr, @result) = capture {
        `$run`;
    };

    warn 'Ans: '. process_ans( @result );
}

sub run_matlab_script {

    my $script = shift;

    my $fh = IO::File->new( "> /tmp/script.m" );

    if( defined $fh ) {
        print $fh " [ 1 1 ]\nexit";
        $fh->close;
    } 
    run_matlab( 'script' );
}

1;
