package Text::Lavaflow::Parser::Pod;

use strict;
use warnings;

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    bless { @_ }, $class;
}

sub slide_seperator {
    my $self = shift;
    my $seperator = shift;

    if ( defined $seperator ) { 
        $self->{seperator} = $seperator
    }

    return $self->{seperator};
}

sub parse {
    my $self = shift;
    my @lines = @_;

    my @chunks;
    my @tmp;

    my $seperator = $self->slide_seperator() // "=head1";

    foreach my $line ( @lines ) {
        # Focus on Pod::S5 conversion so =head1 marks the start
        # of a new slide by default.

        if ( $line =~ /^$seperator$/ ) {
            delete $tmp[$#tmp] if ( $tmp[$#tmp] =~ /^\s+$/ ); 
            while ( $tmp[0] =~ /^\s+$/ ) {
                shift @tmp;
            }
            push @chunks, @tmp;
            @tmp = ();
            # Put the seperator onto the next slide.
            push @tmp, $line;
            next;
        }
        else {
            push @tmp, $line;
        }
    }

    # Check to see if there's still content after last break
    if ( $#tmp > 0 ) {
        delete $tmp[$#tmp] if ( $tmp[$#tmp] =~ /^\s+$/ ); 
        while ( $tmp[0] =~ /^\s+$/ ) {
            shift @tmp;
        }
        push @chunks, @tmp;
    }

    return [ @chunks ];
}

1;
