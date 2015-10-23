#
# ixiaixn.pm
#
use File::Spec;
use File::Basename;
use ixiatcl;
use warnings;
use strict;
use Carp;

package ixiaixn;
sub import () {
    if (defined($ixiaixn::initialized)) {
        return 1
    }

    # $_[0] is first word after use (e.g. ixiahlt)
    # next "argument" is assumed to be a hash reference
    # with various optional directives for the use / import process
    my $use_ixnetworktclconnector = 0;
    if (@_ > 1) {
        my %opts = %{$_[1]};
        # Syntax:
        # use ixiaixn {IxTclNetworkConnector => 1};
        # use ixiaixn {IxTclNetworkConnector => 0};
        #
        if (exists $opts{IxTclNetworkConnector}) {
            if ($opts{IxTclNetworkConnector}) {
                $use_ixnetworktclconnector = 1;
            }
        }
        # Syntax:
        # use ixiaixn {TclAutoPath => ['c:/tcl/libA', 'c:/tcl/libB']};
        #
        if (exists $opts{TclAutoPath}) {
            my @ap_list = @{$opts{TclAutoPath}};
            foreach my $ap (@ap_list) {
                ixiatcl::lappend('::auto_path', $ap);
            }
            undef @ap_list;
        }
    }

    if (ixiatcl::is_windows()) {
        #
        # calculate the tcl init file to be sourced for ixn
        #
        my $a_dir = "";
        if ($ENV{IXIA_PM_DEV}) {
            print("IXIA_PM_DEV is enabled !!! \n");
            my @l = ixiatcl::glob('C:/Program Files*/Ixia/IxNetwork/5.*/TclScripts/lib/IxTclNetwork/IxTclNetwork.tcl');
            $ixiaixn::ixninitfile = $l[-1];
            $a_dir = File::Basename::dirname($ixiaixn::ixninitfile);
            $a_dir = File::Basename::dirname($a_dir);
            ixiatcl::lappend('::auto_path', $a_dir);

        } else {
            $a_dir = File::Spec->rel2abs(File::Basename::dirname(__FILE__));
            $a_dir = File::Basename::dirname($a_dir);
            $a_dir = File::Basename::dirname($a_dir);
            $a_dir = File::Basename::dirname($a_dir);
            $a_dir = File::Basename::dirname($a_dir);
            $a_dir = File::Basename::dirname($a_dir);
            $a_dir = File::Basename::dirname($a_dir);
            # a_dir should now be something like
            # C:\Program Files\Ixia\hltapi\3.90.0.53
            # print(">>> a_dir = $a_dir \n");
            #--------
            # Do various appinfo calls to get path to ixnetwork
            # then build the path to IxTclNetwork.tcl
            # into the tcl var ::ixn_init_file
            ixiatcl::_xeval('
              set ::appinfo_path [registry get {HKEY_LOCAL_MACHINE\SOFTWARE\Ixia Communications\AppInfo\InstallInfo} HOMEDIR]

              set ::appinfo_cmd [file join $::appinfo_path appinfo.exe]
            ');
            ixiatcl::set('::hltapi_path', $a_dir);
            ixiatcl::_xeval('
                set ::tmpcmd "{$::appinfo_cmd} --get-single-dependency IxNetwork --app-path {$::hltapi_path}"
                if {[catch {set ::ixn_init_file [eval exec $::tmpcmd]}]} {
                    set ::ixn_init_file ""
                }
                regsub {^IxNetwork:\s*} $::ixn_init_file "" ::ixn_init_file
                regsub {\s*\\$} $::ixn_init_file "" ::ixn_init_file
                set ::ixn_init_file [file join $ixn_init_file TclScripts lib IxTclNetwork IxTclNetwork.tcl]

            ');
            #--------
            $ixiaixn::ixninitfile = ixiatcl::set('::ixn_init_file');
            # remove various scratch vars set above
            ixiatcl::unset('::appinfo_path');
            ixiatcl::unset('::appinfo_cmd');
            ixiatcl::unset('::hltapi_path');
            ixiatcl::unset('::tmpcmd');
            ixiatcl::unset('::ixn_init_file');
        }
    } else {
        #
        # Load IxTclNetwork
        #
        my $a_dir = File::Spec->rel2abs(File::Basename::dirname(__FILE__));
        $a_dir = File::Basename::dirname($a_dir);
        $a_dir = File::Basename::dirname($a_dir);
        $a_dir = File::Basename::dirname($a_dir);
        $a_dir = File::Basename::dirname($a_dir);
        ixiatcl::_xeval('lappend ::auto_path '.$a_dir);
        ixiatcl::_xeval('package require IxTclNetwork');
    }


    #
    # Make a few dummy commands related to the tk that the xx_init.tcl file
    # tries to use to hide/show windows etc..
    #
    ixiatcl::_xinvoke("proc", "console", 'args', '');
    ixiatcl::_xinvoke("proc", "wm", 'args', '');

    #
    # Source the ixn init file
    #
    if (ixiatcl::is_windows()) {
        eval {
        ixiatcl::_xinvoke("source", $ixiaixn::ixninitfile);
        };
        if ($@) {
            print(
                "Error sourcing tcl file \"" .
                $ixiatcl::ixninitfile .
                "\":\n---------\n" .
                ixiatcl::errorInfo() .
                "\n----------\n\n"
            );
        }
    }

    sub ixNet {
        my $r="";
        eval { $r = ixiatcl::_xinvoke('ixNet', @_);  };
        if ($@) {
            Carp::confess("ixNet error:\n".$@."\n");
        } else {
            return $r;
        }
    };

    #
    # Make a set of bindings for the subcommands in ixNet
    #
    my @sub_cmd_spec_list = (
        ["commit", 0],
        ["rollback", 0],
        ["execute", 0],

        ["writeTo", 0],
        ["readFrom", 0],

        ["getList", 0],
        ["getFilteredList", 0],
        ["getAttribute", 0],
        ["exists", 0],

        ["setMultiAttrs", -1],
        ["setAttribute", -1],
        ["add", 0],
        ["remove", 0],

        ["adjustIndexes", 0],

        ["remapIds", 0],
        ["getRoot", 0],
        ["getNull", 0],
        ["getParent", 0],

        ["connect", 0],
        ["disconnect", 0],

        ["setSessionParameter", 0],

        ["getVersion", 0],
        ["help", 0],
        
        ["getResult", 0],
        ["isDone", 0],
        ["isSuccess", 0],
        ["wait", 0]
    );

    sub ixiaixn::traceixnetcommands {
        ixiatcl::_xeval(
            '
            if {[llength [info commands _ixnet]] == 0} {
              rename ixNet _ixnet
              proc ixNet {args} {
                set cmd [lrange $args 0 3]
                set args [linsert $args 0 _ixnet]
                puts stdout "ixn>>>$args"
                set t [lindex [time {set r [eval $args]}] 0]
                puts stdout "$r<<< time = $t";
                return $r
              }
            }
            '
        );
    }

    for (my $i=0; $i<=$#sub_cmd_spec_list; $i++) {
      my $subcmd = $sub_cmd_spec_list[$i][0];
      my $flatten_last_arg = $sub_cmd_spec_list[$i][1];

      #  'if (ref($attrs) ne "HASH") {push(@_, $attrs);}'
      my $ss = "";
      if ($flatten_last_arg == 0) {
        $ss = "sub ixiaixn::$subcmd {\n" .
        '  my $result = "";' . "\n" .
        '  eval {' . "\n" .
        '    $result=ixiatcl::_xinvoke(' . "\n" .
        "      'ixNet','$subcmd'," . "\n" .
        '      @_);' . "\n" .
        '  };' . "\n" .
        '  if ($@) {Carp::confess($@."\n".ixiatcl::errorInfo().' . "\n" .
        '      "\n\n/\\\\ tcl ========================= perl\\\\/\n\n");} else { return $result; }'. "\n" .
        '};'
        ;
      } else {
        $ss = "sub ixiaixn::$subcmd {\n" .
        '  my $result = "";' . "\n" .
        '  if (ref($_[-1]) ne "HASH") {' . "\n" .
        '    eval {' . "\n" .
        '      $result=ixiatcl::_xinvoke(' . "\n" .
        "        'ixNet','$subcmd'," . "\n" .
        '        @_);' . "\n" .
        '    };' . "\n" .
        '    if ($@) {Carp::confess($@."\n".ixiatcl::errorInfo().' . "\n" .
        '        "\n\n/\\\\ tcl ========================= perl\\\\/\n\n");} else { return $result; }'. "\n" .
        '  } else {'. "\n" .
        '    my $attrs = pop(@_);' . "\n" .
        '    eval {' . "\n" .
        '      $result=ixiatcl::_xinvoke(' . "\n" .
        "        'ixNet','$subcmd'," . "\n" .
        '        @_, ixiatcl::_flatten($attrs));' . "\n" .
        '    };' . "\n" .
        '    if ($@) {Carp::confess($@."\n".ixiatcl::errorInfo().' . "\n" .
        '        "\n\n/\\\\ tcl ========================= perl\\\\/\n\n");} else { return $result; }'. "\n" .
        '  }' . "\n" .
        '};'
        ;
      }
      #print("<\n" . $ss . "\n>\n");
      eval($ss);
    }

    my $tmp = ixiatcl::package('require', 'IxTclNetwork');
    print("ixiaixn: IxTclNetwork version: " . $tmp . "\n");
    # Put the connection manager shim in place if requested
    if ($use_ixnetworktclconnector) {
        $tmp = ixiatcl::_xeval('package require IxTclNetworkConnector');
        print("ixiaixn: IxTclNetworkConnector version: " . $tmp . "\n");
    }
    $ixiaixn::initialized = "1.0.0";
};
ixiatcl::set('::errorInfo', '');
## return value for package
1;
