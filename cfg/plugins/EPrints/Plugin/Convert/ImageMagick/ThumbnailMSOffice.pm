package EPrints::Plugin::Convert::ImageMagick::ThumbnailMSOffice;

=pod

=head1 NAME

EPrints::Plugin::Convert::ImageMagick::ThumbnailMSOffice

=cut

use strict;
use warnings;

use Carp;

use EPrints::Plugin::Convert;
our @ISA = qw/ EPrints::Plugin::Convert /;

our (%FORMATS, @ORDERED, %FORMATS_PREF);
@ORDERED = %FORMATS = qw(
doc application/msword
ppt application/vnd.ms-powerpoint
pps application/vnd.ms-powerpoint
xls application/vnd.ms-excel
docx application/msword
pptx application/vnd.ms-powerpoint
xlsx application/vnd.ms-excel
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

	$self->{name} = "Thumbnail MSOffice Documents";
	$self->{visible} = "all";

	return $self;
}

sub can_convert
{
	my ($plugin, $doc) = @_;

	my $convert = $plugin->get_repository->get_conf( 'executables', 'convert' ) or return ();
	
	return unless $plugin->get_repository->get_conf('open_office_exe');	
	
	return unless $plugin->get_repository()->get_conf("python_exe");

	my %types;

	# Get the main file name
	my $fn = $doc->get_main() or return ();

	if( $fn =~ /\.($EXTENSIONS_RE)$/oi ) 
	{
                $types{"thumbnail_preview"} = { plugin => $plugin, };
	}
	return %types;
}

sub export
{

	my ( $plugin, $dir, $doc, $type ) = @_;
	
	my $office_name = $plugin->get_repository()->get_conf("open_office_name");

	my $office_service = `ps -e |grep $office_name `;

	if(!$office_service){
		$plugin->get_repository()->log( "No open office service found, starting open office. - converting ".$doc->get_id());
		
		my $office_bin = $plugin->get_repository->get_conf('open_office_exe');	

		system($office_bin.' "-accept=socket,host=localhost,port=8100;urp;StarOffice.ServiceManager" -norestore -nofirststartwizard -nologo -headless &');

		sleep(6);

		if( `ps -e |grep $office_name ` ){
			$plugin->get_repository()->log("Open Office started successfully");
		}else{
			$plugin->get_repository()->log("Open Office failed to start. Exiting...");
			return();
		}
	}
	$ENV{"PYTHONPATH"} = $plugin->get_repository->get_conf('office_program_path');

	my $python = $plugin->get_repository()->get_conf("python_exe");
	my $mso_converter = $plugin->get_repository()->get_conf('converter_exe');


	my $fn = $doc->get_main;

	my $file = $doc->local_path."/".$fn;
	my $src = $file;
	my $pdf = $dir.'/'."temp.pdf";
	#give the file a tempname so we know it has no bad characters
        if( $fn =~ m/^(.*)\.([^.]+)$/ )
        {
		$src = $dir.'/'.'temp.'.$2;
		system("cp", $file, $src );
	}
	
	system($python, $mso_converter, $src, $pdf);
	
	unless(-e $pdf)
	{
		$plugin->get_repository()->log("[ThumbnailMSOffice ERROR] the PDF was not created for docid = ".$doc->get_id);
		return ();
	}

	my $convert = $plugin->get_repository->get_conf( 'executables', 'convert' ) or return ();

	$src = $pdf;

	unless( -s $src )
	{
		$plugin->get_repository()->log("The pdf created for doc ".$doc->get_id()." is a zero byte file an so cannot be converted.");
		return ();
	}


        $type =~ m/^thumbnail_(.*)$/;
        my $size = $1;
        return () unless defined $size;

        my $geom = { small=>"66x50", medium=>"200x150",preview=>"600x1200" }->{$1};

        return () unless defined $geom;

        my $out_fn = "$size.png";

	#'system($convert, "-size","$geom>", $pdf."[0]", '-resize', "$geom>", $dir . '/' . $out_fn);
	system($convert, "-size","$geom>", $pdf, '-resize', "$geom>", $dir . '/' . "page.jpg");


#read all the files produced by image magic into an array

	my $page = 'page-0.jpg';
	if(!-e $dir.'/'.$page){
		$page = 'page.jpg';	
	}
	
	system($convert, "-size","66x50>", $dir.'/'.$page, '-resize', "66x50>", $dir . '/' . "small.png");
	
	system("cp", $dir.'/'.$page, $dir.'/'."preview.png");

	unless( -e "$dir/$out_fn" ) {
		return ();
	}

	EPrints::Utils::chown_for_eprints( "$dir/small.png" );
	
	return();
}

1;
