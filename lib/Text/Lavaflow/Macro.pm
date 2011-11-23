package Text::Lavaflow::Macro;

use strict;
use warnings;

use Module::Pluggable search_path => 'Text::Lavaflow::Macro', sub_name => 'macros';

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    my $self = bless { @_ }, $class;

    return $self;
}

sub process {
    my $self = shift;
    my $slide = shift;

    foreach my $macro ( $self->macros() ) {
        if ( $macro->can('expand') ) {
            $macro->expand($slide);
        }
        else {
            next;
        }
    }
}

1;
