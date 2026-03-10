package EPrints::Plugin::ScriptAddin;

use strict;

our @ISA = qw/ EPrints::Plugin /;

package EPrints::Script::Compiled;

sub run_icon
{
	my( $self, $state, $doc, $preview, $new_window ) = @_;

	if( !defined $doc->[0] || ref($doc->[0]) ne "EPrints::DataObj::Document" )
	{
		$self->runtime_error( "Can only call thumbnail_url() on document objects not ".
			ref($doc->[0]) );
	}

	return [ $doc->[0]->render_icon_link( preview=>$preview->[0], new_window=>$new_window->[0] ), "XHTML" ];
}

sub run_url
{
	my( $self, $state, $object ) = @_;

	if( !defined $object->[0] || ref($object->[0])!~m/^EPrints::DataObj::/ )
	{
		$self->runtime_error( "can't call url() on non-data objects." );
	}

	return [ $object->[0]->get_url, "STRING" ];
}

sub run_thumbnail_url
{
	my( $self, $state, $doc, $size ) = @_;

	if( !defined $doc->[0] || ref($doc->[0]) ne "EPrints::DataObj::Document" )
	{
		$self->runtime_error( "Can only call thumbnail_url() on document objects not ".
			ref($doc->[0]) );
	}

	return [ $doc->[0]->thumbnail_url( $size->[0] ), "STRING" ];
}

sub run_icon_url
{
	my( $self, $state, $doc, $size ) = @_;

	if( !defined $doc->[0] || ref($doc->[0]) ne "EPrints::DataObj::Document" )
	{
		$self->runtime_error( "Can only call thumbnail_url() on document objects not ".
			ref($doc->[0]) );
	}

	return [ $doc->[0]->icon_url( ), "STRING" ];
}
