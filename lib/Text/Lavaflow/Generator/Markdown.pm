package Text::Lavaflow::Generator::Markdown;

use strict;
use warnings;

use Text::Markup;

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    bless { @_ }, $class;
}

sub process {
    my $self = shift;
    my $slide = shift; # Text::Lavaflow::Slide object

    my $markup = Text::Markup->new();

    my $html = $markup->parse( 
            file => $slide->raw(),
            format => 'markdown',
    );

    return $html;
}

1;
