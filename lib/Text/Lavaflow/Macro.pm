package Text::Lavaflow::Macro;

use strict;
use warnings;

use Module:Pluggable search_path => 'Text::Lavaflow::Macro' sub_name => 'macros';

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    bless { @_ }, $class;

    return $self;
}

sub examine {
    my $self = shift;
    my $content = shift;

    my $root = HTML::TreeBuilder->new_from_content($content)->disembowel();

    foreach my $macro ( $self->macros() ) {
        if ( $macro->can('expand') ) {
            $content = $macro->expand($root);
        }
        else {
            next;
        }
    }

    return $content;
}

1;
