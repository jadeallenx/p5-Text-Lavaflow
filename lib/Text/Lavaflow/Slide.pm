package Text::Lavaflow::Slide;

use strict;
use warnings;

use Object::Tiny::RW qw(
    raw
    input_file
    cooked
    number
    );

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    bless { @_ }, $class;

    return $self;
}

sub classes {
    my $self = shift;

    if ( @_ ) {
        push @{ $self->{'classes'} }, @_;
    }
    
    return defined $self->{'classes'} ? : @{$self->{'classes'}} : ();
}

sub content {
    my $self = shift;
    
    return $self->cooked();
}

1;
