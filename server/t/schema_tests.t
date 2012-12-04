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
        json_store => Mojo::JSON->encode( { test => 1 } )
    });


my $u_json = $user->TO_JSON();

is_deeply( $u_json->{store}, {test => 1 } );

 $user = $rs_usr->create( {
        email => lc 'kthakore@uwo.ca',
        type  => 'SH',
         json_store => Mojo::JSON->encode( [1, 2, 3 ] )
    });


$u_json = $user->TO_JSON();

is_deeply( $u_json->{store}, [1, 2, 3] );

 $user = $rs_usr->create( {
        email => lc 'kthakore@uwo.ca',
        type  => 'SH',
        json_store => 'Cat'
    });


$u_json = $user->TO_JSON();

is( $u_json->{store}, 'Cat' );

 $user = $rs_usr->create( {
        email => lc 'kthakore@uwo.ca',
        type  => 'SH',
    });


$u_json = $user->TO_JSON();

is( $u_json->{store}, undef );
 $user = $rs_usr->create( {
        email => lc 'kthakore@uwo.ca',
        type  => 'SH',
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

my @users = ();

foreach my $i (0..59) {
        my $rs_usr = $schema->resultset('Usr');

        my $type;

        my $d_types =  $rs_usr->count({
            type => 'D' 
        });
        my $s_types =  $rs_usr->count({
            type => 'S' 
        });
        my $sh_types =  $rs_usr->count({
            type => 'SH' 
        });

        warn "Ds: $d_types, Ss: $s_types, SHs = $sh_types";
    
        if ( $d_types < $s_types || $d_types < $sh_types  ) {
            $type = 'D';
        } elsif ( $s_types < $d_types || $s_types < $sh_types ) {
            $type = 'S';
        } elsif ( $sh_types < $d_types || $sh_types > $s_types ) {
            $type = 'SH';
        } else {
            my @types = ( 'SH', 'S', 'D' ); 
            $type = $types[ rand @types ];
        }

        my $u = $rs_usr->create( {
            email => $i.'@foo.com',
            type => $type,
            current_session => 0,
            json_store => '{}'
        } );

    warn "$i and ".$u->type;

    push @users, $u

}


foreach my $u( @users ) {

    $u->delete();
    }

$rs_usr->search({
    email => 'kthakore@uwo.ca'
})->delete();

done_testing();
