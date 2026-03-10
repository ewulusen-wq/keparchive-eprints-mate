$c->add_dataset_field('eprint',
{
	name => 'separat_type',
	type => 'set',
    required=>1,
	options => [qw(
		scientific
		dissemination
		educational
		public 
		art
		non-classified
	)],
	input_style => 'medium',
},
{
	name => 'related_url2',
	type => 'compound',
	multiple => 1,
	render_value => 'EPrints::Extras::render_related_url',
	fields => [
		{
			sub_name => 'url',
			type => 'url',
			input_cols => 40,
		},
		{
			sub_name => 'type',
			type => 'text',
			input_cols=>40,
			allow_null=>0,
		}
	],
	input_boxes => 2,
	input_ordered => 0,
},

),