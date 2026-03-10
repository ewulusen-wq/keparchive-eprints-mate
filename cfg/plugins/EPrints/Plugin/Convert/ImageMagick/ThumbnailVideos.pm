package EPrints::Plugin::Convert::ImageMagick::ThumbnailVideos;

=pod

=head1 NAME

EPrints::Plugin::Convert::DocPDF - Convert documents to plain-text

=head1 DESCRIPTION

Uses the file extension to determine file type.

=cut

use strict;
use warnings;

use Carp;
use English;
use Unicode::String;
use EPrints;
use Data::Dumper;

use EPrints::Plugin::Convert;
our @ISA = qw/ EPrints::Plugin::Convert /;

our (%FORMATS, @ORDERED, %FORMATS_PREF);
@ORDERED = %FORMATS = qw(
3gp video/avi
3gp2 video/avi
asf video/x-ms-asf
avi video/x-msvideo
m4v video/mp4
mov video/quicktime
mp4 video/mp4
mpeg video/mpeg
mpg video/mpeg
mpe video/mpeg
rm application/vnd.rn-realmedia
wmv audio/x-ms-wmv
);
# formats pref maps mime type to file suffix. Last suffix
# in the list is used.
for(my $i = 0; $i < @ORDERED; $i+=2)
{
	$FORMATS_PREF{$ORDERED[$i+1]} = $ORDERED[$i];
}
our $EXTENSIONS_RE = join '|', keys %FORMATS;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );

	$self->{name} = "thumbnail_video";
	$self->{visible} = "all";

	return $self;
}

sub can_convert
{
	my ($plugin, $doc) = @_;

	my $mimetype = 'video/x-flv';

	my %types;

	# Get the main file name
	my $fn = $doc->get_main() or return ();

	if( $fn =~ /\.($EXTENSIONS_RE)$/oi ) 
	{
		$types{"thumbnail_small"} = { plugin => $plugin, };
		$types{"thumbnail_medium"} = { plugin => $plugin, };
		$types{"thumbnail_preview"} = { plugin => $plugin, };
	}

	return %types;
}

sub export
{
	my ( $plugin, $dir, $doc, $type ) = @_;

	my $src = $doc->local_path . '/' . $doc->get_main;
	
	return () unless $plugin->get_repository->can_execute( "convert" );

	my $convert = $plugin->get_repository->get_conf( 'executables', 'convert' );

	$type =~ m/^thumbnail_(.*)$/;
	my $size = $1;
	return () unless defined $size;
	my $geom = { small=>"66x50", medium=>"200x150",preview=>"600x600" }->{$size};
	return () unless defined $geom;
	
	my $fn = "$size.png";

	system("ffmpeg", "-ss", "00:00:04", "-vframes", "1", "-i", $src, $dir.'/video%d.png');
	
	if(! -e $dir."/".'video1.png'){
		$plugin->get_repository->log( "Failed to take a slice from the video in document ".$doc->get_id());
		return();
	}

	system($convert, "-size", $geom.">", $dir."/".'video1.png' , "-resize", $geom.">", $dir."/".$fn);

	unless( -e "$dir/$fn" ) {
		return ();
	}
	EPrints::Utils::chown_for_eprints( "$dir/$fn" );
	
	return ($fn);

}



1;
