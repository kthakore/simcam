use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
        VERSION   => '0.01',
        PREREQ_PM => {
        'Mojolicious' => '3.85',
        'Digest::SHA' =>  0,
        'MIME::Base64' => 0,
        'File::Slurp'  => 0,
        'Capture::Tiny' => 0

        },
        test      => {TESTS => 't/*.t'}
                                   );
