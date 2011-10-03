#!/usr/bin/env perl

use v5.14;

use strict;
use warnings;

use File::Slurp qw(read_file);
use Data::Printer;
use Text::Markdown;
use HTML::TreeBuilder;

my @lines = read_file($ARGV[0], chomp => 1)  or die;

my @slides;
my @tmp;

foreach my $line ( @lines ) {

    if ( $line =~ /^---$/ ) {
        #delete $tmp[$#tmp] if ( $tmp[$#tmp] =~ /^\s+$/ ); 
        delete $tmp[$#tmp] if ( $tmp[$#tmp] eq "" ); 
        #shift @tmp if ( $tmp[0] =~ /^\s+$/ );
        shift @tmp if ( $tmp[0] eq "" );
        push @slides, join "\n", @tmp;
        @tmp = ();
        next;
    }
    else {
        push @tmp, $line;
    }
}

delete $tmp[$#tmp] if ( $tmp[$#tmp] eq "" ); 
shift @tmp if ( $tmp[0] eq "" );
push @slides, join "\n", @tmp;


my $md = Text::Markdown->new();

my $html_fragment = $md->markdown($slides[5]);
 
my $root = HTML::TreeBuilder->new_from_content($html_fragment)->disembowel();

foreach my $elem ( $root->look_down( "_tag" => "p" ) ) {
    foreach my $content_r ( $elem->content_refs_list() ) {
        next if ref ${$content_r};
        if ( ${$content_r} =~ /^\.notes:\s*([^\s].*)$/ ) {
            $elem->attr( 'class' => 'notes' );
            ${$content_r} = $1;
            next;
        }
        elsif ( ${$content_r} =~ /^\.fx:\s*([^\s].*)$/ ) {
            my @classes = split / /, $1;
            $elem->delete;
            next;
        }
        elsif ( ${$content_r} =~ /\.qr:\s*([^\s].*)$/ ) {
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

foreach my $elem ( $root->look_down( "_tag" => "code" ) ) {
    foreach my $content_r ( $elem->content_refs_list() ) {
        next if ref ${$content_r};
        if ( ${$content_r} =~ s/^!(\w+)$//xms ) {
            $elem->attr( 'class' => $1 );
            last;
        }
    }
}

say $root->as_HTML("", "\t", {});
