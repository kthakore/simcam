# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'SimCamCV' ); }

my $object = SimCamCV->new ();
isa_ok ($object, 'SimCamCV');


