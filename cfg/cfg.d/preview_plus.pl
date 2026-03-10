$c->{previews_exist} = sub
{
	my ( $eprint ) = @_;
	my $can_preview = 0;

	my @documents = $eprint->get_all_documents();

	foreach my $document (@documents)
	{

		my $thumbnail_base_path =  $document->thumbnail_path . '/';
		my @file_names = ("preview.png", "page-0.jpg", "video.flv", "audio.mp3" );

		foreach my $file (@file_names)
		{
			if( -e $thumbnail_base_path.$file ) 
			{ 
				$can_preview = 1; 
				last;
			}
		}
		if($can_preview){
			last;
		}
	}

	return $can_preview;

};

$c->{make_preview_plus} = sub
{
	my ($session, $eprint, $orientation) = @_;
	
	my $preview_container = $session->make_element("div", class=>"ep_preview_plus_container");
	$preview_container->appendChild($session->get_repository()->call("make_preview_area", $session, $eprint));
	$preview_container->appendChild($session->get_repository()->call("make_preview_controls", $session, $eprint, $orientation));
	return $preview_container;
};

$c->{make_preview_area} = sub 
{
        my ($session, $eprint) = @_;

        my $preview_area_div = $session->make_element("div", id=>"ep_preview_plus_area");

	my $load_img = $session->make_element("img", "src"=>"/images/ep_inplace_ajaxload.gif", id=>"ep_inplace_ajaxload", "alt"=>"Loading");
	$preview_area_div->appendChild($load_img);

        return $preview_area_div;

};

$c->{render_preview} = sub 
{
        my ($session, $document) = @_;

	my $user = $session->current_user();
	my $can_view = 0;
	if(defined $user)
	{
		$can_view = $document->user_can_view($user);
	}
	
	my $security = $document->get_value("security");
	
	if( $security eq "public" || $can_view )
	{

		my $eprint = $document->get_eprint;
	
		my $doc_frag = $session->make_doc_fragment();

		my $thumbnail_base_url = $eprint->get_url . 'thumbnails/' . $document->get_value( "pos" ) . '/';
		my $thumbnail_base_path =  $document->thumbnail_path . '/';

		if( -e $thumbnail_base_path."video.flv" )
		{
			my $video_link = $session->make_element("a", id=>"player", href=>$thumbnail_base_url."video.flv", style=>'display:block;width:510px;height:330px;text-align:center;margin:auto;');
			$doc_frag->appendChild($video_link);
			my $script = "flowplayer('player', '/flowplayer/flowplayer-3.1.5.swf', { clip: { autoPlay: false, autoBuffering: true } }); ";
			$doc_frag->appendChild($session->make_javascript($script));
	
		}elsif( -e $thumbnail_base_path."page-0.jpg" ){
			#get all the pages
			opendir(DIR, $thumbnail_base_path) || die "can't opendir: $!";
	                my @pages = grep { /^page.*/ && -f "$thumbnail_base_path/$_" } readdir(DIR);
			#sort the pages into order
			if(scalar @pages > 1){
				@pages = sort{
					$a =~ m/[0-9]+/;
					my $a_num = $&;

					$b =~ m/[0-9]+/;
					my $b_num = $&;

					return $a_num <=> $b_num;

				} @pages;
                	}
			
			foreach my $page (@pages){
				my $img = $session->make_element("img", class=>"ep_inplace_page", src=>$thumbnail_base_url.$page);
				$doc_frag->appendChild($img);
			}
		
		}elsif( -e $thumbnail_base_path."audio.mp3" ){
			my $preview_holder = $session->make_element("div", class=>"ep_inplace_no_preview");
                        $doc_frag->appendChild($preview_holder);
                        my $helptext = $session->make_text("This is an audio file so there is no visual preview. You can still listen to the audio file using the controls below.");
			$preview_holder->appendChild($helptext);

			my $audio_link = $session->make_element("a", id=>"player", href=>$thumbnail_base_url."audio.mp3", style=>'display:block;width:510px;height:25px;text-align:center;margin:auto;');
                        $doc_frag->appendChild($audio_link);

		}elsif( -e $thumbnail_base_path."preview.png" ){
			
			my $first_thumbnail = $document->thumbnail_url("preview");
			my $img = $session->make_element("img", src=>$first_thumbnail, alt=>"");
			$doc_frag->appendChild($img);
		}else{
			my $preview_holder = $session->make_element("div", class=>"ep_inplace_no_preview");
			$doc_frag->appendChild($preview_holder);
			my $title_el = $session->make_text($document->get_value("main"));
			$preview_holder->appendChild($title_el);
			$preview_holder->appendChild($session->make_element("br"));
	                $preview_holder->appendChild($document->render_citation("default"));
			$preview_holder->appendChild($session->make_element("br"));
			my $download_text = $session->make_text("There is no preview available for this file but you can download it.");
			$preview_holder->appendChild($download_text);
			$preview_holder->appendChild($session->make_element("br"));
			$preview_holder->appendChild($session->make_element("br"));
			my $download_link = $session->make_element("a", href=>$document->get_url());
			$preview_holder->appendChild($download_link);
			$download_link->appendChild($session->make_text("Download"));
		}

        	return($doc_frag);
	}else{
		my $preview_holder = $session->make_element("div", class=>"ep_inplace_no_preview");
		my $title_el = $session->make_text($document->get_value("main"));
		$preview_holder->appendChild($title_el);
		$preview_holder->appendChild($session->make_element("br"));
		$preview_holder->appendChild($document->render_citation("default"));
		$preview_holder->appendChild($session->make_element("br"));
		$preview_holder->appendChild($session->make_element("br"));
		$preview_holder->appendChild($session->get_repository()->call("render_request_copy", $session, $document));
		return $preview_holder;
	}
};

$c->{make_preview_controls} = sub
{
        my ($session, $eprint, $scroll_direction) = @_;
	my $controls_container = $session->make_element("div", id=>"ep_inplace_controls_container");
        my $controls_table = $session->make_element("table", id=>"ep_preview_plus_controls");
	$controls_container->appendChild($controls_table);

        my $controls_tbody;

        if($scroll_direction eq "vertical")
	{
                $controls_tbody = $session->make_element("tbody", id=>"ep_inplace_tile_container");
        }else{
                $controls_tbody = $session->make_element("tbody");
        }

        $controls_table->appendChild($controls_tbody);


        if($scroll_direction eq "vertical")
	{
        }else{
                my $table_rows = $session->get_repository()->call("build_horizontal_table",$session, $eprint);
                $controls_tbody->appendChild($table_rows);
        }

        return $controls_container;
};

$c->{build_horizontal_table} = sub
{
        my ($session, $eprint) = @_;

        my @docs = $eprint->get_all_documents();

        my $doc_frag = $session->make_doc_fragment();

        my $row = $session->make_element("tr", id=>"ep_inplace_tile_container" );

        $doc_frag->appendChild($row);

        $row->appendChild($session->make_element("td", id=>"ep_inplace_previous_button"));

        my $script_url = $session->get_repository()->get_conf("perl_url")."/get_preview_plus?docid=";

        my $count = 0;
        foreach my $doc (@docs)
        {
                my $docid = $doc->get_id();
		my $td = $session->make_element("td", class=>"ep_preview_plus_tile", onclick=>"ep_inplace_tile_click(".$count.",'".$script_url.$docid."');");
		if($count == 0)
		{
			my $script = "window.onload =  function(){
				ep_inplace_tile_click(".$count.",'".$script_url.$docid."');
			};
			";
			$td->appendChild($session->make_javascript($script));
		}
		my $tile_box = $session->make_element("div", class=>"ep_inplace_tile_container");
                $tile_box->appendChild($doc->render_citation("preview_tile"));
		$td->appendChild($tile_box);
                $row->appendChild($td);
                $count++;
        }

        $row->appendChild($session->make_element("td", id=>"ep_inplace_next_button"));

        return $doc_frag;
};
$c->{render_request_copy} = sub
{
	my ( $session, $document ) = @_;
	my $eprint = $document->get_eprint();

	my $doc_frag = $session->make_doc_fragment();

	my $has_contact_email = 0;

	if( $session->get_repository->can_call( "email_for_doc_request" ) )
	{
		if( defined( $session->get_repository->call( "email_for_doc_request", $session, $eprint ) ) )
		{
			$has_contact_email = 1;
		}
	}
	if( $has_contact_email && !$document->is_public && $eprint->get_value( "eprint_status" ) eq "archive" )
	{
		# "Request a copy" button
		my $form = $session->render_form( "get", $session->get_repository->get_conf( "perl_url" ) . "/request_doc" );
		$form->appendChild( $session->render_hidden_field( "docid", $document->get_id ) );
		$form->appendChild( $session->render_action_buttons(
			"null" => $session->phrase( "request:button" )
		) );
		$doc_frag->appendChild($form);
		
	}
	return $doc_frag;
};

