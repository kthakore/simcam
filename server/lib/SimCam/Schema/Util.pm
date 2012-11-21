package SimCam::Schema::Util;

sub TO_JSON {
    my $self = shift;
    my $next = shift;
    my $json_obj = Mojo::JSON->decode( $self->json_store );

    my $ref = ref $json_obj;

    my %precursor = %{$next};
    my %final_hash;

    if( $ref =~ 'HASH' || $ref =~ 'ARRAY' ) {

       %final_hash = %precursor;
       $final_hash{store} = $json_obj;

    } else {
 
       %final_hash = %precursor;
       $final_hash{store} = $self->json_store; 

    }

    return \%final_hash;
    


}
1;
