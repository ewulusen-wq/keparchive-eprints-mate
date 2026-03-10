$c->{search}->{advanced} ={
        search_fields => [
                { meta_fields => [ $EPrints::Utils::FULLTEXT ] },
                { meta_fields => [ "title" ] },
                { meta_fields => [ "creators_name" ] },
                { meta_fields => [ "creators_id" ] },
                { meta_fields => [ "abstract" ] },
                { meta_fields => [ "keywords" ] },
                { meta_fields => [ "subjects" ] },
				
                { meta_fields => [ "divisions" ] },

                { meta_fields => [ "type" ] },
                { meta_fields => [ "publisher" ] },
                { meta_fields => [ "department" ] },
                { meta_fields => [ "editors_name" ] },
                { meta_fields => [ "ispublished" ] },
                { meta_fields => [ "refereed" ] },
                { meta_fields => [ "publication" ] },
                { meta_fields => [ "date" ] }
        ],
        preamble_phrase => "cgi/advsearch:preamble",
        title_phrase => "cgi/advsearch:adv_search",
        citation => "result",
        page_size => 20,
        order_methods => {
                "byyear"         => "-date/creators_name/title",
                "byyearoldest"   => "date/creators_name/title",
                "byname"         => "creators_name/-date/title",
                "bytitle"        => "title/creators_name/-date"
        },
        default_order => "byyear",
};