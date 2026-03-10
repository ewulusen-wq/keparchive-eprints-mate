=pod


# Please see http://wiki.eprints.org/w/User_login.pl
#$c->{check_user_password} = sub {
#
#        my( $repo, $password, $username ) = @_;
#	print STDERR "fent bent \n"
#        return $ok ? $username : undef;
#};

=cut

$c->{check_user_password} = sub {
   my( $session, $username, $password ) = @_;
print STDERR "bejött ldap elott\n";

   # LDAP authentication for "user", "editor" and "admin" types (roles)
   use Net::LDAP; # IO::Socket::SSL also required
   use Time::Piece ();
   # LDAP tunables

   my $secusername=$username;
$username = "uid=".$username.",ou=Employees,ou=People,dc=szie,dc=hu";
print STDERR $username;
	
   
   my $ldap_host = "ldaps://192.188.242.24";
   my $base      = "dc=szie,dc=hu";
   my $groupbase = "ou=Employees,ou=People,dc=szie,dc=hu";
   my $dn        = "uid=MAT8262,ou=RoleAccounts,ou=People,dc=szie,dc=hu";
   my $ldappass   = "Asdf1234!";
     my $ldap      = Net::LDAP->new ( $ldap_host, version => 3,port =>636 );
   unless( $ldap )
   {
        print STDERR Time::Piece::localtime->strftime('[%a %b %d %H:%M:%S %Y]');
        #print STDERR " LDAP error: $@\n";
        #print  " LDAP error: $@\n";
        return 0;
   }

   # Start secure connection (not needed if using LDAPS)
 #  my $ssl = $ldap->start_tls();
  # if( $ssl->code() )
  # {
#       print STDERR Time::Piece::localtime->strftime('[%a %b %d %H:%M:%S %Y]');
#       print STDERR " LDAP SSL error: " . $ssl->error() . "\n";
#      print " LDAP SSL error: " . $ssl->error() . "\n";
#       return 0;
 #  }
   # Get password for the search-bind-account
   my $repository = $session->get_repository;
   my $id         = $repository->get_id;
    my $mesg="";
    if( $dn eq "" && $ldappass eq "" )
{
       $mesg = $ldap->bind; # anonymous bind
}
else
{
       $mesg = $ldap->bind( $dn, password => $ldappass );
}
  
   if( $mesg->code() )
   {
       print STDERR "LDAP Bind error: " . $mesg->error() ."-->".$mesg->code(). "\n";
       return 0;
   }
#print mesg->code();
   # Distinguished name (and attribues needed later on) for this user
   my $result = $ldap->search (
       base    => "$base",
       scope   => "sub",
       filter  => "(&(uid=$secusername))",
       attrs   =>  ['1.1', 'uid', 'sn','givenName', 'mail'],
       sizelimit=>1
   );
  if ( $result->code() ) {
  #
  # if we've got an error... record it
  #
  LDAPerror ( "Searching", $result );
	print $result->error();
}
 
sub LDAPerror
{
  my ($from, $mesg) = @_;
  print "Return code: ", $mesg->code;
  print "\tMessage: ", $mesg->error_name;
  print " :",          $mesg->error_text;
  print "MessageID: ", $mesg->mesg_id;
  print "\tDN: ", $mesg->dn;
 
  #---
  # Programmer note:
  #
  #  "$mesg->error" DOESN'T work!!!
  #
  #print "\tMessage: ", $mesg->error;
  #-----
}
   my $entr = $result->pop_entry;
    #print $entr."valami ez is |";
   unless( defined $entr )
   {
	#print STDERR "rossz kód ldaphozadmin".$secusername."\n"; #<---- itt dobja a hibát nem találja meg a usert az ldapba.
       # Allow local EPrints authentication for admins (accounts not found in LDAP)
       my $user = EPrints::DataObj::User::user_with_username( $session, $secusername );
       return 0 unless $user;

       my $user_type = $user->get_type;
	#print STDERR "rossz kód ldaphoz2\n";
	#print STDERR $user_type."\n";
       if( $user_type eq "admin" or $user_type eq "user")
       {
           # internal authentication for "admin" type
           return $session->get_database->valid_login( $secusername, $password );
       }
       return 0;
   }
   my $ldap_dn = $entr->dn;
   #filter the user found based on group (make sure the user is in Staff_grp group in OID)
 my $userGroup = $ldap->search (
      base    => "$groupbase",
      scope   => "sub",
     filter  => "(&(uniquemember=$ldap_dn))",
      attrs   =>  ['cn'],
      sizelimit=>1

   );
  # my $entrGroup = $userGroup->pop_entry;
  # unless( defined $entrGroup )
 # {
        # User Not in Staff group - reject login
    #    print STDERR Time::Piece::localtime->strftime('[%a %b %d %H:%M:%S %Y]');
     #  print STDERR " NOT AUTHORIZED : User $username is not a staff\n";
#	print  " NOT AUTHORIZED : User $username is not a staff\n";
#        return 0;
 #  }

   # Check password
   my $mesg2 = $ldap->bind( $ldap_dn, password => $password );
   if( $mesg2->code() )
   {
    #print STDERR "rossz kód ldaphoz";
       return 0;
   }

   # Does account already exist?
   my $user = EPrints::DataObj::User::user_with_username( $session, $secusername );
   if( !defined $user )
   {
#print STDERR $secusername;
#print STDERR "új user name $secusername!";
       # New account
       $user = EPrints::DataObj::User::create( $session, "user" );
       $user->set_value( "username", $secusername );
   }

   # Set metadata
   my $name = {};
   $name->{family} = $entr->get_value( "sn" );
   $name->{given} = $entr->get_value( "givenName" );
   $user->set_value( "name", $name );
   $user->set_value( "username", $secusername );
   $user->set_value( "email", $entr->get_value( "mail" ) );
   $user->commit();
   # print STDERR " neved: $name";	

   $ldap->unbind if $ldap;

   return 1;

}
