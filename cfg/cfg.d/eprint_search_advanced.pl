
$c->{search}->{eprint} = {
    _basic => {
        fields => [ 'full_text', 'title', 'creators_name', 'abstract', 'date', 'subjects' ],
        defaults => { 'full_text' => { DESC => 1 } }
    },
    _advanced => {
        fields => [ 'full_text', 'title', 'creators_name', 'abstract', 'date', 'subjects', 'divisions', 'status', 'photographers', 'collection', 'event_location' ],
        defaults => { 'full_text' => { DESC => 1 } }
    },
    _default => {
        allow_null => 0,
        fields => [ 
            { id => 'full_text', meta_fields => [ 'documents.text', 'documents.text_l' ] },
            { id => 'title', meta_fields => [ 'title', 'title_l' ], new_row => 0 },
            { id => 'creators_name', meta_fields => [ 'creators_name', 'creators_name_l' ], new_row => 0 },
            { id => 'abstract', meta_fields => [ 'abstract', 'abstract_l' ], new_row => 0 },
            { id => 'date', meta_fields => [ 'date' ] },
            { id => 'subjects', meta_fields => [ 'subjects' ] },
            { id => 'divisions', meta_fields => [ 'divisions' ] },
            { id => 'status', meta_fields => [ 'status' ] },
            { id => 'photographers', meta_fields => [ 'photographers' ] },
            { id => 'collection', meta_fields => [ 'collection' ] },
            { id => 'event_location', meta_fields => [ 'event_location' ] },
        ],
        defaults => { 'full_text' => { DESC => 1 } },
        show_zero_results => 1,
        satisfy_all => 1,
        order_by => 'byrelevance',
        render_style => 'collapsed',
    },
};
