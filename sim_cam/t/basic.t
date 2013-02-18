use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('SimCam');
$t->get_ok('/')->status_is(200)->content_like(qr/Welcome to SimCam/i);

done_testing();
