package SimCam::Controller::Root;
use Moose;
use namespace::autoclean;
use MIME::Base64;
use File::Slurp;
use JSON;

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

=head2 prototype


=cut
sub prototype :Path('prototype') :Args(0) {
   my ( $self, $c ) = @_;

}
sub curve :Path('curve') :Args(0) {
   my ( $self, $c ) = @_;

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


        push @{$c->session->{'images'}}, $file_loc; 
 
        my $reply = { mssg => "Made '.$file_loc.'", images => $c->session->{'images'} };

        

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
