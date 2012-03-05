use strict;
use warnings;
use MIME::Base64; 

my $str = $ARGV[0];

$str =~ s/^.+?,//;
#print $str;

my $decoded = decode_base64($str);

use File::Slurp ;

write_file( 'foo.png', $decoded ) ;



