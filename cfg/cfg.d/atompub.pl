# Disable the default Atom XSLT stylesheet.
$c->{plugins}{"Import::Atom XML"}{params}{disable} = 1;

# Enable our improved Atom XSLT + DC Terms stylesheet.
$c->{plugins}{"Import::Atom XML Feed"}{params}{disable} = 0;
