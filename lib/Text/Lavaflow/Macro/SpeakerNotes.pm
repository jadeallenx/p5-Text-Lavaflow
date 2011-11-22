package Text::Lavaflow::Macro::SpeakerNotes;

use strict;
use warnings;

use Object::Tiny;
use HTML::TreeBuilder;

sub regex {
    return qr/^\.notes:\s*([^\s].*)$/;
}

sub expand {
    my $self = shift;
    my $slide = shift; 

    my $root = HTML::TreeBuilder->new_from_content($slide->cooked())->disembowel();

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

    $slide->cooked(
        $root->as_HTML("", undef, {})
    );

    return $slide;

}

1;
