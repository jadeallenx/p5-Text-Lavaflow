use Text::Markup;
use Data::Printer;
use v5.14;
my $pod = Text::Markup->new->parse( file => 'example.pod' );
say $pod;
