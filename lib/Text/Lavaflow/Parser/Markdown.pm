package Text::Lavaflow::Parser::Markdown;

use strict;
use warnings;

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    bless { @_ }, $class;
}

sub parse {
    my $self = shift;
    my @lines = @_;

    my @chunks;
    my @tmp;

    foreach my $line ( @lines ) {
        # Markdown line breaks are ---, ***, or ___ with or without 
        # spaces between them
        #
        # Regex copied right out of Markdown.pl 1.0.2

        if ( $line =~ /^[ ]{0,2}([ ]?\*[ ]?){3,}[ \t]*$/ || 
             $line =~ /^[ ]{0,2}([ ]? -[ ]?){3,}[ \t]*$/ || 
             $line =~ /^[ ]{0,2}([ ]? _[ ]?){3,}[ \t]*$/) {
            delete $tmp[$#tmp] if ( $tmp[$#tmp] =~ /^\s+$/ ); 
            while ( $tmp[0] =~ /^\s+$/ ) {
                shift @tmp;
            }
            push @chunks, @tmp;
            @tmp = ();
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
