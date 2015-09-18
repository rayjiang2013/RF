##
## [::my_codegen cget -command-name]
##
use File::Spec;
use File::Basename;
use Tcl;
use warnings;
use strict;
use ixiatcl;

package ixiahltesmc;
##
my @cmd_spec_list = (
    ['esmc_config', 'status', 'log', 'handles'],
    ['esmc_control', 'status', 'log', '*'],
    ['esmc_stats', 'status', 'log', '*'],
);
ixiatcl::source(File::Spec->join(
    File::Spec->rel2abs(File::Basename::dirname(__FILE__)), 
    '00_ixia_hag.x.tcl'
));
eval {
    ixiatcl::source(File::Spec->join(
        File::Spec->rel2abs(File::Basename::dirname(__FILE__)),
        'esmc.x.tcl'
    ));
}; 
if ($@) {
  Carp::confess("esmc.x.tcl:
----
".ixiatcl::errorInfo()."
------
");
}

print("using " . File::Spec->join(
 File::Spec->rel2abs(File::Basename::dirname(__FILE__)), 'esmc.x.tcl') . "
");

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for (my $i=0; $i<=$#cmd_spec_list; $i++) {
    my $cmd = $cmd_spec_list[$i][0];
    # key that holds the status
    my $statusk = $cmd_spec_list[$i][1];
    # key that holds the error msg (if status was not ::SUCCESS)
    my $logk = $cmd_spec_list[$i][2];
    # key that holds the value to return
    my $returnk = $cmd_spec_list[$i][3];
    my $hcmd = '::ixiahlt::'.$cmd;
    if (!defined(&$hcmd)) {
        my $ss =  '
            sub '.$hcmd.' {
                my $klv = "";
                eval {
                    $klv = ixiatcl::_xinvoke("::ixia::'.$cmd.'", ixiatcl::_flatten(@_));
                } or do {
                    Carp::confess($@."\n".ixiatcl::errorInfo()."\n\n/\\\\ tcl ====================================================== perl\\\\/\n\n");
                };
                ixiatcl::set("::KLV", $klv);
                if ("'.$returnk.'" eq "*") { 
                    return $klv; 
                }
                if (ixiahlt::status_item("status") != 1) {
                    return ixiatcl::_xeval("keylget ::KLV log");
                }
                return ixiatcl::_xeval("keylget ::KLV '.$returnk.'");
            };
        ';
        eval($ss);
    } else {
        print("Note: $hcmd is already defined\n");
    }
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##
## module return value
##
1;

