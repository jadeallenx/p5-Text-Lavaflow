package Text::Lavaflow::Generator::Pod;

use strict;
use warnings;

use Text::Markup;

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    bless { @_ }, $class;
}

sub process {
    my $self = shift;
    my $slide = shift; # Text::Lavaflow::Slide object

    my @targets;
    my $raw_content;
    foreach my $line ( $slide->raw() ) {
        next unless $line =~ /^=begin\s+(\S+)\s*$/;
        next $1 =~ /html/i;
        push @targets, $1;
        $raw_content .= $line;
    }

    my $markup = Text::Markup->new();
    my $html = $markup->parse(
            file => $raw_content,
            format => 'pod',
            options => [
                html_header => '',
                html_footer => '',
                accept_targets_as_text => @targets,
                accept_targets_as_html => (qw(html)),
            ]
    );

    return $html;
}

1;
