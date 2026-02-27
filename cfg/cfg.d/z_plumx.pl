### Plumx Summary Page Widget
########################################################################################

# Enable the widget
$c->{plugins}->{"Screen::EPrint::Box::Plumx"}->{params}->{disable} = 0;

# Position
$c->{plugins}->{"Screen::EPrint::Box::Plumx"}->{appears}->{summary_bottom} = 25;
$c->{plugins}->{"Screen::EPrint::Box::Plumx"}->{appears}->{summary_right} = undef;

$c->{plumx}{type} = "details"; # options: 'details', 'plum-print-popup', 'plum-print-popup-badge', 'summary', 
$c->{plumx}{theme} = ""; # options: 'big-ben', 'liberty' (leave blank for default)

# popup side for plum-print-popup
#$c->{plumx}{popup} = "right"; # options: 'left', 'right', 'top', 'bottom'

# Hide PlumX content if empty
$c->{plumx}{hide} = "false";

# Hide outer EPrints box
#$c->{plumx}{style} = "/style/plumx_hide_box.css";

# Function to return id type and id.
# For supported id_types, check https://plu.mx/plum/developers/widgets#Supported-Identifier-Types
# Currently, this supports doi isbn bepress_url_id arxiv github_repo_id oclc nct_id pmid 
# slideshare_slideshow_id sourceforge_repo_id ssrn_id us_patent_publication_id 
# vimeo_video_id youtube_video_id medwave_id pitt_eprint_dscholar_id smithsonian_pddr_id 
# repo_url cabi_abstract_id ebsco_db_an_match_id elsevier_id scopus_id airiti_doc_id 
# airiti_book_id cscd_id mendeley_data_id datasearch_id 
# If an EPrints has multiple usable identifiers, the first returned value will be used.
$c->{plumx}{get_type_and_id} = sub {
        my( $eprint ) = @_;

        if( $eprint->exists_and_set( "doi" ) ){
                return( "doi", $eprint->value( "doi" ) );
        }
        if( $eprint->exists_and_set( "isbn" ) ){
                return( "isbn", $eprint->value( "isbn" ) );
        }

	# id_numbers that have 10. in them (rudimentary doi check)
        if( $eprint->exists_and_set( "id_number" ) && ( $eprint->value( "id_number" ) =~ /\b10./ ) ){	        
                return( "doi", $eprint->value( "id_number" ) );	
	}

	#other fields could be checked and returned here.
};

