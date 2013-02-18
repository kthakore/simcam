use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('SimCam');

#Not logged in!
my $session_0 = $t->get_ok('/session/0')->status_is(302);

#Log in 

my $logged_in = $t->get_ok('/')->post_ok('/login' => form => { email => 'asdad' } )->status_is(302);

$logged_in->get_ok('/session/0');

done_testing();
