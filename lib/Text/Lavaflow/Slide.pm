package Text::Lavaflow::Slide;

use strict;
use warnings;

use Tiny::Object::RW qw(
    raw_format
    raw
    input_file
    cooked_format
    cooked
    slide_number
    classes
    );

use Try::Tiny;

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
