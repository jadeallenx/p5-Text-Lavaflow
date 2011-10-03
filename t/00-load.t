#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Text::Lavaflow' ) || print "Bail out!\n";
}

diag( "Testing Text::Lavaflow $Text::Lavaflow::VERSION, Perl $], $^X" );
