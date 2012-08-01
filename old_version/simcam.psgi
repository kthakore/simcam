use strict;
use warnings;
use Plack::Builder;
use lib 'lib';
use SimCam;

builder {
 enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' }
	"Plack::Middleware::ReverseProxy";
 SimCam->psgi_app;
};
