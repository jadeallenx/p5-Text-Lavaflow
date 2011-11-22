package Text::Lavaflow::Macro::CodeHighlighting;

use strict;
use warnings;

use Object::Tiny;
use HTML::TreeBuilder;

sub expand {
    my $self = shift;
    my $slide = shift; # should be HTML::Element object

    my $root = HTML::TreeBuilder->new_from_content($slide->cooked())->disembowel();

    foreach my $elem ( $root->look_down( "_tag" => "code" ) ) {
        foreach my $content_r ( $elem->content_refs_list() ) {
            next if ref ${$content_r};
            if ( ${$content_r} =~ s/^!(\w+)$//xms ) {
                $elem->attr( 'class' => $1 );
                last;

            }
        }
    }

    $slide->cooked(
        $root->as_HTML("", undef, {})
    );

    return $slide;

}

1;
