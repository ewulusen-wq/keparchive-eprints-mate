# Configuration required to manage users who can login / be imported to the repository.
 
 $c->{ldap_hostname} = "ldaps://192.188.242.24";

 # Leave empty for anonymous bind to LDAP
 $c->{ldap_bind_username} = "uid=MAT8262,ou=RoleAccounts,ou=People,dc=szie,dc=hu";
 $c->{ldap_bind_password} = "Asdf1234!";

 # Typically used in bin/update_users
 #$c->{ldap_import_base} = "ou=Employees,ou=People,dc=szie,dc=hu"; 
$c->{ldap_import_base} = "dc=szie,dc=hu";
 $c->{ldap_import_filter} = "(&(objectClass=person)(OU=People,DC=szie,dc=hu))";

 # Typically used in cfg/cfg.d/user_login.pl
 $c->{ldap_login_base} = $c->{ldap_import_base};
 $c->{ldap_login_filter} = "(&(objectClass=person)(OU=People,DC=szie,dc=hu))";