package SimCam::Controller::Root;
use Moose;
use namespace::autoclean;
use MIME::Base64;
use File::Slurp;
use JSON;
use XML::Simple;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

SimCam::Controller::Root - Root Controller for SimCam

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}

sub create_camera :Path('create_camera') :Args(0) {
    my ( $self, $c ) = @_;


}

=head2 prototype


=cut
sub prototype :Path('prototype') :Args(0) {
   my ( $self, $c ) = @_;

}
sub curve :Path('curve') :Args(0) {
   my ( $self, $c ) = @_;

}

sub calibrate :Path('calibrate') :Args(0) {
    my( $self, $c ) = @_;

    warn $#{$c->session->{'checked_images'}};
    if ( !exists $c->session->{'checked_images'} || $#{$c->session->{'checked_images'}} < 1 )
    {
        $c->response->status(400); 
        $c->response->body( '{message: "Need at least 2 found pattern images to calibrate"}' );
 
    }
    else {
        my @run = ('simcamCV/calibrate', @{$c->session->{'checked_images'}} );

        my $status = system @run;

        if( $status == 256 )
        {
            my $xs = XML::Simple->new();
            my $d_data = $xs->XMLin("/tmp/Distortion.xml");
            my $f_data = $xs->XMLin("/tmp/Intrinsics.xml");


            my $d_cv_data = $d_data->{Distortion}->{data};

            $d_cv_data =~ s/\s/ /g;

            my $i_cv_data = $f_data->{Intrinsics}->{data};

            $i_cv_data =~ s/\s/ /g;
          
            my @d_array = split(' ', $d_cv_data ); 
            my @f_array = split(' ', $i_cv_data );
            
            my $d = JSON::encode_json( \@d_array );
            my $f = JSON::encode_json( \@f_array );      
     
            my $fo = '{ "distortion" : '.$d. ', "intrinsics" : '.$f.' }';
            $c->response->body( $fo );

        }
        else
        {
            $c->response->status(400); 
            $c->response->body( '{message: "Couldn\'t calibrate"}' );

        }
    }

}

sub capture_images :Path('capture_images') :Args(0) {
    my( $self, $c ) = @_;

    my $uri = $c->req->param('uri');

    $uri =~ s/(^.+?,)//; 

    if( $1 )
    {

        my $d = decode_base64($uri);
        my $file_name = time; 
        my $file_loc = '/tmp/'.$file_name.'.png';
        write_file( $file_loc , $d );

        my $found = system './simcamCV/check', $file_loc;
        push @{$c->session->{'images'}}, $file_loc; 
   
          my $reply = { mssg => "Made '.$file_loc.'", images => $c->session->{'images'}};
     
        if( $found )
        {
          
            my $base64 = 'data:image/png;base64,';
             open(my $FILE, '/tmp/found.png') or die "$!";while (read($FILE, my $buf, 60*57)) { $base64 .= encode_base64($buf);}

            $reply->{found} = $base64;
            push @{$c->session->{'checked_images'}}, $file_loc; 

            $reply->{total_found} = $c->session->{'checked_images'};
        } 
    

        $c->response->body( encode_json( $reply ) );

    }
    else
    {
       $c->response->body('{ "mssg": "Didn\'t work for '.$1.': '.$uri.'"}' );
    }
    

}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Kartik Thakore,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
