
$c->{get_login_url} = sub {
	my( $session, $target ) = @_;

	# preserve CGI params
	$session->read_params;
	$target = $session->get_url(
		host => 1,
		path => "auto",
		query => 1,
	);

        my $url = URI->new( $session->get_repository->get_conf( "base_url" ) . "/shibboleth/login" );
        $url->query_form( target => "$target" );
        return "$url";
};

$c->{on_logout} = sub
{
	my( $session ) = @_;

	# remove _shibsession_ cookie
	my( $shibname, $shibvalue );
	for( $session->get_query->cookie() )
	{
		if( $_ =~ /^_shibsession/ )
		{
			$shibname = $_;
			$shibvalue = $session->get_query->cookie( $shibname );
		}
	}

	my $cookie = $session->get_query->cookie(
		-name    => $shibname,
		-path    => "/",
		-value   => "",
                -host  => $session->get_repository->get_conf("cookie_domain"),
		-expires => "-1d",
	);	
	EPrints::Apache::AnApache::header_out( 
		$session->{request},
		"Set-Cookie" => $cookie );
};
