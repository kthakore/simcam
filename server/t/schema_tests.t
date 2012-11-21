use Mojo::Base -strict;

use Test::More;

use Data::Dumper;

use_ok('SimCam::Schema');

my $schema =  SimCam::Schema->connect('dbi:SQLite:database=simcam.db');

isa_ok( $schema, 'SimCam::Schema' );


my $rs_usr = $schema->resultset('Usr');
my $rs_session = $schema->resultset('Session');

my $user = $rs_usr->find({ id => 1 } );


warn Dumper $user->TO_JSON();


done_testing();
