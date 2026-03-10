#default install location for redhat
#$c->{office_path} = "/opt/openoffice.org3/";

#default install location for ubuntu
$c->{office_path} = "/usr/bin/openoffice/";

$c->{office_program_path} = $c->{office_path}."program/";

$c->{open_office_name} = "soffice.bin";

$c->{open_office_exe} = $c->{office_program_path}.$c->{open_office_name};

#$c->{python_exe} = $c->{office_program_path}."python";
$c->{python_exe} = "/usr/bin/python";

$c->{converter_exe} = $c->{archiveroot}."/bin/DocumentConverter.py";
