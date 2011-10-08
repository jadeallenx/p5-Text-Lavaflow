package Text::Lavaflow::Slide;

use strict;
use warnings;

use Tiny::Object::RW qw(
    raw
    input_file
    cooked
    number
    classes
    );

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    bless { @_ }, $class;

    return $self;
}

sub as_HTML {
    my $self = shift;
    
    return $self->cooked->as_HTML("", "", {});
}

1;
