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
}
),