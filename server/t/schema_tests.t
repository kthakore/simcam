use Mojo::Base -strict;

use Test::More;

use Data::Dumper;

use Mojo::JSON;

use_ok('SimCam::Schema');

my $schema =  SimCam::Schema->connect('dbi:SQLite:database=simcam.db');

isa_ok( $schema, 'SimCam::Schema' );


my $rs_usr = $schema->resultset('Usr');
my $rs_session = $schema->resultset('Session');

my $user = $rs_usr->create( {
        email => lc 'kthakore@uwo.ca',
        type  => 'SH',
        apikey => '123as2vq2',
        json_store => Mojo::JSON->encode( { test => 1 } )
    });


my $u_json = $user->TO_JSON();

is_deeply( $u_json->{store}, {test => 1 } );

 $user = $rs_usr->create( {
        email => lc 'kthakore@uwo.ca',
        type  => 'SH',
        apikey => '123as2vq2',
        json_store => Mojo::JSON->encode( [1, 2, 3 ] )
    });


$u_json = $user->TO_JSON();

is_deeply( $u_json->{store}, [1, 2, 3] );

 $user = $rs_usr->create( {
        email => lc 'kthakore@uwo.ca',
        type  => 'SH',
        apikey => '123as2vq2',
        json_store => 'Cat'
    });


$u_json = $user->TO_JSON();

is( $u_json->{store}, 'Cat' );

 $user = $rs_usr->create( {
        email => lc 'kthakore@uwo.ca',
        type  => 'SH',
        apikey => '123as2vq2'
    });


$u_json = $user->TO_JSON();

is( $u_json->{store}, undef );
 $user = $rs_usr->create( {
        email => lc 'kthakore@uwo.ca',
        type  => 'SH',
        apikey => '123as2vq2',
        json_store => '{"as": a}'
    });


$u_json = $user->TO_JSON();

is( $u_json->{store}, '{"as": a}' );


$rs_usr->search({
    email => 'kthakore@uwo.ca'
})->delete();


### Count function
 $user = $rs_usr->create( {
        email => lc 'kthakore@uwo.ca',
        type  => 'SH',
        apikey => '123as2vq2',
        json_store => '{"as": a}'
    });
is ( $rs_usr->count({
    type => 'D' 
}), 0 );
is ( $rs_usr->count({
    type => 'S' 
}), 0 );
is ( $rs_usr->count({
    type => 'SH' 
}), 1 );



$rs_usr->search({
    email => 'kthakore@uwo.ca'
})->delete();

done_testing();
