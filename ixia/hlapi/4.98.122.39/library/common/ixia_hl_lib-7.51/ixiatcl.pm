#
# ixiatcl.pm
#

use Tcl;
use File::Spec;
use File::Basename;
use warnings;
use strict;

#####################################################################################
# Below code was added to fix "Segmentation fault" when using ActiveState Tcl module 
# on some linux platforms (BUG1138809).
# Setting [PERL_DL_NONLAZY] forces the loader to load up all functions at once, so 
# that it can ensure that it really does have code for all the functions it claims 
# to have code for.
BEGIN {
  if ($^O !~ /MSWin/) {
        $ENV{PERL_DL_NONLAZY} = 1;
    }
}
#####################################################################################




package ixiatcl;
sub is_windows {
    if ($^O =~ /MSWin/) {
        return 1;
    } else {
        return 0
    }
}
sub import () {
    if (defined($ixiatcl::initialized)) {
        return 1
    }
   
    # $_[0] is first word after use (e.g. ixiahlt)
    # next "argument" is assumed to be a hash reference
    # with various optional directives for the use / import process
    my $use_ixnetworktclconnector = 0;
    my $use_ixiaperlserver = '';
    my @use_ap_list = ();
    if (@_ > 1) {
        my %opts = %{$_[1]};
        # Syntax:
        # use ixiaixn {TclAutoPath => ['c:/tcl/libA', 'c:/tcl/libB']};
        #
        if (exists $opts{TclAutoPath}) {
            @use_ap_list = @{$opts{TclAutoPath}};
        }
        if (exists $opts{IXIAPERLSERVER}) {
            $use_ixiaperlserver = $opts{IXIAPERLSERVER};
        }
    }

    #
    # make tcl interpreter used to do all the work
    #
    $ixiatcl::interp = new Tcl;
    $ixiatcl::interp->Init();
    $::ixiatcl::interp->Eval('set ::tcl_platform(IXNETWORK_CLIENT_TYPE) perl');
    # HACK: fix core dump when writing to ::env from Tcl interp inside Perl
    # SR 207094 (BUG736779) Active Perl gives core dump after Ixia cleanup session
    $ixiatcl::interp->Eval('
        if {[info commands ::perl::Eval] != ""} {
            set orig_env [array get ::env]
            # unset the tcl special variable
            array unset ::env
            # restore it without the tcl tracking
            array set ::env $orig_env

            # track it manually in order to propagate
            # the environment changes to main perl process
            proc ::perl::env_writeback_hack {varName index op} {
                    ::perl::Eval "\$ENV\{\'$index\'\} = \'$::env($index)\'"
            }
            proc ::perl::env_readback_hack {varName index op} {
                    if {[::perl::Eval "exists(\$ENV{\'$index\'})"]} {
                            set ::env($index) [::perl::Eval "\$ENV{\'$index\'}"]
                    }
            }
            trace add variable ::env write ::perl::env_writeback_hack
            trace add variable ::env read ::perl::env_readback_hack
        }
    ');

    $ixiatcl::_pm_comm_id = 'LOCAL';

    # note: env overrides any directives in the using stmt args
    if ($ENV{IXIAPERLSERVER}) {
        $use_ixiaperlserver = $ENV{IXIAPERLSERVER};
    }

    if ($use_ixiaperlserver ne '') {
        my @_pm_flds = split(/:/, $use_ixiaperlserver);
        $ixiatcl::_pm_comm_id = "$_pm_flds[1] $_pm_flds[0]";
        print("ixiatcl: $_pm_flds[0]\n");
        print("ixiatcl: $_pm_flds[1]\n");

        #
        # Load comm pkg into local interp from tcllib dir
        #
        my $a_dir = File::Spec->rel2abs(File::Basename::dirname(__FILE__));
        $a_dir = File::Basename::dirname($a_dir);

        print("ixiatcl: using comm package: ".
            $ixiatcl::interp->Eval(
                "lappend ::auto_path $a_dir; package require comm") .
            " for remoting\n"
        );
        print("ixiatcl: remoting portmapper -> '$ixiatcl::_pm_comm_id'\n");
        $ixiatcl::interp->invoke(
            '::comm::comm', 'connect', $ixiatcl::_pm_comm_id
        );
        $ixiatcl::_sess_comm_id = $ixiatcl::interp->invoke(
            '::comm::comm', 'send', $ixiatcl::_pm_comm_id,
            '::ix_psvr::portmap.'.$_pm_flds[1],
            'new_session'
        );
        my @_sess_flds = split(/:/, $ixiatcl::_sess_comm_id);
	if ($_sess_flds[0] eq 'use.portmap.server') {
            $_sess_flds[0] = $_pm_flds[0];
	}
        $ixiatcl::_sess_comm_id = "$_sess_flds[1] $_sess_flds[0]";
        print("ixiatcl: remoting session -> '$ixiatcl::_sess_comm_id'\n");
        undef @_sess_flds;
        undef @_pm_flds;
        #
        #
        #
        $::ixiatcl::interp->Eval(
            'proc ::_xtinvoke {args} {::comm::comm send {' .
            $ixiatcl::_sess_comm_id .
            '} $args}'
        );
    }


    # A tcl invoker that can do remoting via the tcllib comm package
    # this should always be used to do interp invocations
    # never use $::ixiatcl::interp->invoke() unless you really know that's
    # what you to do
    sub _xinvoke {
        if ($ixiatcl::_pm_comm_id eq 'LOCAL') {
            $::ixiatcl::interp->invoke(@_);
        } else {
            # remote all commands
            print("_xremote >>>" . join(",", @_) . "\n");
            $::ixiatcl::interp->invoke('::_xtinvoke', @_);
        }
    }
    #
    # A tcl evaler that can do remoting
    #
    sub _xeval {
        if ($ixiatcl::_pm_comm_id eq 'LOCAL') {
            $ixiatcl::interp->Eval(@_);
        } else {
            ixiatcl::eval(@_); # this inturn calls _xinvoke
        }
    }

    #
    # Util for flattening a hash into a tcl option value list
    # {-option0 value0 ... -optionN valueN} list
    #
    # Note: not for general consumption subject to change
    # w/o notice
    #
    sub _xflatten {
        if (@_ != 1) {
            return @_;
        }
        my $ref = $_[0];
        if (ref($ref) eq 'HASH') {
            my @l = ();
            while ((my $k, my $v) = each(%$ref)) {
                $k =~ s/^\-//;
                push(@l,"-".$k);
                push(@l,$v);
            }
            return @l;
        }
        if (ref($ref) eq 'ARRAY') {
            return @$ref;
        }
        return @_;
    }

    sub _flatten {
        if (@_ != 1) {
            return @_;
        }
        my $ref = $_[0];
        if (ref($ref) eq 'HASH') {
            my @l = ();
            while ((my $k, my $v) = each(%$ref)) {
                $k =~ s/^\-//;
                push(@l,"-".$k);
                if (ref($v) eq 'ARRAY') {
                    my @vv = _flatten($v);
                    push(@l,\@vv);
                } elsif (ref($v) eq 'HASH') {
                    my @vv = _flatten($v);
                    push(@l,\@vv);
                } else {
                    push(@l,$v);
                }
            }
            return @l;
        }
        if (ref($ref) eq 'ARRAY') {
            my @l = ();
            foreach my $v (@$ref) {
                if (ref($v) eq 'ARRAY') {
                    my @vv = _flatten($v);
                    push(@l, \@vv);
                } elsif (ref($v) eq 'HASH') {
                    my @vv = _flatten($v);
                    push(@l, \@vv);
                } else {
                    push(@l, $v);
                }
            }
            return @l;
        }
        return @_;
    }

    #
    # I am not entirely trustful of ties between perl and tcl
    # so just supply an accessor to errorInfo instead of using a tie
    sub errorInfo {
        ixiatcl::_xinvoke('set', '::errorInfo');
    };

    #
    # Make a set of bindings for the basic tcl commands
    #

    for my $cmd (
    "after",
    "append",
    "array",
    "bgerror",
    "binary",
    "break",
    "catch",
    "cd",
    "clock",
    "close",
    "concat",
    "continue",
    "dde",
    "encoding",
    "eof",
    "error",
    "eval",
    "exec",
    "exit",
    "expr",
    "fblocked",
    "fconfigure",
    "fcopy",
    "file",
    "fileevent",
    "filename",
    "flush",
    "for",
    "foreach",
    "format",
    "gets",
    "glob",
    "global",
    "if",
    "incr",
    "info",
    "interp",
    "join",
    "lappend",
    "lindex",
    "linsert",
    "list",
    "llength",
    "load",
    "lrange",
    "lreplace",
    "lsearch",
    "lset",
    "lsort",
    "namespace",
    "open",
    "package",
    "parray",
    "pid",
    "proc",
    "puts",
    "pwd",
    "read",
    "regexp",
    "registry",
    "regsub",
    "rename",
    "resource",
    "return",
    "scan",
    "seek",
    "set",
    "socket",
    "source",
    "split",
    "string",
    "subst",
    "switch",
    "tell",
    "time",
    "trace",
    "unknown",
    "unset",
    "update",
    "uplevel",
    "upvar",
    "variable",
    "vwait",
    "while"
    ) {
        my $ss =
          "sub $cmd " . '{ ixiatcl::_xinvoke('. "\"$cmd\"". ', @_); }';
        #print("<" . $ss . ">\n");
        eval($ss);
        #print("done\n");
    }
    ixiatcl::_xeval(
        'if {$::tcl_platform(platform) == "windows"} {package require registry}'
    );

    #
    # Make a few dummy commands related to the tk that the hlt_init.tcl file
    # (and other similar ixia XXX_init.tcl files)
    # try to use to hide/show windows etc..
    #
    ixiatcl::_xinvoke("proc", "console", 'args', '');
    ixiatcl::_xinvoke("proc", "wm", 'args', '');
    ixiatcl::_xinvoke("set", "::tcl_interactive", "0");

    foreach my $ap (@use_ap_list) {
        ixiatcl::lappend('::auto_path', $ap);
    }

    print("ixiatcl: Tcl version: " . ixiatcl::info("patchlevel"). "\n");
    $ixiatcl::initialized = ixiatcl::info("patchlevel");
}
## return value for package
1;
