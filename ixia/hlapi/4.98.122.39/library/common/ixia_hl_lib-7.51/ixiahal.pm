#
# ixiahal.pm
#
use File::Spec;
use File::Basename;
use ixiatcl;
use ixiahaldata; # has ixiahaldata::* configuration data used below
use warnings;
use strict;
use Carp;

package ixiahal;
sub import () {
    if (defined($ixiahal::initialized)) {
        return 1
    }

    # $_[0] is first word after use (e.g. ixiahlt)
    # next "argument" is assumed to be a hash reference
    # with various optional directives for the use / import process
    my $use_ixnetworktclconnector = 0;
    if (@_ > 1) {
        my %opts = %{$_[1]}; 
        # Syntax:
        # use ixiahal {TclAutoPath => ['c:/tcl/libA', 'c:/tcl/libB']};
        #
        if (exists $opts{TclAutoPath}) {
            my @ap_list = @{$opts{TclAutoPath}};
            foreach my $ap (@ap_list) {
                ixiatcl::lappend('::auto_path', $ap);
            }
            undef @ap_list;
        }
    }

    ixiatcl::_xeval('
        if {[lsearch [package names] IxTclHal] != -1} {
            error "ixiahal.pm: Hal package was already loaded somehow?"
        }
    ');

    #
    # NOTE: work around for commands that take the name of a portlist variable
    #
    ixiatcl::lappend(
        '::wrapped__', @::ixiahaldata::commands_that_use_portlist_as_a_ref
    );
    ixiatcl::_xeval('
        # work around for commands that take the name of a portlist variable
        foreach {_p_} $::wrapped__ {
            proc ${_p_}!!wrapped {port_list_o_rama} [list $_p_ port_list_o_rama]
        }
        unset _p_
    ');
    ixiatcl::unset('::wrapped__');
    my %wrapped; 
    foreach my $x (@::ixiahaldata::commands_that_use_portlist_as_a_ref) {
        $wrapped{$x} = 1; 
    }

    #
    # When using the perl Tcl module it seems it does not 
    # do auto_loading of auto_index-ed procs properly (via 'unknown')
    # so we will force loading of them (later below). firstly, record the 
    # existing ::auto_index elements. we'll skip these later 
    # when we force-load the ixtclhal related ones
    #
    ixiatcl::_xeval('
        # force load of std auto loaded tcl stuff
        tcl_wordBreakBefore "x x" 1
        array set ::ixiahal_pm_preload_auto_index [array get ::auto_index]
    ');

    my @pre_hal_list = ixiatcl::info('commands');
    my %pre_hal_hash;
    foreach my $pre_hal (@pre_hal_list) {
        $pre_hal_hash{$pre_hal} = $pre_hal;
    }

    if (ixiatcl::is_windows()) {
        #
        # calculate the tcl init file to be sourced for ixn
        #
        my $a_dir = "";
        if ($ENV{IXIA_PM_DEV}) {
            print("IXIA_PM_DEV is enabled !!! \n");
            my @l = ixiatcl::glob(
              'C:/Program Files/Ixia/IxOS/5.*/TclScripts/bin/IxiaWish.tcl'
            );
            $ixiahal::halinitfile = $l[-1];
            $a_dir = File::Basename::dirname($ixiahal::halinitfile);
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
            # into the tcl var ::hal_init_file
            ixiatcl::_xeval('
              set ::appinfo_path [registry get {HKEY_LOCAL_MACHINE\SOFTWARE\Ixia Communications\AppInfo\InstallInfo} HOMEDIR]

              set ::appinfo_cmd [file join $::appinfo_path appinfo.exe]
            ');
            ixiatcl::set('::xxx_path', $a_dir);
            ixiatcl::_xeval('
                set ::tmpcmd "{$::appinfo_cmd} --get-single-dependency IxNetwork --app-path {$::xxx_path}"
                if {[catch {set ::hal_init_file [eval exec $::tmpcmd]}]} {
                    set ::hal_init_file ""
                }
                regsub {^IxNetwork:\s*} $::hal_init_file "" ::hal_init_file
                regsub {\s*\\$} $::hal_init_file "" ::hal_init_file
                set ::hal_init_file [file join $hal_init_file TclScripts lib IxTclNetwork IxTclNetwork.tcl]

            ');
            #--------
            $ixiahal::halinitfile = ixiatcl::set('::hal_init_file');
            # remove various scratch vars set above
            ixiatcl::unset('::appinfo_path');
            ixiatcl::unset('::appinfo_cmd');
            ixiatcl::unset('::xxx_path');
            ixiatcl::unset('::tmpcmd');
            ixiatcl::unset('::hal_init_file');
        }
    } else {
        #
        # Load IxTclHal
        #
        my $a_dir = File::Spec->rel2abs(File::Basename::dirname(__FILE__));
        $a_dir = File::Basename::dirname($a_dir);
        $a_dir = File::Basename::dirname($a_dir);
        $a_dir = File::Basename::dirname($a_dir);
        $a_dir = File::Basename::dirname($a_dir);
        ixiatcl::_xeval('lappend ::auto_path '.$a_dir);
    }

    #
    # Source the init file
    #
    if (ixiatcl::is_windows()) {
        eval { 
            ixiatcl::source($ixiahal::halinitfile); 
        };
        if ($@) {
            print(
                "Error sourcing tcl file \"" . 
                $ixiatcl::halinitfile .
                "\":\n---------\n" . 
                ixiatcl::errorInfo() . 
                "\n----------\n\n"
            );
        } else {
            #print("*** sourced: ".  $ixiahal::halinitfile .  "\n");
        }
    }
    my $tmp = ixiatcl::package('require', 'IxTclHal');
    print("ixiahal: IxTclHal version: " . $tmp . "\n");

    ixiatcl::_xeval('
        proc ::_ixiahal_pm_check_cmds {args} {
            foreach {cmd} $args {
                if {[llength [info commands $cmd]] == 0} {
                    if {[info exists ::auto_index($cmd)]} {
                        set failed [catch {
                            uplevel #0 $::auto_index($cmd)
                        } err]
                        if {$failed} {
                            puts stderr "warning: cannot auto_load $cmd"
                        }
                    }
                }
            }
        }
    ');

    ixiatcl::_xinvoke(
        '::_ixiahal_pm_check_cmds', 
        @::ixiahaldata::hal_command_list
    );

    for (my $i=0; $i<=$#::ixiahaldata::hal_command_list; $i++) {
      my $subcmd = $::ixiahaldata::hal_command_list[$i];
      my $flatten_last_arg = 1;
      #print("ixiahal: DEFINING $subcmd \n");

      my $tclcmd = $subcmd;
      if (exists $wrapped{$subcmd}) {
          $tclcmd = $subcmd."!!wrapped"
      }

      #  'if (ref($attrs) ne "HASH") {push(@_, $attrs);}'
      my $ss = "";
      if ($flatten_last_arg == 0) {
        $ss = "sub ixiahal::$subcmd {\n" . 
        '  my $result = "";' . "\n" .
        '  eval {' . "\n" . 
        '    $result=ixiatcl::_xinvoke(' . "\n" .
        "      $tclcmd'," . "\n" .
        '      @_);' . "\n" . 
        '  };' . "\n" .
        '  if ($@) {Carp::confess($@."\n".ixiahal::ixErrorInfo().' . "\n" .
        '      "\n\n/\\\\ tcl ========================= perl\\\\/\n\n");} else { return $result; }'. "\n" .
        '};'
        ;
      } else {
        $ss = "sub ixiahal::$subcmd {\n" . 
        '  my $result = "";' . "\n" .
        '  if (ref($_[-1]) ne "HASH") {' . "\n" .
        '    eval {' . "\n" . 
        '      $result=ixiatcl::_xinvoke(' . "\n" .
        "        '$tclcmd'," . "\n" .
        '        @_);' . "\n" . 
        '    };' . "\n" .
        '    if ($@) {Carp::confess($@."\n".ixiahal::ixErrorInfo().' . "\n" .
        '        "\n\n/\\\\ tcl ========================= perl\\\\/\n\n");} else { return $result; }'. "\n" .
        '  } else {'. "\n" .
        '    my $attrs = pop(@_);' . "\n" .
        '    eval {' . "\n" . 
        '      $result=ixiatcl::_xinvoke(' . "\n" .
        "        '$tclcmd'," . "\n" .
        '        @_, ixiatcl::_flatten($attrs));' . "\n" . 
        '    };' . "\n" .
        '    if ($@) {Carp::confess($@."\n".ixiahal::ixErrorInfo().' . "\n" .
        '        "\n\n/\\\\ tcl ========================= perl\\\\/\n\n");} else { return $result; }'. "\n" .
        '  }' . "\n" .
        '};'
        ;
      }
      #print("<\n" . $ss . "\n>\n");
      eval($ss);
    }

    # I am not entirely trustful of ties between perl and tcl
    # so just supply an accessor to errorInfo instead of using a tie
    sub ixErrorInfo {
        ixiatcl::_xinvoke('set', '::ixErrorInfo');
    };

    #
    #
    #
    $ixiahal::TCL_OK = ixiatcl::set('::TCL_OK');
    $ixiahal::TCL_ERROR = ixiatcl::set('::TCL_ERROR');

    ixiatcl::set('::ixErrorInfo', '');
    $ixiahal::initialized = "1.0.0";
};
## return value for package
1;
