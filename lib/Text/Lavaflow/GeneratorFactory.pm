package Text::Lavaflow::GeneratorFactory;

use strict;
use warnings;

use Text::Lavaflow::Generator::Markdown;
use Text::Lavaflow::Generator::Pod;

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    my $input_format = shift;

    my $self = bless $self, $class; 

    return $self->dispatch($input_format);
}

sub dispatch {
    my $self = shift;
    my $format = shift;

    if ( $format =~ /markdown/i ) {
        return Text::Lavaflow::Generator::Markdown->new();
    }
    elsif ( $format =~ /pod/i ) {
        return Text::Lavaflow::Generator::Pod->new();
    }
    else {
        return undef;
    }
}

1;
