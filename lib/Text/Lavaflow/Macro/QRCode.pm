package Text::Lavaflow::Macro::QRCode;

use strict;
use warnings;

use Object::Tiny;
use HTML::TreeBuilder;

sub regex {
    return qr/\.qr:\s*([^\s].*)$/;
}

sub expand {
    my $self = shift;
    my $slide = shift; 

    my $root = HTML::TreeBuilder->new_from_content($slide->content())->disembowel();

    foreach my $elem ( $root->look_down( "_tag" => "p" ) ) {
        foreach my $content_r ( $elem->content_refs_list() ) {
            next if ref ${$content_r};
            if ( ${$content_r} =~ $self->regex() ) {
                my ($size, $stuff) = split /\|/, $1;
                $elem->attr( 'class' => 'qr' );
                ${$content_r} = HTML::Element->new_from_lol( [
                    'img', 
                    { 'src' => 
                        "http://chart.apis.google.com/chart?chs=$size" . "x" .
                        "$size&cht=qr&chl=$stuff&chf=bg,s,00000000&choe=UTF-8" },
                    { alt => 'QR code' },
                ] );
                next;
            }

        }
    }

    $slide->content(
        $root->as_HTML("", undef, {})
    );

    return $slide;
}

1;
