package Text::Lavaflow;

use strict;
use warnings;

use Object::Tiny::RW qw(
    slides
    input_filepath
    theme_filepath
    input_format
    output_format
    output_file
    input_file
    config_file
    config
    _toc
    log
    loglevel
    logfile
    theme
    );

use File::Slurp qw(read_file read_dir);
use Try::Tiny;
use Data::Printer;
use Log::Dispatch;
use Config::Tiny;
use Carp qw(confess);

use Text::Lavaflow::ParserFactory;
use Text::Lavaflow::GeneratorFactory;
use Text::Lavaflow::Slide;

=head1 NAME

Text::Lavaflow - Process text files into HTML5 slides

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Text::Lavaflow;

    my $slides = Text::Lavaflow->new(
         input_file => 'slides.md',
        output_file => 'presentation.html'
    );

=head1 METHODS

=head2 new

=cut

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    my $self = bless { @_ }, $class;

    $self->load_config() if defined $self->config_file();

    $self->log($self->start_logger()) unless defined $self->log();

    $self->read_file() if defined $self->input_file();
    $self->generate_slides() if $self->slides();

    return $self;
}

=head2 start_logger

=cut

sub start_logger {
    my $self = shift;
    my $loglevel = $self->loglevel() || "debug";
    my $logfile = $self->logfile();

    my $log;
    if ( defined $logfile ) {
        $log = [ 'File', min_level => $loglevel, filename => $logfile ];
    }
    else {
        $log = [ 'Screen', min_level => $loglevel ];
    }


    my $logger = Log::Dispatch->new( outputs => [ 
        $log
    ] );

    $logger->debug("[start_logger] Logger started");

    return $logger;
}

=head2 load_config

=cut

sub load_config {
    my $self = shift;
    my $config_file = $self->config_file();

    try {
        my $cfg = Config::Tiny->read($config_file) or die Config::Tiny->errstr();
        $self->config($cfg);
        foreach my $k ( keys %{ $cfg } ) {
            self->{$k} = $cfg->{$k};
        }
    }
    catch {
        if ( defined $self->log() ) {
            $self->log->error("[load_config] Unable to load config: $_"
        }
        else {
            confess "[load_config] Unable to load config: $_";
        }
        return undef;
    };
}

=head2 read_file

=cut

sub read_file {
    my $self = shift;
    my $input_file = $self->input_file() // $self->input_file(shift);

    try {
        die "No filename given" unless defined $input_file;
        die "$input_file does not exist" unless -e $input_file; 
        die "Insufficient permissions to read $input_file" unless -r $input_file;
        die "$input_file is a directory" if -d $input_file;


        $self->log->debug("[read_file] Reading file $input_file");
        my @lines = read_file($input_file);
        if ( $self->_parse_raw_contents(@lines) ) {
            $self->log->info("[read_file] Finished reading $input_file");
            return 1;
        }
        else {
            die "Could not parse $input_file";
        }

    }
    catch {
        $self->log->error("[read_file] Could not read file: $_");
        return undef;
    };

}

=head2 generate_slides

=cut

sub generate_slides {
    my $self = shift;

    return undef unless defined $self->slides();

    return undef unless defined $self->input_format();

    my $generator = Text::Lavaflow::GeneratorFactory->new($self->input_format());

    foreach my $slide ( @{ $self->slides() } ) {
        my $content = $generator->process($slide->raw());

        unless ( defined $content ) {
            $self->logger->warn("Could not generate cooked slide content for slide #" . $slide->number() . " in file " . $slide->input_file());
            next;
        }

        $slide->cooked($content);
    }

}

=head2 output

=cut

sub output {
    my $self = shift;

    # magic happens here
    # populate base.html with slide content
}

sub _parse_raw_contents {
    my $self = shift;
    my @lines = @_;

    my $input_file = $self->input_file();
    my $input_format = $self->input_format() // $self->input_format( $self->_guess_format() );

    try {
        die "Could not determine input format for $input_file" unless defined $input_format;
        my $parser = Text::Lavaflow::ParserFactory->new($input_format);
        die "Couldn't get a parser for format $input_format" unless defined $parser;
        my $raw_content_aref = $parser->parse(@lines);
        if ( scalar @$raw_contant_aref ) {
            my $cnt = 0;
            foreach my $raw_chunk ( @{ $raw_content_aref } ) {
                $self->log->debug("[_parse_raw_content] Building new Text::Lavaflow::Slide object: $cnt");
                push @{ $self->{'slides'} }, Text::Lavaflow::Slide->new(
                    raw => $raw_chunk,
                    input_file => $input_file,
                    number => $cnt + 1,
                    );
                $cnt++;
            }
            $self->log->info("[_parse_raw_content] Added all raw content from $input_file");
            return 1;
        }
        else {
            die "Could not find any content in format $input_format";
        }
    }
    catch {
        $self->log->error("[_parse_raw_contents] Couldn't process $input_file: $_";
        return undef;
    };
}

sub _guess_format {
    my $self = shift;
    my $input_file = $self->input_file();

    my $endings->{'markdown'} = [ qr{\.md$}, qr{\.markdown$} ];
    my $endings->{'pod'} = [ qr{\.pm$}, qr{\.pod$}, qr{\.pl} ];

    try {
        foreach my $format ( keys %{ $endings } ) {
            foreach my $regex ( @{ $endings->{$format} } ) {
                return $format if $input_file =~ $regex;
            }
        }

        die "No file endings matched known formats";

    }
    catch {
        $self->log->error("[_guess_format] Couldn't guess format for $input_file: $_";
        return undef;
    };
}

=head1 AUTHOR

Mark Allen, C<< <mrallen1 at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-text-lavaflow at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Text-Lavaflow>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Text::Lavaflow


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Text-Lavaflow>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Text-Lavaflow>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Text-Lavaflow>

=item * Search CPAN

L<http://metacpan.org/Text-Lavaflow/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mark Allen.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Text::Lavaflow
