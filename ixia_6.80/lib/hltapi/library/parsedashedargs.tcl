proc procDescr {procName descr} {
    global _ixia_proc_descr
    set _ixia_proc_descr($procName) $descr
}


proc ixia_help {args } {
    global _ixia_proc_descr

    set opt_args {-proc}

    ixia::parse_dashed_args -args $args -optional_args $opt_args

    if {[info exists proc]} {
        if {[info exists _ixia_proc_descr($proc)]} {
            return $_ixia_proc_descr($proc)
        }
    }
}


##Library Header
#
# $Id: parse_dashed_args.tcl,v 1.24.2.3 2005/10/24 19:31:21 mkirkham Exp $
# Copyright (c) 2002 by Cisco Systems, Inc.
#
# Name:
#   parse_dashed_args
#
# Purpose:
#   This library provides the procedure "parse_dashed_args", which is used
#   to parse a list of dashed arguments into an array or variables within
#   the context of the calling routine or script.
#
# Author:
#   Dave Cardosi and Wayne Marquette
#
# Usage:
#   package require parse_dashed_args
#
# Description:
#   The top level procedure for this library is parse_dashed_args. All other 
#   procedures in this library are internal in support of parse_dashed_args.
#
#   To see all the features of parse_dashed_args, refer to the
#   procedure description.
#
# Requirements:
#   package require Cisco
#
# Support Alias:  
#   ats-gate@cisco.com or dcardosi@cisco.com
#
# Keywords:
#   parsing parser parse dashed args arguments
#
# Category:
#   utilities,parsing utilities,development
#
# End of Header


##Internal Procedure Header
#
# Name:
#   ::ixia::parse_dashed_args
#
# Purpose:
#   To parse a list of dashed arguments into an array or variables within
#   the context of the calling routine or script.
#
# Synopsis:
#   ::ixia::parse_dashed_args -args <parse_arglist> 
#                     [-mandatory_args <man_arglist>] 
#                     [-optional_args <opt_arglist>]
#                     [-return_direct | -return_array <array-name>]
#                     [-passthru]
#                     [-no_help]
#                     [-level <context-level>]
#
# Arguments:
#   -args <parse_arglist>
#       List of arguments to be parsed, where arguments must be in a
#       dashed format.  The format can be stand-alone (ex. -arg1) or in 
#       argument/value pairs (ex. -arg1 value1). Note the value may
#       also be a list (ex. -arg1 value1 value2 value3).
#       Each element in the parse list must appear in one of the
#       argument check lists (mandatory or optional).  If all check
#       lists are null, then any arguments in the parse list cause an
#       error to be thrown.
#
#   -mandatory_args <man_arglist>
#       List of mandatory arguments.
#       Every element in this list identifies a dashed argument name
#       required in the parse list.  
#       If a mandatory argument specified here is not found in the 
#       arguments being parsed, an error is thrown.
#       By default, a null list is assumed, meaning there are
#       no mandatory arguments.
#       The arguments are specified in a "line" format as follows:
#         -<argname>[:<altname>] <check_type> <check_fields>
#                                <check_type> <check_fields>
#                                ...
#         -<argname>[:<altname>] <check_type> <check_fields>
#                                <check_type> <check_fields>
#                                ...
#         Breakdown:
#           - The <argname> is the name of the dashed argument 
#             (with the dash).  It is required.
#           - The colon separated <altname> is optional.  If specified, it
#             will be used as an alternative variable name or array index
#             upleveled to the callers context, instead of the argname.
#             In most cases this should be avoided if possible.
#           - The <check_type> is a check type which may be followed by 
#             corresponding <check_fields> depending on the type as
#             follows (check_type is always specifed in all caps):
#               RANGE <low_value>-<high_value>
#                  A numeric range, between low_value and high_value.
#               CHOICES <choice1> <choice2> <choice3>... 
#                  A list of choice values logically or'ed together.
#               IP
#                  An IP address, either v4 (dotted decimal notation) or
#                  v6 (colon hexadecimal notation).
#               IPV4
#                  A v4 IP address (of the form #.#.#.#).
#               IPV6
#                  A v6 IP address (of the form #:#:#:#:#:#:#:#).
#               MASK
#                  An IP mask in either v4, v6, or CIDR (decimal) format.
#               MAC
#                  A MAC address, in standard or Cisco format.
#               KEYLIST 
#                  A TCL keyed list.  The KEYLIST type is exclusive, meaning
#                  it cannot be combined with other check types, and only
#                  a single keylist value is allowed.  No verification is
#                  done on the keylist value, it is assumed to be in
#                  TCL keylist format, so invalid keylist formats will
#                  have unforseen consequences.
#               REGEXP
#                  A TCL regular expression.
#               ALPHA
#                  An alphabetic only value.
#               NUMERIC
#                  A numeric only value.
#               ALPHANUM
#                  An alphanumeric value (letters, numbers, or underbars).
#               DECIMAL
#                  A decimal value (a number with a possible single
#                  decimal point).
#               HEX
#                  A hex value, which may optionally have a leading "0x".
#               FLAG
#                  A flag argument, meaning this argument either does not have
#                  any value and is a stand-alone argument or accepts a boolean
#                  value (0, 1, yes, no, true or false).  The behavior of
#                  FLAG switches depends on the presence or absense of a
#                  DEFAULT value.
#
#                  If a DEFAULT value is defined for the flag, then the
#                  return variable will always be set to 0 or 1 and the
#                  optional_args return variable will get both the switch
#                  name and the 0 or 1 value.
#
#                  If a DEFAULT value IS NOT defined for the flag, then the
#                  return variable is set to 1 only if the switch is provided
#                  and is not set otherwise.  Likewise, only the switch
#                  name will be included in the optional_args return variable
#                  and only if the switch is provided.
#
#                  The FLAG type is exclusive, meaning it cannot be combined
#                  with other check types.
#               SHIFT
#                  An unchecked value which is blindly "shifted" from the
#                  list of arguments.  This is generally used for string 
#                  values which could contain special characters, and would
#                  therefore confuse the parser if not ignored (such as a
#                  leading dash).
#                  This type is limited to a single value since only a
#                  single positional shift is performed, so anything that
#                  may contain spaces must be quoted into a single string.
#                  ** Note **
#                  This check type should be avoided unless absolutely
#                  required, and use caution in those cases as a blind
#                  shift can have unforseen consequences, such as taking the
#                  next dashed argument as the value if no value exists.
#               ANY
#                  Any value, meaning no check is performed on the value.
#                  This type is equivalent to not specifying a check type
#                  and therefore unnecessary, but is provided simply for 
#                  user convenience.
#               LIST_SIZE <value>
#                  The number of values allowed for this argument.  By
#                  default, any argument can be a list and therefore have
#                  multiple values.  Using this type allows you to specify
#                  the list size.  The minimum value is 1.  
#               DEFAULT <value> 
#                  A default value.  This applies only to optional
#                  arguments.  If the optional argument is not specified,
#                  it will be set to this value.
#                  It is good programming technique to always include
#                  a DEFAULT setting, which then allows the scripter to
#                  check the variable directly (since it will always be
#                  set to a value if it has a default), thereby avoiding
#                  the scripter having to use "info exists" calls.
#               REQUIRES <list> 
#                  This property specifies the names of other options
#                  that must also be specified along with the option that
#                  this property is assigned to.
#               EXCLUDES <list> 
#                  This property specifies the names of other options that
#                  must not be used when the option that this property is
#                  assigned to is used.
#               VCMD <proc>
#                  Specifies the name of an external procedure to be invoked
#                  in order to validate the value with the corresponding
#                  option.  The specified procedure is appended with one
#                  list element providing the value to be validated.  The
#                  procedure can return either a boolean value or a list
#                  consisting of a boolean value and a reason message,
#                  where any "true", "yes" or any non-zero value indicates
#                  that the value is valid, while "false", "no" or 0 indicates
#                  the value is invalid, and the reason message can be used
#                  to indicate what is wrong with the value.
#           - If the parsed value for an argument does not match the check
#             value, an error is thrown.  Note that if the parsed value is
#             a list, then the check is done for each element of the list.
#           - Only one dashed argument may appear on a line, however multiple
#             check types may be used for each argument.  Multiple checks
#             are logically or'ed together.
#
#   -optional_args <opt_arglist>
#       Space separated list of optional arguments, specified as:
#       <argname>[:<altname>][<<check_value>>]  
#       Every element in this list identifies a dashed argument
#       name which may optionally appear in the parse list.  
#       By default, a null list is assumed, meaning there are
#       no optional arguments.
#       Note: The same format breakdown applies here as for the
#       mandatory argument list.
#
#   -return_direct
#       Flag indicating all parsed arguments are to be returned directly
#       back as variables of the same name within the context of the 
#       calling procedure or script.  This is the default.
#
#   -return_array <array-name>
#       If specified, parsed arguments will be returned as indexes within
#       the specified array-name.  The array will be returned back as a
#       single variable within the context of the calling procedure or 
#       script.  This is mutually exclusive of the -return_direct option.
#
#   -passthru
#       Option to pass through or save all "extra" arguments in the
#       parsed list.  Normally, any extra parsed arguments not 
#       found in the mandatory or optional lists would 
#       cause an error to be thrown.  With the -passthru option,
#       these arguments are instead placed into a variable called
#       "passthru_args", which is upleveled back to the callers 
#       context, and no error is generated.  This option may
#       be useful in cases where argument lists are "passed down" between
#       procedures, so strict argument checking at the top level procedure
#       would cause problems, however care should be taken as this option
#       could mask problems by allowing invalid options to go unchecked.
#
#   -no_help
#       Option to turn off the automatic procedure usage help normally 
#       displayed for parse failures.
#
#   -level <context-level>
#       The context level where variables will be placed (via
#       uplevel).  By default, the level is 1 (meaning the 
#       level of the calling procedure or script).  This is
#       provided for internal use, so end users should have no
#       reason to ever change this.
#
#   -exact
#       Flag specifying the use of exact matching of arguments to
#       their corresponding specification, meaning the options must
#       be provided using their exact names.  This is the default
#       in Tcl's non-interactive mode.
#
#   -closest
#       Flag specifying the use of closest matching of arguments to
#       their corresponding specification, meaning the options may
#       be provided using any unique prefix for the actual option
#       name within the specification.  This is the default
#       in Tcl's interactive mode.
#
# Return Values:
#   For success:
#       Each dashed argument in the parse list is placed into the
#       context of the caller as a variable or array index of the same
#       name (without the dash), containing the value from the
#       parse list.  For stand-alone dashed arguments, they
#       are placed as variables with a value of 1.  Note that
#       if the <argname>:<altname> format was used, then the
#       variables or indexes are named accordingly.  
#       In addition, the variables or indexes "mandatory_args",
#       "optional_args", and "passthru_args" are passed back for each
#       of those options, containing a list of the respective arguments.
#   For failure:
#       Throws an error. Note that the caller can invoke parse_dashed_args 
#       using catch cmd to capture the error message and exit gracefully
#       without printing the full error stack trace.
#
# Description:
#   This procedure is intended to provide a single, centralized parsing
#   solution for scripters, thereby removing the repetitive and mundane
#   burden of having parsing code within every script or procedure.
#   It takes a list of dashed arguments, parses them, and returns them
#   as an array or variables within the context of the calling routine
#   or script.
#   The procedure is quite robust, with a slew of features, among them:
#
#   * Predefined type checking:
#        Complex types such as IP addresses or ranges of values can
#        be easily verified via built in type specifications.
#
#   * Custom type checking:
#        Supports "regexp" specification for custom built user check types.
#
#   * Multiple type checking:
#        Check types can be combined, allowing for combinations of values
#        and either/or style logic verification.
#
#   * Mandatory arguments:
#        Ability to require arguments as mandatory.
#
#   * Optional arguments:
#        Ability to specify arguments as optional.
#
#   * Passthrough arguments:
#        Ability to allow unspecified arguments to be "passed through".
#
#   * Default values:
#        Ability to assign a default value to any optional argument.
#
#   * Argument lists:
#        Ability for arguments to contain no value, a single value, or a
#        list of values, and the ability to control the list size.
#
#   * Argument aliasing:
#        Ability for arguments to have alternate names.
#
#   * Argument return type flexibility:
#        Allow for arguments to be returned as individual variables or
#        as an array.
#
# Examples:
#   Example 1:  Using check types
#
#     # Note: Normally the args come from the command line or
#     # the proc call, but they are set here for reference
#     set args "-port eth1/0/0 eth2/0/0 5\
#               -clock internal \
#               -debug \
#               -detail \
#               -framing sdh \
#               -ip 100.1.55.250 1a1b:2:3:4:aa:bb:9a:ffff \
#               -ip4 1.2.3.4 \
#               -ip6 1111:2222:aaaa:bbbb:0:0:1:9999 \
#               -mask 16 255.255.0.0 \
#               -mac 11.22.aa.aa.ff.1f 1234.aabb.1f1f \
#               -slot 1 4 8 \
#               -name dave \
#               -kl {{a 1} {b 2} {c 3}}\
#               -shift1 -foo \
#               -alp abc \
#               -num 100 \
#               -rtr sys_1 \
#               -dec 12.52 \
#               -hex 0xa5 1bf \
#               -type xyz 5 node_1 4.2 whatever
#               "
#     set man_list {-port
#                   -clock CHOICES internal line
#                  }
#     set opt_list {-debug    FLAG
#                   -detail   
#                   -framing  CHOICES sdh sonet atm
#                   -ip       IP
#                   -ip4      IPV4
#                   -ip6      IPV6
#                   -mask     MASK
#                   -mac      MAC
#                   -slot     RANGE 1-8
#                   -name     REGEXP  ^[a-z]+$
#                   -kl       KEYLIST
#                   -shift1   SHIFT
#                   -alp      ALPHA
#                   -num      NUMERIC
#                   -rtr      ALPHANUM
#                   -dec      DECIMAL
#                   -hex      HEX
#                   -type     ANY
#                   -un1      NUMERIC
#                   }
#     parse_dashed_args -args $args -mandatory_args $man_list\
#         -optional_args $opt_list 
#     # At this point, all args that were passed in are now present
#     # as variables of the same name.
#     # All args that were not passed in are not present as variables,
#     # which means they are undefined.  Use of the "info exists"
#     # call would be required for all optional arguments in order to
#     # determine their existance.
#     # If we print the the user args, they would look like this:
#     puts "$port"
#       # Would display "eth1/0/0 eth2/0/0 5"
#       # Notice that port is a list of values.  The parser allows any
#       # argument to be a list by default.
#     puts "$clock"
#       # Would display "internal"
#     puts "$debug"
#       # Would display "1".  Notice that this was defined as a FLAG, so
#       # the parser set the value to 1.
#     puts "$detail"
#       # Would display "1".  Notice that this was not defined as a FLAG,
#       # yet the parser determined this was a flag so set the value to 1.
#       # This is a rather unique property of flag type variables, the
#       # parser can dynamically determine them and set them to a 1 value.
#     puts "$framing"
#       # Would display "sdh"
#     puts "$ip"
#       # Would display "100.1.55.250 1a1b:2:3:4:aa:bb:9a:ffff".  Notice
#       # both ipv4 and ipv6 formats allowed for type IP.
#     puts "$ip4"
#       # Would display "1.2.3.4"
#     puts "$ip6"
#       # Would display "1111:2222:aaaa:bbbb:0:0:1:9999"
#     puts "$mask"
#       # Would display "16 255.255.0.0".  Notice the CIDR and IP masks
#       # both allowed for type MASK.
#     puts "$mac"
#       # Would display "11.22.aa.aa.ff.1f 1234.aabb.1f1f".  Notice both
#       # standard and Cisco formats allowed for type MAC.
#     puts "$slot"
#       # Would display "1 4 8"
#     puts "$name"
#       # Would display "dave"
#     puts "$kl"
#       # Would display "{a 1} {b 2} {c 3}"
#     puts "$shift1"
#       # Would display "-foo".  Notice this was check type SHIFT, so the
#       # leading dash was allowed as a value.  Please avoid the SHIFT
#       # type unless absolutely necessary due to the possible bad
#       # consequences of doing a hard shift.  The check type ANY should
#       # suffice for most strings.
#     puts "$alp"
#       # Would display "abc"
#     puts "$num"
#       # Would display "100"
#     puts "$rtr"
#       # Would display "sys_1"
#     puts "$dec"
#       # Would display "12.52"
#     puts "$hex"
#       # Would display "0xa5 1bf".  Notice values allowed with or without
#       # the leading "0x" for type HEX.
#     puts "$type"
#       # Would display "xyz 5 node_1 4.2 whatever".  
#     # Those are all the user variables, however the parser also returns
#     # the mandatory and optional arguments and values as variables.  They
#     # are always named "mandatory_args" and "optional_args", so be sure
#     # not to have variables of the same name within your script already
#     # or they will be overwritten.
#     puts "$mandatory_args"
#       # Would display "-clock internal"
#     puts "$optional_args"
#       # Would display "-debug -detail -framing sdh
#                        -ip {100.1.55.250 1a1b:2:3:4:aa:bb:9a:ffff}
#                        -ip4 1.2.3.4 -ip6 1111:2222:aaaa:bbbb:0:0:1:9999
#                        -mask {16 255.255.0.0}
#                        -mac {11.22.aa.aa.ff.1f 1234.aabb.1f1f}
#                        -slot {1 4 8} -name dave
#                        -kl {{a 1} {b 2} {c 3}}
#                        -shift1 -foo -alp abc -num 100 -rtr sys_1
#                        -dec 12.52 -hex {0xa5 1bf}
#                        -type {xyz 5 node_1 4.2 whatever}"
#       # Notice that only the variables and values specified by the user are 
#       # contained in the returned optional_args variable, other valid
#       # optional arguments that the user did not specify values for
#       # are not returned, so this is a list of optional arguments that
#       # were actually parsed.
#       # These variables are normally used for passing to subsequent
#       # procedure calls.
#
#
#   Example 2: Using multiple check types, lists, and defaults
#
#     set args {-port_type oc12 \
#               -keepalive off \
#               -hosts rtr1 rtr2 rtr3 \
#               -slot 2 \
#              }
#     set man_list {-port_type   CHOICES oc3 oc12 oc48
#                                CHOICES eth faste gige atm
#                                RANGE 1-5
#                                RANGE 10-20
#                                IP
#                  }
#     set opt_list {-keepalive   DEFAULT 5
#                                CHOICES on off 
#                                RANGE 0-10
#                   -count       CHOICES up down sideways 
#                                NUMERIC
#                                DEFAULT 8
#                   -hosts       ALPHANUM
#                                LIST_SIZE 3
#                   -slot        NUMERIC
#                                LIST_SIZE 1
#                  }
#     parse_dashed_args -args $args -optional_args $opt_list \
#                       -mandatory_args $man_list
#     puts "$port_type"
#       # Would display "oc12".  Notice that many check types were specified
#       # for this field, so the valid values allowed were not only the 
#       # various choices, but also a number from 1-5, a number from 10-20,
#       # or an ip address.  Any of these would have been accepted.  This
#       # shows the power of multiple check types.
#     puts "$keepalive"
#       # Would display "off".  Notice that since a value was specified
#       # in the parsed arguments, the default was not needed.
#     puts "$count"
#       # Would display "8".  Notice that there was no -count in the args 
#       # being parsed, and yet a value was assigned based on the DEFAULT
#       # specification.  A default can only be specified for optional
#       # arguments (since a user must give a value for mandatory args).
#     puts "$hosts"
#       # Would display "rtr1 rtr2 rtr3".  Notice the LIST_SIZE specification,
#       # which means the parser ensures that there are 3 elements for this
#       # option.
#     puts "$slot"
#       # Would display "2".  Notice the LIST_SIZE specification of 1,
#       # which means the parser ensures that this field only contains 1
#       # value (so it is not really a list).  This is the mechanism to
#       # use if you want to override the default parser functionality of
#       # always allowing lists for every option.
#
#
#   Example 3:  Passing back an array
#
#     set args {-port 5 \
#               -ip 1.1.1.1 \
#               -mode t1}
#     set man_list {-port RANGE 1-10}
#     set opt_list {-ip IP
#                   -mode CHOICES t1 e1}
#     parse_dashed_args -args $args -mandatory_args $man_list\
#         -optional_args $opt_list -return_array blob
#     puts "$blob(port)"
#       # Would display "5".  Notice that instead of a variable being
#       # returned, the array "blob" was now used.  The argument becomes
#       # the array index.
#     puts "$blob(ip)"
#       # Would display "1.1.1.1".
#     puts "$blob(mode)"
#       # Would display "t1".
#     puts "$blob(mandatory_args)"
#       # Would display "-port 5".
#     puts "$blob(optional_args)"
#       # Would display "-ip 1.1.1.1 -mode t1".
#
#
#   Example 4:  Dynamic choices
#
#     set args {-port 5 \
#               -mode t1}
#     set choice_list "t1 e1 atm fr qos"
#     set man_list {-port RANGE 1-10}
#     set opt_list "-ip IP
#                   -mode CHOICES $choice_list
#                         CHOICES eth gige
#                  "
#     # Notice the opt_list above was specified with double quotes, not braces.
#     # This allows TCL to expand any variables in the string, which in this
#     # example will expand the $choice_list to their values.
#     parse_dashed_args -args $args -mandatory_args $man_list\
#         -optional_args $opt_list
#     puts "$port"
#       # Would display "5".
#     puts "$ip"
#       # Would display "1.1.1.1".
#     puts "$mode"
#       # Would display "t1".  
#
#
#   Example 5:  Passing arguments through
#
#     # Be careful when using -passthru option as it could mask
#     # user input errors.
#     set args {-port 5 \
#               -framing sdh \
#               -ip 1.1.1.1 \
#               -mode t1}
#     set man_list {-port RANGE 1-10}
#     set opt_list {-ip IP}
#     parse_dashed_args -args $args -mandatory_args $man_list\
#         -optional_args $opt_list -passthru
#     puts "$port"
#       # Would display "5".
#     puts "$ip"
#       # Would display "1.1.1.1".
#     puts "$mandatory_args"
#       # Would display "-port 5".
#     puts "$optional_args"
#       # Would display "-ip 1.1.1.1"
#     puts "$passthru_args"
#       # Would display "-framing sdh -mode t1".  The passthru_args variable
#       # is only returned when the -passthru option is specified on the
#       # parser call.  A word of caution, by allowing arguments to be
#       # "passed through", the normal error checking for these unknown
#       # arguments is disabled, which means anything can slip through,
#       # including valid options that are mistyped.  The intention of
#       # passthru is that the passthru_args variable would be passed down
#       # to a subsequent procedure, which could then do another round of
#       # parsing.
#
#
#   Example 6:  Error conditions
#
#     set man_list {-port RANGE 1-10}
#     set opt_list {-ip IP}
#
#     parse_dashed_args -args {-ip 1.1.1.1} \
#         -mandatory_args $man_list -optional_args $opt_list
#       # Would generate error that mandatory -port argument is missing
#
#     parse_dashed_args -args {-slot 1 -port 5} \
#         -mandatory_args $man_list -optional_args $opt_list
#       # Would generate error that -slot argument is not allowed,
#       # since it is not in mandatory or optional list
#
#     parse_dashed_args -args {-port 25} \
#         -mandatory_args $man_list -optional_args $opt_list
#       # Would generate error that port value 25 is out of range
#
#     parse_dashed_args -args {-ip 1.2.3 -port 1} \
#         -mandatory_args $man_list -optional_args $opt_list
#       # Would generate error that ip value 1.2.3 is invalid
#
#     check_info -badarg 5
#     procDescr check_info {
#        Usage:
#           check_info -slot <number>      
#     }
#     proc check_info {args} {
#        set man_list {-slot NUMERIC}    
#        parse_dashed_args -args $args -mandatory_args $man_list
#         # This shows the parser being called from within a procedure.
#         # The arguments passed into the procedure call were in error,
#         # (-badarg was used instead of -slot), so the parser would
#         # generate the appropriate error.
#         # In addition, since this call is being made from within a proc,
#         # and the procedure has a procDescr with a Usage section defined,
#         # then a procedure usage message would also be generated.
#         # This is done dynamically via the "cisco_help" utility.
#     }
#
#   Example 7:  Exiting gracefully under error conditions
#
#     set man_list {-port RANGE 1-10}
#     set opt_list {-ip IP}
#
#     if  {[catch {parse_dashed_args -args {-ip 1.1.1.1} \
#                                    -mandatory_args $man_list \
#                                    -optional_args $opt_list} err_msg]} {
#         puts stderr $err_msg
#         exit 1
#     } ;# End of if stmt
#     # The catch cmd would return a non-zero status.
#     # Would generate error that mandatory -port argument is missing.
#     # This error message will be available in $err_msg variable.
#     # The $err_msg will be printed to stderr without the error stack.
#     # The exit cmd will gracefully terminate the script.
#
#   Example 8: Exact vs. closest argument matching
#
#     set man_list {-port RANGE 1-10}
#     set opt_list {-address1 IP -address2 IP -foo ANY -foo1 ANY}
#
#     parse_dashed_args -exact -args {-address1 1.2.3.4 -p 1} \
#         -mandatory_args $man_list -optional_args $opt_list
#       # Would generate error indicating that the -p argument is not found
#       # in the mandatory or optional argument list.
#
#     parse_dashed_args -closest -args {-address1 1.2.3.4 -p 1} \
#         -mandatory_args $man_list -optional_args $opt_list
#       # Would accept the -p argument as equivalent to -port.
#
#     parse_dashed_args -closest -args {-address 1.2.3.4 -p 1} \
#         -mandatory_args $man_list -optional_args $opt_list
#       # Would generate error indicating that -address is ambiguous.
#
#     parse_dashed_args -closest -args {-foo bar} \
#         -mandatory_args $man_list -optional_args $opt_list
#       # Would accept -foo as being an exact, unambiguous match
#
#   Example 9: Using VCMD to verify that a value is an integer
#
#       proc isInteger { value } {
#           if {[string is integer $value]} {
#               return 1
#           } else {
#               return [list 0 "specified value is not an integer"]
#           }
#       }
#       
#       parse_dashed_args -args [list -isinteger notAnInteger] \
#           -mandatory_args {
#              -isinteger VCMD isInteger
#           }
#
#   Example 10: Optional arguments requiring and excluding other optional args
#
#       parse_dashed_args -args $args \
#           -optional_args {
#               -option1    ANY
#                           REQUIRES -option2 -option3
#               -option2    ANY
#                           EXCLUDES -option4
#               -option3    ANY
#               -option3    ANY
#           }
#       # If -option1 is given, -option2 and -option3 must also be given.
#       # If -option2 is given, -option4 must not be given.
#
#   Example 11: Using FLAG type switches with and without values
#
#       set args {
#           -flag2
#           -flag3 0
#           -flag4 true
#           -flag5 false
#       }
#
#       parse_dashed_args -args $args \
#           -optional_args {
#               -flag0      FLAG
#               -flag1      FLAG
#                           DEFAULT 0
#               -flag2      FLAG
#               -flag3      FLAG
#               -flag4      FLAG
#               -flag5      FLAG
#                           DEFAULT 0
#           } -return_direct
#
#     puts "$flag0"
#       # Would generate an error, because without a DEFAULT value
#       # unspecified flags' associated variables are not set.
#     puts "$flag1"
#       # Would display "0" from the DEFAULT.
#     puts "$flag2"
#       # Would display "1".
#     puts "$flag3"
#       # Would generate an error, because without a DEFAULT value
#       # associated variables are not set for false values.
#     puts "$flag4"
#       # Would display "1" because boolean values are converted to 0/1.
#     puts "$flag5"
#       # Would display "0".
#     puts "$optional_args"
#       # Would display "-flag2 -flag4 -flag5 0" because only "true"
#       # flags and "false" flags with DEFAULT values are treated as
#       # having been specified, and only flags (true or false) with
#       # DEFAULT values are treated as having specified a value.
#
#
# Notes:
#   Creation Date: October 19, 2001        
#   Author: Wayne Marquette/Dave Cardosi
# End of Header

proc ::ixia::parse_dashed_args {args} {
    set procName [lindex [info level [info level]] 0]

    set num_args [llength $args]
    if {$num_args < 1} {
        return -code error "\n$procName: Called with no arguments."
    }

    # Initialize vars
    # -----------------------
    set mandatory_flag 0
    set optional_flag 0
    set proc_flag 0
    set mandatory_arg_count 0
    set optional_list ""
    set mandatory_list ""
    set mandatory_arg_count_actual 0
    set process_args ""
    set mandatory_string_actual ""
    set optional_string_actual ""
    set level 1
    set passthru 0
    set no_help 0
    set direct_uplevel 1
    set next_arg_has_brace 0
    set use_closest_match $::tcl_interactive
    set switch_list [list]
    set switches_provided [list]
    set switch_pairings [list]

    set stacklevel [info level] ;# gives the current level of stack
    if {$stacklevel > 1} {
        set calling_proc_name [lindex [info level -1 ] 0]
    } else {
        set calling_proc_name ""
    }

    for { set i 0 } { $i < $num_args } { incr i } {
        set arg [lindex $args $i]
        switch -- $arg {
            -args {
                incr i
                set process_args [lindex $args $i]
            }
            -exact {
                set use_closest_match 0
            }
            -closest {
                set use_closest_match 1
            }
            -mandatory_args {
                incr i
                set mandatory_list [lindex $args $i]
            }
            -optional_args {
                incr i
                set optional_list [lindex $args $i]
            }
            -proc_name {
                # legacy option
                incr i
                set calling_proc_name [lindex $args $i]
            }
            -level {
                incr i
                set level [lindex $args $i]
            }
            -no_help {
                set calling_proc_name ""
            }
            -passthru {
                set passthru 1
            }
            -return_direct {
                set direct_uplevel 1
            }
            -return_array {
                incr i
                set arr_name [lindex $args $i]
                set direct_uplevel 0
            }
            default {
                return -code error "\n$procName: Invalid arg \"$arg\""
            }
        }
    }

    # Parse all mandatory args
    if {($mandatory_list != "") && (![regexp {^ +$} $mandatory_list])} {
        set parse_result [_parse_check_args mandatory $mandatory_list]
        set mandatory_arg_count [keylget parse_result count]
        set mandatory_string [keylget parse_result switch_list]
        foreach value [keylkeys parse_result map] {
            set var_array($value) [keylget parse_result map.$value]
            set mandatory_array($value) 1
            set mandatory_array([keylget parse_result map.$value]) 1
        }
        foreach value [keylkeys parse_result check] {
            set check_array($value) [keylget parse_result check.$value]
        }
    }

    # Parse all optional args
    if {($optional_list != "") && (![regexp {^ +$} $optional_list])} {
        set parse_result [_parse_check_args optional $optional_list]
        set optional_arg_count [keylget parse_result count]
        set optional_string [keylget parse_result switch_list]
        foreach value [keylkeys parse_result map] {
            set var_array($value) [keylget parse_result map.$value]
            set optional_array($value) 1
            set optional_array([keylget parse_result map.$value]) 1
        }
        foreach value [keylkeys parse_result check] {
            set check_array($value) [keylget parse_result check.$value]
        }
        # Uplevel any default values
        if {[regexp {default} [keylkeys parse_result]]} {
            foreach def_switch [keylkeys parse_result default] {
                set def_value [keylget parse_result default.$def_switch]
                # Strip off any surrounding quotes or braces
                if {[regexp {^".*"$} $def_value]} {
                    # Remove surrounding quotes
                    regsub {^"(.*)"$} $def_value {\1} def_value
                } elseif {[regexp {^\{.*\}$} $def_value]} {
                    # Remove surrounding braces
                    regsub {^\{(.*)\}$} $def_value {\1} def_value
                }
                set varname $def_switch
                set default_value($varname) $def_value
                # Change variable name in case of alternate name
                if {[info exists var_array($def_switch)]} {
                    set varname $var_array($def_switch)
                }
                if {$direct_uplevel} {
                    uplevel $level "set $varname {$def_value}"
                } else {
                    uplevel $level "set $arr_name\($varname\) {$def_value}"
                }
            }
        }
    }

    set switch_list [array names check_array]

    # From this point on, we want any error message to look like it
    # came from the calling proc if the user supplied one.  We will
    # prepend the calling proc name and append the calling proc usage.

    # Parse arguments from procs or from command line 
    # and check for valid args
    # ------------------------------------------------
    set num_args [llength $process_args]
    # Loop through arguments for parsing
    for { set i 0 } { $i < $num_args } { incr i } {
        catch {unset check_type}
        set keylist_flag 0
        set string_flag 0
        set other_string_flag 0
        # Grab 1st argument
        set arg [lindex $process_args $i]
        if {[regexp {^-} $arg]} {
            # Remove the dash from the variable
            regsub {^-} $arg {} arg
        } else {
            if {$arg == ""} {
                # Null arg, probably from list being passed thru, so ignore it
                continue
            } else {
                return -code error [_build_parse_error \
                      $calling_proc_name "Illegal\
                      non-dashed argument \"$arg\" found in parsed argument\
                      list."]
            }
        }
        # Initialize arg value as non existant
        if {[info exists value]} {
            unset value
        }

        # Add this argument to the list of "have been provided" arguments
        # for later checking of required/excluded option pairs.

        lappend switches_provided $arg

        # Use glob-style pattern matching to match the provided switch up to
        # a defined/expected switch, if requested or in interactive mode.
        # TODO: refactor to separate procedure once there's a namespace.

        if {$use_closest_match} {
            set opts_matched [lsearch -all -inline -glob $switch_list "$arg*"]

            # If there were multiple possible matches, see if any of them is an
            # exact match.  If not, the argument is ambiguous.

            if {[llength $opts_matched] > 1} {
                set actual_arg [lsearch -inline -exact $opts_matched $arg]

                # actual_arg will be an empty string if no exact match
                # was found.

                if {[string length $actual_arg] == 0} {
                    # Format the ambiguous error message

                    set switch_list [lsort -dict $switch_list]

                    set message "ambiguous option \"-$arg\": must be "
                    append message "-[lindex $switch_list 0]"

                    set switch_list [lrange $switch_list 1 end]

                    while {[llength $switch_list] > 1} {
                        append message ", -[lindex $switch_list 0]"
                        set switch_list [lrange $switch_list 1 end]
                    }

                    append message " or "
                    append message "-[lindex $switch_list 0]"

                    return -code error [_build_parse_error \
                        $calling_proc_name $message]
                }
            } elseif {[llength $opts_matched]} {
                set arg [lindex $opts_matched 0]
            }
        }

        # Grab next argument
        if {$i < [expr {$num_args - 1} ] } {
            set next_arg [lindex $process_args [expr {$i + 1}]]
            # Set flag if next arg had a leading brace, since tcl
            # strips them away
            if {[regexp {^\{} "[lreplace $process_args 0 $i]"]} {
                set next_arg_has_brace 1
            } else {
                set next_arg_has_brace 0
            }
 
            # If the type is a shift, blindly grab the next argument since
            # a shift string can contain anything (including a leading dash)
            if {[info exists check_array($arg)] && \
                    ([regexp -- {-STRING} $check_array($arg)] || \
                     [regexp -- {-SHIFT} $check_array($arg)])} {
                set value $next_arg
                incr i
                # Unset string check type since so we don't go through the
                # check code, which would have problems with complex strings,
                # and there's nothing to check anyway, we already know it's
                # a string
                set check_array($arg) ""
                set string_flag 1
            } else {
                
                if {[info exists check_array($arg)] && \
                    [regexp -- {-LIST_OF_LISTS_NO_TYPE_CHECK} $check_array($arg)]} {
                   set other_string_flag 1
                }       
                
                # Loop until we find next dashed arg or end of args
                # If the arg began with a brace, then we need to treat it as
                # a value because tcl has stripped away the braces, so we 
                # do not want to treat a braced dashed value as a true dashed
                # argument.
                while {![regexp {^-} $next_arg] || $next_arg_has_brace} {
                    # Next argument is the value for this argument.
                    # For single value, just set it, but for multiple values
                    # (meaning a list) use lappend to keep it a list. Note
                    # we cannot use lappend for single value, as this will turn
                    # it into a single element list and introduce extra braces
                    # on the uplevel of passthru, mandatory, and optional args
                    # (which is bad).
                    if {[info exists value]} {
                        if {[info exists check_array($arg)] && \
                            [regexp -- {-LIST_OF_LISTS_NO_TYPE_CHECK} $check_array($arg)]} {
                            append value " $next_arg"
                        } else {
                            lappend value $next_arg
                        }
                    } else {
                        # The value has not been assigned yet, so we know we 
                        # have a single element.  However, if it's length is 2
                        # or more, that means it came in as a braced list
                        # (or even a list of lists), so we need to use lappend
                        # to keep it as a list.  Otherwise for a true single
                        # element, just set it.
                        # First, see if we can use llength to determine length.
                        if {[info exists check_array($arg)] && \
                            [regexp -- {-LIST_OF_LISTS_NO_TYPE_CHECK} $check_array($arg)]} {
                            append value " $next_arg"
                        } elseif {[catch {llength $next_arg} errmsg]} {
                            # The llength operation has failed, which most
                            # likely means the value is a complicated string.
                            # For example, the string: "blah". blah blah 
                            # has something in quotes followed by a dot
                            # followed by other things, which llength would 
                            # blow up on as an invalid list (because
                            # llength sucks).  Anyways, since llength can't 
                            # handle it, that proves whatever it is is not
                            # a valid list, so just treat it as a single value.
                            # The user really should have declared this as a
                            # SHIFT so we could avoid this check.
                            set value $next_arg
                        } elseif {[llength $next_arg] >= 2} {
                            # Keep it as a list
                            lappend value $next_arg
                        } else {
                            # Just a single value
                            set value $next_arg
                        }
                    }
                    incr i
                    if {$i < [expr {$num_args - 1}]} {
                        # More args exists, get next one
                        set next_arg [lindex $process_args [expr {$i + 1}]]
                        # Set flag if next arg had a leading brace, since
                        # tcl strips them away
                        if {[regexp {^\{} "[lreplace $process_args 0 $i]"]} {
                            set next_arg_has_brace 1
                        } else {
                            set next_arg_has_brace 0
                        }
                    } else {
                        # No more args, time to exit loop
                        break
                    }
                } ;# end of while not dashed arg loop
            } ;# end of non-string else
        } ;# end of arg grabbing if code

        # Change the value to use the varname instead of switch name for
        # alternate named arguments
        if {[info exists var_array($arg)]} {
            set var_switch $arg
            set var_name $var_array($arg)
        } else {
            set var_name $arg
        }
                
        # Check for valid value against any user specified check value
        if {[info exists check_array($arg)] && ($check_array($arg) != "")} {
            # Make sure we have a value to check
            if {![info exists value]} {
                # There's no value, so unless it's a flag type, error out
                if {![regexp -- {-FLAG} $check_array($arg)] && ![regexp -- {-VCMD} $check_array($arg)]} {
                    # Null value for non-flag type, throw error
                    return -code error [_build_parse_error $calling_proc_name \
                               "Invalid null value for \"-$arg\"\
                                argument.  Value check type is specified as:\
                                $check_array($arg)"]
                } else {
                    # Null value for flag type, we're done, set to not loop
                    set loop_value ""
                }
            } else {
                set valid_string "$check_array($arg)"
                # Setup for checking values.  For lists, need to loop through
                # each value.  Also setup string for error message based on
                # value type (list or single value).
                # Note: The llength command can fail on complicated strings,
                # so first see if we can use llength to determine length.
                if {[catch {llength $value} errmsg]} {
                    # The llength operation has failed, which most
                    # likely means the value is a complicated string.
                    # For example, the string: "blah". blah blah 
                    # has something in quotes followed by a dot
                    # followed by other things, which llength would 
                    # blow up on as an invalid list (because
                    # llength sucks).  Anyways, since llength can't 
                    # handle it, that proves whatever it is is not
                    # a valid list, and since it was not declared as a SHIFT,
                    # we need to error out now so we don't fail trying to
                    # loop over this value when checking.
                    return -code error [_build_parse_error $calling_proc_name \
                               "Invalid value\
                               \"$value\" for \"-$arg\"\ argument.\n\
                               Valid values are: \"$valid_string\""]
                } elseif {[llength $value] >= 2} {
                    # Value is a list, so loop on value will cycle thru list
                    # and every list value will be checked.
                    set loop_value $value
                    set value_type "list element"
                } elseif {[llength [lindex $value 0]] >= 2} {
                    # Value is a list passed in as single element, so set
                    # to loop on "inside" list to check every list element.
                    # Note: This only works for single inside list, it is
                    # not recursive for multi-lists of lists.  Doubtful
                    # anyone would ever need that anyway (even this is 
                    # rare case).
                    set loop_value [lindex $value 0]
                    set value_type "list element"
                } else {
                    # Value is single value, so will just loop once
                    set loop_value $value
                    set value_type "value"
                }
                # Check for too many values if list size exists
                # Note: Only one LIST_SIZE is allowed, if more are specified
                # then only the first one will be used.
                if {[regexp -- {-LIST_SIZE\:([0-9]+)} $check_array($arg)\
                        - list_size]} {
                    if {$list_size == 0} {
                        return -code error [_build_parse_error \
                                   $calling_proc_name \
                                   "Invalid check value specification:\
                                    $check_array($arg)\n\
                                    The -LIST_SIZE cannot be 0.\
                                    Use the -FLAG specification\
                                    for arguments without values."]
                    }
                    if {[llength $value] != $list_size} {
                        return -code error [_build_parse_error \
                                   $calling_proc_name \
                                   "Incorrect number of values specified for\
                                   \"-$arg\"\ argument.\nThe required list\
                                   size is $list_size, yet [llength $value]\
                                   values were given: \"$value\""]
                    }
                } ;# end of list size check
            } ;# end of value else

            set check_error_str ""
            # Loop through all the values and see if they match at least
            # one user specification for that field
            foreach element $loop_value {
                foreach check_val $check_array($arg) {
                    # Note: If the value is a regexp, the foreach has just
                    # removed all backslash characters.  We deal with
                    # this tcl crappiness later.
                    set check_val [string trim $check_val]
                    # Set the default check type as a regular expression
                    set check_type "REGEXP"
                    # Check for special case known value types
                    if {[regexp {^-} $check_val]} {
                        # Build out regular expression for known types
                        switch -regexp -- $check_val {
                            ^-IPV4$ -
                            ^-IPV6$ -
                            ^-IP$ {
                                # IPv4 is 4 dot separated decimal bytes,
                                # of the form #.#.#.#
                                # Setup v4 byte regexp as:
                                # 0-9 or 00-99 or 000-199 or 200-249 or
                                # 250-255
                                set ipv4byte {([0-9]|[0-9][0-9]}
                                append ipv4byte {|[0-1][0-9][0-9]}
                                append ipv4byte {|2[0-4][0-9]}
                                append ipv4byte {|25[0-5])}
                                set ipv4 "$ipv4byte\\\.$ipv4byte\\\.$ipv4byte"
                                append ipv4 "\\\.$ipv4byte"
                                # IPv6 is 8 colon separated hex bytes (words),
                                # of the form #:#:#:#:#:#:#:#
                                # Setup v6 byte regexp as 1-4 hex chars
                                set ipv6byte {[0-9a-fA-F]{1,4}}
                                # Now setup regexp for v6 address.  V6 allows
                                # shorthand notation of double colon :: 
                                # to represent multiple groups of 0
                                set ipv6 "("
                                # Normal 8 byte address
                                append ipv6 "|(($ipv6byte:){7}$ipv6byte)"
                                # 0 bytes followed by :: followed by 0-6 bytes
                                append ipv6 "|(::($ipv6byte:){0,5}"
                                append ipv6 "($ipv6byte)?)"
                                # 1 byte followed by :: followed by 0-5 bytes
                                append ipv6 "|($ipv6byte\::($ipv6byte:){0,4}"
                                append ipv6 "($ipv6byte)?)"
                                # 2 bytes followed by :: followed by 0-4 bytes
                                append ipv6 "|($ipv6byte:$ipv6byte\::"
                                append ipv6 "($ipv6byte:){0,3}($ipv6byte)?)"
                                # 3 bytes followed by :: followed by 0-3 bytes
                                append ipv6 "|($ipv6byte:$ipv6byte:$ipv6byte"
                                append ipv6 "\::($ipv6byte:){0,2}($ipv6byte)?)"
                                # 4 bytes followed by :: followed by 0-2 bytes
                                append ipv6 "|($ipv6byte:$ipv6byte:$ipv6byte:"
                                append ipv6 "$ipv6byte\::($ipv6byte:){0,1}"
                                append ipv6 "($ipv6byte)?)"
                                # 5 bytes followed by :: followed by 0-1 bytes
                                append ipv6 "|($ipv6byte:$ipv6byte:$ipv6byte:"
                                append ipv6 "$ipv6byte:$ipv6byte\::"
                                append ipv6 "($ipv6byte)?)"
                                # 6 bytes followed by :: followed by 0 bytes
                                append ipv6 "|($ipv6byte:$ipv6byte:$ipv6byte:"
                                append ipv6 "$ipv6byte:$ipv6byte:$ipv6byte\::)"
                                append ipv6 ")"
                                if {[regexp "V4" $check_val]} {
                                    # V4 IP only
                                    set check_val "^$ipv4$"
                                    set valid_string "A v4 format IP address"
                                    append valid_string " (of form #.#.#.#)"
                                } elseif {[regexp "V6" $check_val]} {
                                    # V6 IP only
                                    set check_val "^$ipv6$"
                                    set valid_string "A v6 format IP address"
                                    append valid_string " (of form "
                                    append valid_string "#:#:#:#:#:#:#:#)"
                                } else {
                                    # Any IP (v4 or v6)
                                    set check_val "^($ipv4|$ipv6)$"
                                    set valid_string "An IP address (v4 or v6)"
                                }
                            }
                            ^-MAC$ {
                                # MAC address is of the form xx.xx.xx.xx.xx.xx
                                # (standard 6 byte format) or xxxx.xxxx.xxxx
                                # (3 byte Cisco format)
                                # Note: In the future we could add MAC3 or MAC6
                                # if we need to allow only one type.
                                set cscfmt {[0-9a-f][0-9a-f][0-9a-f][0-9a-f]}
                                append cscfmt {\.[0-9a-f][0-9a-f][0-9a-f]}
                                append cscfmt {[0-9a-f]}
                                append cscfmt {\.[0-9a-f][0-9a-f][0-9a-f]}
                                append cscfmt {[0-9a-f]}
                                set stdfmt {[0-9a-f][0-9a-f]\.}
                                append stdfmt {[0-9a-f][0-9a-f]\.}
                                append stdfmt {[0-9a-f][0-9a-f]\.}
                                append stdfmt {[0-9a-f][0-9a-f]\.}
                                append stdfmt {[0-9a-f][0-9a-f]\.}
                                append stdfmt {[0-9a-f][0-9a-f]}
                                # the colon format was added due to BUG739053
                                set clnfmt {([0-9a-fA-F]{2}:){5}([0-9a-fA-F]{2})}
                                set check_val "^($stdfmt|$cscfmt|$clnfmt)$"
                                set valid_string "MAC address"
                            }
                            ^-RANGE: {
                                if {![regexp -- {-RANGE\:([0-9]+)\-([0-9]+)} \
                                          $check_val - \
                                          low_val high_val]} {
                                    return -code error [_build_parse_error \
                                               $calling_proc_name \
                                               "Invalid check value\
                                               specification:\
                                               $check_array($arg)\n\
                                               Valid RANGE format is:\
                                               \"RANGE #-#\""]
                                }
                                set check_type "RANGE"
                                set valid_string "Number between $low_val and\
                                                 $high_val"
                            }
                            ^-CHOICES: {
                                # Remove keyword
                                regsub -- {-CHOICES\:} $check_val {} \
                                    check_val
                                set valid_string "$check_val"
                                # Put in anchoring around choices
                                regsub -- {^} $check_val {^(} \
                                                              check_val
                                    regsub -- {$} $check_val {)$} \
                                    check_val
                            }
                            ^-KEYLIST$ {
                                # We don't want to check anything for a keyed
                                # list so just null out the check and set flag
                                set check_val ""
                                set keylist_flag 1
                                set valid_string "Keyed list"
                            }
                            ^-FLAG$ {
                                set check_type "FLAG"
                            }
                            ^-DECIMAL$ {
                                # A decimal value
                                set cval1 {[0-9]+\.*[0-9]*}
                                set cval2 {[0-9]*\.*[0-9]+}
                                set check_val "^($cval1|$cval2)$"
                                set valid_string "A decimal value (a number\
                                                  which may contain a decimal\
                                                  point)"
                            }
                            ^-HEX$ {
                                # A hex value, with optional leading 0x
                                set check_val {^(0x)?[0-9a-fA-F]+$}
                                set valid_string "A hexadecimal value (with\
                                                  optional leading \"0x\")"
                            }
                            ^-NUMERIC$ {
                                # A numeric only value
                                set check_val {^[0-9]+$}
                                set valid_string "A numeric value only"
                            }
                            ^-ALPHA$ {
                                # An alphabetic only value
                                set check_val {^[a-zA-Z]+$}
                                set valid_string "An alphabetic value only"
                            }
                            ^-ALPHANUM$ {
                                # An alphanumeric value
                                set check_val {^[a-zA-Z0-9_]+$}
                                set valid_string "An alphanumeric value\
                                                  (letters, numbers,\
                                                   or underbars)"
                            }
                            ^-REGEXP: {
                                # Remove keyword
                                regsub -- {-REGEXP:} $check_val {} \
                                    check_val
                                set valid_string "A value conforming to\
                                                  the regular expression:\
                                                  $check_val"
                            }
                            ^-LIST_OF_LISTS_NO_TYPE_CHECK$ {
                                # Remove keyword
                                set check_val ""
                                set valid_string "A string value is expected"
                            }
                            ^-LIST_SIZE: {
                                if {![regexp -- \
                                          {-LIST_SIZE\:([0-9]+)}\
                                          $check_val - list_size]} {
                                    return -code error [_build_parse_error \
                                               $calling_proc_name \
                                               "Invalid check value\
                                               specification:\
                                               $check_array($arg)\n\
                                               Valid LIST_SIZE format is:\
                                               \"LIST_SIZE #\""]
                                }
                                continue
                            }
                            ^-REQUIRES: -
                            ^-EXCLUDES: {
                                # These directives are ignored until later,
                                # after all arguments have been processed.
                                # But we'll set a flag indicating this
                                # processing needs to be done to avoid the
                                # overhead of re-processing this check info
                                # when these are not in use.

                                set mode [string range $check_val 1 8]
                                set mode [string tolower $mode]
                                set check_val [string range $check_val 10 end]
                                set check_val [split $check_val |]

                                foreach check_val $check_val {
                                    lappend switch_pairings \
                                        $arg $mode $check_val
                                }
                                set check_val ""
                                continue
                            }
                            ^-VCMD: {
                                set check_val [string range $check_val 6 end]
                                set check_type "VCMD"
                            }
                            default {
                                return -code error [_build_parse_error \
                                           $calling_proc_name \
                                           "Invalid check value\
                                            specification: Check type\
                                            \"$check_val\" is unknown."]
                            }
                        } ;# end of switch
                    } else {
                        # Not a known check type, must be a regexp
                        # For regexp, we need to set the check_val back to
                        # its original value directly from the check_array,
                        # since the foreach function above has removed any
                        # backslashes from the regexp (because tcl is crap).
                        # Note this only works for newer line format, old
                        # regexp format cannot handle backslashes.
                        set check_val $check_array($arg)
                        # Setup error msg with correct user regexp criteria
                        set valid_string "A value conforming to the regular\
                                          expression: $check_val"
                    }
                    
                    # Check if value matches user specified check criteria
                    # Check individual element
                    if {$check_type == "RANGE"} {
                        # Add decimal point to range values so large
                        # numbers can be handled.
                        # Without decimal, highest number handled is
                        # 2147483647 (just in case you wondered)
                        set low_val $low_val.0
                        set high_val $high_val.0
                        if {![regexp {\.} $element]} {
                            # Add decimal to user value
                            set temp_element $element.0
                        } else {
                            # User value already has decimal
                            set temp_element $element
                        }
                        if {($temp_element < $low_val) || \
                                ($temp_element > $high_val)} {
                            append check_error_str\
                                "\n[_build_parse_error $calling_proc_name \
                                  "Invalid $value_type\
                                \"$element\" for \"-$arg\"\ argument.\n\
                                Valid values are: \"$valid_string\""]"
                        } else {
                            set check_error_str ""
                            break
                        }
                    } elseif {$check_type == "FLAG"} {
                        # A flag type should have either no value or
                        # any boolean value (e.g. 0, 1, true, false, yes, no)
                        # It does not allow more than one value to be
                        # provided.

                        if {[info exists value] && \
                                ![string is boolean $value]} {
                            append check_error_str\
                                "\n[_build_parse_error $calling_proc_name \
                                "Invalid $value_type \"$element\" for\
                                \"-$arg\" argument.\nValid values are:\
                                \"0|1|true|false|yes|no\""]"
                        } else {
                            set check_error_str ""
                            break
                        }
                    } elseif {$check_type == "VCMD"} {
                        # Use the defined command to validate the value.

                        if {[catch { set vcmd_out [uplevel $level \
                                [list $check_val $element]] } \
                                vcmd_msg]} {

                            return -code error [_build_parse_error \
                                $calling_proc_name $vcmd_msg]
                        }

                        # If the first element is false, then it is invalid.

                        if {![lindex $vcmd_out 0]} {
                            append check_error_str\
                                "\n[_build_parse_error $calling_proc_name \
                                    "Invalid $value_type\
                                    \"$element\" for \"-$arg\" argument"]"

                            # If a reason was provided by the vcmd,
                            # include it in the error message.
                            if {[llength $vcmd_out] > 1} {
                                append check_error_str \
                                    ": [lindex $vcmd_out end]"
                            }
                        } else {
                            set check_error_str ""
                            break
                        }
                    } else {
                        if {![regexp "$check_val" $element]} {
                            append check_error_str\
                                "\n[_build_parse_error $calling_proc_name \
                                  "Invalid $value_type\
                                \"$element\" for \"-$arg\"\ argument.\n\
                                Valid values are: \"$valid_string\""]"
                        } else {
                            set check_error_str ""
                            break
                        }
                    }
                } ;# end of check type loop
                # Break out of loop if any criteria passed
                if {$check_error_str != ""} {
                    return -code error "$check_error_str"
                }
            } ;# end of element check loop
        } ;# end of check array if

        if {[info exists check_type] && ($check_type == "FLAG")} {
            # When the FLAG has no associated DEFAULT value, we want to
            # treat "false" values as having not been specified at all
            # and "true" values as having been specified only with the
            # switch (no value), for backwards-compatibility.
            # [CSCeh94732]

            if {![info exist default_value($arg)]} {
                if {!$value} {
                    continue
                }

                unset value
            } else {
                # Convert yes/no/true/false to 1/0
                set value [expr {1 && $value}]
            }
        }

        # Check if arg is mandatory
        # --------------------- --------------------------------
        if {[info exists mandatory_array($arg)]} {
            # Check for duplicate mandatory args being passed
            if {[lsearch -exact $mandatory_string_actual $arg]>=0} {
                return -code error "$procName:\
                Duplicate argument found.  The mandatory argument\
                \"$arg\" was specified twice."
            }
            incr mandatory_arg_count_actual
            append mandatory_string_actual " $arg"
            # Append mandatory args to variable for later upleveling
            if {[info exists mandatory_args]} {
                append mandatory_args " -$arg"
            } else {
                # Initial set, no leading space
                set mandatory_args "-$arg"
            }
            if {[info exists value]} {
                append mandatory_args " $value"
            }
        } elseif {![info exists optional_array($arg)]} {
            # Not mandatory or optional, check for pass thru
            if {$passthru} {
                # Append pass through args to variable for later upleveling
                if {[info exists passthru_args]} {
                    append passthru_args " -$arg"
                } else {
                    # Initial set, no leading space
                    set passthru_args "-$arg"
                }
                if {[info exists value]} {
                    append passthru_args " $value"
                }
                # Parse next arg
                continue
            } else {
                return -code error [_build_parse_error \
                      $calling_proc_name "Argument\
                      \"-$arg\" not found in mandatory or optional argument\
                       list."]
            }
        } else {
            # Check for duplicate optional args being passed
            if {[lsearch -exact $optional_string_actual $arg]>=0} {
                return -code error "$procName:\
                Duplicate argument found.  The optional argument\
                \"$arg\" was specified twice."
            }
            append optional_string_actual " $arg"
            # Append optional args to variable for later upleveling
            if {[info exists optional_args]} {
                append optional_args " -$arg"
            } else {
                # Initial set, no leading space
                set optional_args "-$arg"
            }
            if {[info exists value]} {
                append optional_args " $value"
            }
        }
        # Uplevel appropriately
        if {![info exists value]} {
            # Uplevel flag switches with value of 1
            if {$direct_uplevel} {
                uplevel $level "set $var_name 1"
            } else {
                uplevel $level "set $arr_name\($var_name\) 1"
            }
        } elseif {$string_flag} {
            # A string could have all kinds of special characters, so
            # just brace it and uplevel.
            if {$direct_uplevel} {
                uplevel $level "set $var_name {$value}"
            } else {
                uplevel $level "set $arr_name\($var_name\) {$value}"
            }
        } elseif {$other_string_flag} {
            
            # A string could have all kinds of special characters, so
            # just brace it and uplevel.
            if {$direct_uplevel} {
                if {[regexp {^\{\{} $value] && ([llength $value] == 1)} {
                    uplevel $level "set $var_name {{$value}}"
                } elseif {[regexp {^\{\{} $value] && ([llength $value] >= 2)} {
                    uplevel $level "set $var_name {$value}"
                } elseif {[regexp {^\{} $value] && ([llength $value] >= 2)} {
                    uplevel $level "set $var_name {$value}"
                } else {
                    uplevel $level "set $var_name {$value}"
                }
            } else {
                if {[regexp {^\{\{} $value] && ([llength $value] == 1)} {
                    uplevel $level "set $arr_name\($var_name\) {{$value}}"
                } elseif {[regexp {^\{\{} $value] && ([llength $value] >= 2)} {
                    uplevel $level "set $arr_name\($var_name\) {$value}"
                } elseif {[regexp {^\{} $value] && ([llength $value] >= 2)} {
                    uplevel $level "set $arr_name\($var_name\) {$value}"
                } else {
                    uplevel $level "set $arr_name\($var_name\) {$value}"
                }
            }
        } else {
            # Uplevel the value.  If the value is a multi-element list (or
            # list of lists, etc.) we need to brace it so the set works 
            # correctly, and uploads as a list.
            # If the value is a single element, it could be a single value,
            # a single list, or a single list of lists, etc.  If we brace 
            # a list, we in essence turn it into a value rather than keeping
            # it as a list, so we cannot brace it to avoid this problem.
            # First, see if we can use llength to determine length.
            if {[catch {llength $value} errmsg]} {
                # The llength operation has failed, assume it's a complex
                # string, surround in braces to avoid any set syntax error,
                # and just uplevel it
                if {$direct_uplevel} {
                    uplevel $level "set $var_name {$value}"
                } else {
                    uplevel $level "set $arr_name\($var_name\) {$value}"
                }
            } elseif {[llength $value] >= 2} {
                # Multi-element list, must be braced to avoid set syntax error
                if {$direct_uplevel} {
                    uplevel $level "set $var_name {$value}"
                } else {
                    uplevel $level "set $arr_name\($var_name\) {$value}"
                }
            } else {
                # Single value, no brace unless special keyed list case
                if {($keylist_flag) && (![regexp {^\{\{} $value])} {
                    # A keyed list is a special case.  If it has exactly one
                    # key/value pair (as is this case) then it looks exactly
                    # like a list, however it must be uploaded as a single
                    # braced element, otherwise key operations (keylget, etc.)
                    # will fail.  A keyed list with a single key/value pair
                    # will only have one leading brace, whereas a keyed
                    # list with many key/value pairs has double leading
                    # braces already.  For this single case, we need
                    # to add in extra surrounding braces.
                    if {$direct_uplevel} {
                        uplevel $level "set $var_name {$value}"
                    } else {
                        uplevel $level "set $arr_name\($var_name\) {$value}"
                    }
                } else {
                    # Uplevel single value as is
                    if {$value == ""} {
                        # Need to brace a null value
                        if {$direct_uplevel} {
                            uplevel $level "set $var_name {}"
                        } else {
                            uplevel $level "set $arr_name\($var_name\) {}"
                        }                        

                    } else {
                        if {$direct_uplevel} {
                            if {[catch {uplevel $level "set $var_name $value"}\
                                     errmsg]} {
                                # The uplevel has failed, assume it's a complex
                                # string (such as with CR chars), surround in 
                                # braces to avoid any set syntax error, and try
                                # again.  If it fails again, we're dead.
                                # Note that for a string that ends in CR, the
                                # CR would be lost if upleveled without
                                # braces, yet no error is given.  This is
                                # tough luck for users who do not tell us it
                                # is a string.
                                uplevel $level "set $var_name {$value}"
                            }
                        } else {
                            if {[catch {uplevel $level\
                                        "set $arr_name\($var_name\) $value"}\
                                     errmsg]} {
                                uplevel $level \
                                    "set $arr_name\($var_name\) {$value}"
                            }
                        }
                    }
                } ;# end of single value uplevel else
            } ;# end of single value else
        } ;# end of uplevel else
    } ;# end of parse argument loop

    # Check mandatory arg count matches required count
    # -------------------------------------------------------------
    if {$mandatory_arg_count && \
       ($mandatory_arg_count_actual != $mandatory_arg_count)} {
        return -code error [_build_parse_error $calling_proc_name \
              "Missing mandatory arguments\n\
              Expected: $mandatory_string\nActual:\
              $mandatory_string_actual"]
    }

    # Check for required/excluded argument pairings, if indicated in
    # the option specification.

    foreach { arg1 mode arg2 } $switch_pairings {

        # Check to see if the required/excluded argument was
        # even defined within the option specification.

        if {[lsearch -exact $switch_list $arg2] == -1} {
            return -code error [_build_parse_error \
                $calling_proc_name \
                "option \"-$arg1\" $mode option \"-$arg2\",\
                    which is not defined in the option spec."]
        }

        # Check to see if the pairing rule were met

        switch -- $mode {
            "requires" {
                if {[lsearch -exact $switches_provided $arg2] == -1} {
                    return -code error [_build_parse_error \
                        $calling_proc_name \
                        "option \"-$arg1\" requires option\
                            \"-$arg2\", which was not provided."]
                }
            }
            "excludes" {
                # Check for options excluding themselves, which would
                # be an impossible requirement to meet.

                if {$arg1 == $arg2} {
                    return -code error [_build_parse_error \
                        $calling_proc_name \
                        "option \"-$arg1\" cannot exclude its self."]
                }
                    
                # Check for mandatory options excluding other mandatory
                # options, which would be a conflict.

                if {[lsearch -exact [array names mandatory_array] \
                        $arg2] != -1} {

                    return -code error [_build_parse_error \
                        $calling_proc_name \
                        "option \"-$arg1\" cannot exclude mandatory option\
                            \"-$arg2\"."]
                }
                    
                if {[lsearch -exact $switches_provided $arg2] != -1} {
                    return -code error [_build_parse_error \
                        $calling_proc_name \
                        "option \"-$arg2\" cannot be used with option\
                            \"-$arg1\"."]
                }
            }
        }
    }

    if {$direct_uplevel} {
        if {[info exists optional_args]} {
            uplevel $level "set optional_args {$optional_args}"
        } else {
            uplevel $level "set optional_args {}"
        }
        if {[info exists mandatory_args]} {
            uplevel $level "set mandatory_args {$mandatory_args}"
        } else {
            uplevel $level "set mandatory_args {}"
        }
        if {$passthru} {
            if {[info exists passthru_args]} {
                uplevel $level "set passthru_args {$passthru_args}"
            } else {
                uplevel $level "set passthru_args {}"
            }
        }
    } else {
        if {[info exists optional_args]} {
            uplevel $level "set $arr_name\(optional_args\) {$optional_args}"
        } else {
            uplevel $level "set $arr_name\(optional_args\) {}"
        }
        if {[info exists mandatory_args]} {
            uplevel $level "set $arr_name\(mandatory_args\) {$mandatory_args}"
        } else {
            uplevel $level "set $arr_name\(mandatory_args\) {}"
        }
        if {$passthru} {
            if {[info exists passthru_args]} {
               uplevel $level "set $arr_name\(passthru_args\) {$passthru_args}"
            } else {
               uplevel $level "set $arr_name\(passthru_args\) {}"
            }
        }
    }

}


##Internal Procedure Header
#
# Name:
#   ::ixia::_parse_check_args
#
# Purpose:
#
# Synopsis:
#   ::ixia::_parse_check_args <argtype> <arglist>
#
# Arguments:
#   <argtype> = optional|mandatory
#   <arglist> = list of argument specifications
#
# Return Values:
#   Keylist with the following keys:
#     count            = number of switch arguments found
#     switch_list      = space separated string of switch arguments 
#     check.<switch>   = check string for dashed switch argument
#     check.<varname>  = check string for alternate switch variable
#                        name (may be same as switch)
#     map.<switch>     = varname, allows mapping of switch key
#                        to variable name (alternate or same)
#     default.<switch> = default value for dashed switch argument
#
# Description:
#   Internal procedure to parse the mandatory or optional argument
#   specifications.  Specification is either in "line" or "block"
#   format.  Line format should always be used, however legacy code
#   still uses the older block format, therefore we must support it.
#   Documentation on block format has been removed from the main
#   procedure usage so users are no longer aware of it.  For posterity,
#   it has been placed here for reference. 
#
#   Legacy Block Format Documentation:
#     Block format is as follows:
#       <argname>[:<varname>][<<check_value>>]
#       Breakdown:
#         - The <argname> is the name of the dashed argument 
#           (with or without the dash).  It is required.
#         - The colon separated <varname> is optional.  If specified,
#           then it will be used as the variable name upleveled to the
#           callers context, instead of the argname.  In most cases
#           this should be avoided if possible.
#         - The <<check_value>> is an optional regular expression 
#           used to check against the parsed value.  If specified, it
#           must be enclosed in angle brackets <>.  If the parsed 
#           value for an argument does not match the check value 
#           regular expression, an error is thrown.  Note that
#           if the parsed value is a list, then the check is done
#           for each element of the list.
#           In addition to a regular expression check, a set of
#           customized check values are available, which are essentially
#           shorthand types for complicated regular expressions.
#           These are specified by a leading dash "-" on the check_value,
#           and are as follows:
#             -IP
#                An IP address, either v4 (dotted decimal notation) or
#                v6 (colon hexadecimal notation).
#             -MAC
#                A MAC address, in standard or Cisco format.
#             -RANGE:<low_value>-<high_value>
#                A numeric range, between low_value and high_value.
#             -CHOICES:<choice1>|<choice2>|<choice3>... 
#                A list of choice values logically or'ed together.
#             -KEYLIST 
#                A TCL keyed list.
#             -STRING
#                An alphanumeric string.
#             -NUMERIC
#                A numeric only value.
#             -FLAG
#                A flag argument, meaning this argument does not have
#                any value and is a stand-alone argument.
# End of Header

proc ::ixia::_parse_check_args {argtype arglist} {
    # Hardcode proc name to match parser
    set procName "parse_dashed_args"
    set arg_count 0
    set keylist {}

    # Strip away any leading or trailing whitespace in arglist
    set arglist [string trim $arglist " \n\r\t"]
    # Replace any tabs with spaces, as tabs would be interpreted as arguments
    regsub -all "\t" $arglist " " arglist
    # Determine if line (new) or block (old) format.
    # If newline present then must be new format, however also
    # need to cover case for single line new format so do that by 
    # looking for all caps type after argument
    if {[regexp {\n} $arglist] || \
        [regexp {^-[^ ]+ +[A-Z]} $arglist]} {
        # Line format (each arg on a separate line) as:
        #  -switch_name:alt_name data_type data_fields
        #                  data_type data_fields
        #                        ...
        # Details:
        # -switchname  = dashed switch argument  (ex. -slot)
        # alt_name     = alternative variable name and switch name
        # data_type    = all caps data type (ex. NUMERIC, RANGE, etc.)
        # data_fields  = fields required by data_type, different for each

        set lines [split $arglist \n]
        foreach line $lines {
            set line [string trim $line]
            if {[regexp {^-} $line]} {
                # Found a switch, increment switch count
                incr arg_count
                # Remove leading dash
                regsub {^-} $line {} line
                # Set switch name and variable name as same
                # Note: Need to use regexp to pull off the switch, cannot
                # use shift or lvarpop commands because they insert braces
                # around special list elements (because tcl is crap)
                regexp {^([^ ]+) *(.*)} $line - var_switch line
                set var_name $var_switch
                # Check for alternate name
                if {[regexp {:} $var_switch]} {
                    # Set switch and variable name different
                    set split_var [split $var_switch {:}]
                    set var_switch [lindex $split_var 0]
                    set var_name [lindex $split_var 1]
                }
                # Check for duplicate switch
                if {[regexp {map} [keylkeys keylist]]} {
                    if {[lsearch -exact "[keylkeys keylist map]"\
                             $var_switch] >= 0} {
                        return -code error "\n$procName: Duplicate $argtype\
                            argument found: \"$var_switch\""
                    }
                }
                append switch_list " $var_switch"
                set check_value ""
            } 
            
            # Grab data type
            set type ""
            regexp {^([^ ]+) *(.*)} $line - type line
            if {$type == "DEFAULT"} {
                # Make sure we found a switch previously
                if {$arg_count == 0} {
                    return -code error "\n$procName: Type $type found with\
                        no corresponding dashed switch argument"
                }
                # Set default value
                keylset keylist default.$var_switch $line
            } elseif {$type != ""} {
                # Make sure we found a switch previously
                if {$arg_count == 0} {
                    return -code error "\n$procName: Type $type found with\
                        no corresponding dashed switch argument"
                }
                append check_value " -$type"
                switch -exact -- $type {
                    ANY -
                    SHIFT -
                    LIST_OF_LISTS_NO_TYPE_CHECK -
                    IP -
                    IPV4 -
                    IPV6 -
                    MASK -
                    MAC -
                    ALPHANUM -
                    ALPHA -
                    NUMERIC -
                    DECIMAL -
                    HEX -
                    KEYLIST -
                    FLAG {
                        # These types take no arguments, make sure nothing
                        # extra on line
                        if {[regexp {[^ ]} $line]} {
                            return -code error "\n$procName: Invalid check\
                              value specification: The check type \"$type\"\
                              allows no further arguments, yet \"$line\"\
                              was found following the type."
                        }
                        if {$type == "MASK"} {
                            # This is a combination of IP and NUMERIC, so
                            # just convert to those
                            regsub -- {-MASK} $check_value {-IP -NUMERIC}\
                                check_value
                        }
                        if {$type == "ANY"} {
                            # This is the same as no type, so get rid of it
                            set check_value ""
                        }
                    }
                    CHOICES {
                        # Desired format: -CHOICES:a|b|c
                        append check_value ":"
                        regsub -all { +} $line { } line
                        regsub -all { } $line {|} choices
                        append check_value $choices
                    }
                    REGEXP {
                        set check_value $line
                    }
                    RANGE {
                        # Desired format: -RANGE:1-25
                        append check_value ":"
                        if {[regexp {\-} $line]} {
                            regsub -all { } $line {} line
                        } else {
                            regsub -all { } $line {-} line
                        }
                        append check_value $line
                    }
                    LIST_SIZE {
                        # Desired format: -LIST_SIZE:1
                        append check_value ":"
                        regsub -all { } $line {} line
                        append check_value $line
                    }
                    REQUIRES -
                    EXCLUDES {
                        # These types take a single argument that must be
                        # the name of another switch.
                        # Desired format: -REQUIRES:arg|arg|arg
                        # or -EXCLUDES:arg|arg|arg

                        append check_value ":"

                        set line [string trim $line]
                        set pair_args [list]

                        foreach pair_arg $line {
                            if {[string index $pair_arg 0] == "-"} {
                                set pair_arg [string range $pair_arg 1 end]
                            }
                            lappend pair_args $pair_arg
                        }

                        append check_value [join $pair_args |]
                    }
                    VCMD {
                        append check_value ":$line"
                    }
                    default {
                        return -code error "\n$procName: Invalid check value\
                              specification: Check type \"$type\"\
                              is unknown."
                    }
                }
            }
            # Set return keys
            keylset keylist check.$var_switch $check_value
            keylset keylist check.$var_name $check_value
            keylset keylist map.$var_switch $var_name
        }
    } else {
        # Block format (args in a single space separated block)
        foreach arg $arglist {
            catch {unset def_value}
            # Check for invalid argument (to catch extra space between argument
            # and check-value notation)
            if {[regexp {^<} $arg]} {
                # Argument begins with check symbol, probably extra space typo
                return -code error "\n$procName: Invalid argument \"$arg\".\
                   This is probably a check-value notation with an extra \
                   space in front of it.\
                   Please remove any spaces between the argument and the\
                   check-value notation."
            }
            # Remove any leading dashes
            regsub {^-} $arg {} arg
            set check_value ""
            set check_values ""
            # Save any specified value check (between <> symbols)
            if {[regexp {<.+>$} $arg]} {
                # Save everything between braces <>
                regsub {^.+<} $arg {} check_values
                regsub {>$} $check_values {} check_values
                # Remove check value from argument
                regsub {<.+>$} $arg {} arg
                # Split on comma and loop through all variables
                set check_value_list [split $check_values ,]
                set check_values ""
                foreach check_value $check_value_list {
                    set check_value [string trim $check_value]
                    if {![regexp {^-} $check_value]} {
                        set check_value "-REGEXP:$check_value"
                    }
                    if {[regexp {^-MASK} $check_value]} {
                        # This is a combination of IP and NUMERIC, so
                        # just convert to those
                        append check_values " -IP -NUMERIC"
                    } elseif {[regexp {^-DEFAULT:} $check_value]} {
                        # This is not a check type, so just set default value
                        regsub -- {-DEFAULT:} $check_value {} def_value
                    } elseif {([regexp {^-DECIMAL} $check_value]) || \
                            ([regexp {^-HEX} $check_value])} {
                        # These new types and only allowed in the new format
                        return -code error "\n$procName: Invalid check value\
                              specification: Check type \"$check_value\"\
                              is not allowed with legacy format.  Please\
                              use correct format for this check type."
                    } else {
                        append check_values " $check_value"
                    }
                }
            }

            # Save the var name in array if the switch and var name not same
            if {[regexp {:} $arg]} {
                set split_arg [split $arg {:}]
                set var_switch [lindex $split_arg 0]
                set var_name [lindex $split_arg 1]
                regsub {^-} $var_name {} var_name
                set var_array($var_switch) $var_name
            } else {
                set var_switch $arg
                set var_name $arg
            }

            # Check for duplicate switch
            if {[regexp {map} [keylkeys keylist]]} {
                if {[lsearch -exact "[keylkeys keylist map]" \
                        $var_switch] >= 0} {
                    return -code error "\n$procName: Duplicate $argtype\
                        argument found: \"$var_switch\""
                }
            }
            keylset keylist check.$var_switch $check_values
            keylset keylist check.$var_name $check_values
            keylset keylist map.$var_switch $var_name    
            if {[info exists def_value]} {
                keylset keylist default.$var_switch $def_value
            }
            append switch_list " $var_switch"
            incr arg_count
        }
    }
    keylset keylist switch_list $switch_list
    keylset keylist count $arg_count
    return $keylist
}

##Internal Procedure Header
#
# Name:
#   ::ixia::_build_parse_error
#
# Synopsis:
#   ::ixia::_build_parse_error <proc-name> <msg>
#
# Arguments:
#   <proc-name>
#         The calling proc name (can be null if not supplied)
#   <msg>
#         Error message
#
# Return Values:
#   Error string.
#
# Description:
#         Internal procedure for building a parser error string with the
#         appropriate calling proc name and usage, allowing the error to look
#         like it came from the calling proc instead of the parser.
#     Author: Dave Cardosi
#     Date: May 2, 2003
#
# Examples:
#   error [_build_parse_error $calling_proc_name \
#          "Missing mandatory arguments"]
#
# End of Header

proc ::ixia::_build_parse_error {calling_proc_name msg} {

    # If calling proc name is available, and cisco_help proc is defined,
    # then build the appropriate return message with usage info, otherwise
    # just return parser name without usage.
    if {($calling_proc_name == "") || (![llength [info proc cisco_help]])} {
        # Hard code parser procname without usage for direct parser call
        set error_string "parse_dashed_args: $msg"
    } else {
        # Build string with calling proc name and usage
        # Add leading :: due to bug CSCdx82291
        set calling_proc_usage [cisco_help +verbose \
                                    proc "\^(::)*$calling_proc_name$"]
        if {![regexp {^no help for} $calling_proc_usage]} {
            # Strip off everything from help except usage statement
            if {[regexp -nocase {Usage} $calling_proc_usage]} {
                regsub -nocase {^.*Usage} $calling_proc_usage {Usage} \
                    calling_proc_usage
                regsub "\[\n\r\] *\[\n\r\].*" $calling_proc_usage "\n" \
                    calling_proc_usage
            }
            set error_string "$calling_proc_name: $msg \n$calling_proc_usage"
        } else {
            set error_string "$calling_proc_name: $msg "
        }
    }
    return $error_string
}


# $Log: parse_dashed_args.tcl,v $
# Revision 1.24.2.3  2005/10/24 19:31:21  mkirkham
# DDTS Number: CSCsc27093
# Reviewed By: hlavana
# Change Description: Using LIST_SIZE with other types suppressed checks
# of those other types, rather than requiring the specified number of items
# of one of those types.
#
# Revision 1.24.2.2  2005/10/20 20:40:08  mkirkham
# DDTS Number: CSCej31515
# Reviewed By: hlavana
# Change Description:
# Corrected a regression introduced by CSCeh94732 that caused because the FLAG
# type to be exclusive of all other types.
#
# Revision 1.24.2.1  2005/08/31 19:18:42  mkirkham
# DDTS Number: CSCej02630
# Reviewed By: hlavana
# Change Description: Corrected a regression issue whereby the ANY type
# (or unspecified type) arguments would generate an error if given a
# string that could not be converted to a list.  Tests were added for ANY
# type, including for this DDTS.  The other existing tests were changed
# to the style of more recent tests added for other.  packages (wrapping
# in a namespace, requiring tcltest 2.2)
#
# Revision 1.24  2005/06/28 21:42:32  hlavana
# DDTS Number: CSCei32063
# Change Description:
# Itramp should track real usage via API invocation rather than [package require].
#
# Revision 1.23  2005/05/31 21:33:43  mkirkham
# DDTS Number: CSCeh94732
# Change Description: Enhanced the handling of FLAG type arguments, which
# previously accepted no value, to optionally accept any boolean value
# (0, 1, true, false, yes or no).  To remain compatible, "false" values are
# only returned and the optional_args value populated if such switches have
# a DEFAULT value, and values are returned as either 0 or 1.
#
# Revision 1.22  2005/05/13 17:24:10  mkirkham
# DDTS Number: CSCeh07511
# Reviewed by: hlavana
# Change Description: Two new keywords, REQUIRES and EXCLUDES, were added to
# parse_dashed_args to support specifications where some options must or must
# not be used with other options.  Each instance of either keyword can take
# one or more arguments to require or exclude.
#
# Revision 1.21  2005/05/13 16:42:41  mkirkham
# DDTS Number: CSCeh07740
# Reviewed by: hlavana
# Change Description: A new keyword was added, VCMD, which can be used to
# specify a procedure to be invoked from the parse_dashed_args caller's
# scope to validate an argument value externally.  The procedure takes one
# argument (the value) and can return either any boolean or a boolean and
# a failure message as a list.
#
# Revision 1.20  2005/05/11 22:48:54  mkirkham
# DDTS Number: CSCeh07751
#
# Reviewed by: hlavana
#
# Change Description: Options were added to parse_dashed_args was to support
# two different modes of matching switches provided with the -args option to the
# -mandatory_args and -optional_args specifications: -exact and -closest.
# In -exact mode, the argument must match exactly.  In -closest mode, the
# closest unambiguous match will be allowed (as in "-p" provided for "-port").
# The default is -closest when Tcl is running in interactive mode
# ($::tcl_interactive == 1) and -exact otherwise.
#
# Revision 1.19  2005/02/16 22:07:45  vjeyem
# DDTS Number:CSCeh08427
# Change Description:
# Added the fixed for the bug where parse will fail if the mandatory
# or optional arguments are on the same line as the leading brace.
#
# Revision 1.18  2005/02/07 19:38:36  hlavana
# DDTS Number: CSCeh06893
# Change Description:
# Replaced "error <string>" with "return -code error <string>"
#
# Revision 1.17  2005/01/20 21:55:51  dcardosi
# Change Description: Added new HEX check type.  Fixed problem so multiple
# RANGE types now allowed.  Fixed problem so alternate name properly set
# with default value.  Add code so cisco_help call is now conditional, which
# allows future removal of Cisco package dependency. Converted all
# documentation to new Autocat compatible format, and updated and added 
# examples.
# Reviewed by: wmarquet
#
# Revision 1.16  2004/11/05 16:07:28  dcardosi
# Change Description: Fixed issue where backslash was getting lost
# for the REGEXP specification.
# Reviewed by: wmarquet
#
# Revision 1.15  2004/08/25 22:36:28  dcardosi
# Reviewed by: jgeorgs
#
# Change Description: Added DECIMAL and ANY check types. Removed STRING type
# and replaced with SHIFT type to reflect it's true nature and to avoid users
# choosing STRING arbitrarily.
# Note: This is not backward compatible, we fully expect some current uses
# of STRING type to be rejected.  We believe the scope is very limited and
# therefore want to force these changes now before they become widespread.
#
# Revision 1.14  2004/08/19 18:44:59  dcardosi
# Reviewed by: wmarquet
#
# Change Description: Updated to ignore tabs in check specifications.
#
# Revision 1.13  2004/08/11 22:04:51  dcardosi
# Reviewed by: wmarquet
#
# Change Description: Changed returned passthru_args, mandatory_args, and
# optional_args to use straight append instead of lappend to solve issues
# with extra braces being upleveled.
#
# Revision 1.12  2004/07/30 19:43:36  dcardosi
# Reviewed by: wmarquet
#
# Change Description: Fixed to allow RANGE type to handle large values.
#
# Revision 1.11  2004/07/19 15:12:38  dcardosi
# Reviewed by: wmarquet
#
# Change Description: Added new ALPHA and ALPHANUM check types, and changed
# LIST_LIMIT to LIST_SIZE for more accurate functionality.
#
# Revision 1.10  2004/06/08 15:11:32  dcardosi
# Reviewed by: wmarquet
# Change Description: Fixed the IP check type to correctly verify V4 and
# V6 formatted IP addresses via the use of an amazing single regexp that
# goes beyond anything ever thought possible within tcl.
# Added new IPV4 and IPV6 check types.
# Fixed the documentation for REGEXP, updated examples, and added dummy
# procDescr for internal procs so autocat does not diplay them.
#
# Revision 1.9  2004/05/21 14:29:56  dcardosi
# Reviewed by: wmarquet
# Change Description: Documentation change only.  Updated usage to
# remove "block" format (moved to internal proc) since we want to
# use "line" format only going forward.
#
# Revision 1.8  2004/04/27 13:23:12  dcardosi
# Change Description: Updated to strip off any surrounding quotes or braces
#  on any default values (not just null or space).
# Reviewed by: wmarquet
#
# Revision 1.7  2004/04/21 21:19:27  dcardosi
# Reviewed by: wmarquet
# Change Description: Fixes to skip over null or blank arg lists, and
# to properly set null or blank default values.
#
# Revision 1.6  2004/04/21 15:24:41  dcardosi
# Reviewed by: wmarquette
#
# Change Description: Added trim of whitespace for older format arguments
#
# Revision 1.5  2004/04/21 14:03:49  dcardosi
# Reviewed by: Wayne Marquette
# Change Description:
# Many new features added:
#  -A new, easy to read single line format (no more cryptic check syntax)
#  -Multiple check types now allowed (ex. a range 1-7 or a value "off")
#  -Default values can now be set for optional args (no need to set each
#   variable beforehand)
#  -List limit feature (can specify maximum list lengths or single value only)
#  -New MASK check type added
#  -Values can be returned as an array (instead of current variable only method)
#
#
# Revision 1.4  2004/04/03 00:07:23  nkapur
# Change Description:
# Corrected name of library that was inadvertently changed during testing 
# of autocat
#
# Revision 1.3  2004/04/01 03:57:21  cms
# Commiting Files
#
# Revision 1.2  2004/02/09 16:49:06  dcardosi
# Reviewed by: Jurgen
# Change Description:
# Changed variable "level" to "stacklevel" for proc level checking.
#
# Revision 1.1  2004/02/05 21:24:01  cms
# Commiting Files
#

#
# Used for emacs
# Local Variables:
# mode:tcl
# indent-tabs-mode:nil
# End:
