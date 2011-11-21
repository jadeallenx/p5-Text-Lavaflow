package Text::Lavaflow::Macro::SpeakerNotes;

use strict;
use warnings;

use Object::Tiny;

sub regex {
    return qr/^\.notes:\s*([^\s].*)$/;
}

sub expand {
    my $self = shift;
    my $root = shift; # should be HTML::Element object

    foreach my $elem ( $root->look_down( "_tag" => "p" ) ) {
        foreach my $content_r ( $elem->content_refs_list() ) {
            next if ref ${$content_r};
            if ( ${$content_r} =~ $self->regex() ) {
                $elem->attr( 'class' => 'notes' );
                ${$content_r} = $1;
                next;
            }

        }
    }

    return $root->as_HTML("", undef, {});
}

