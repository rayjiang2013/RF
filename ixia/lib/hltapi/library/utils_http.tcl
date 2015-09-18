proc ::ixia::ixLoadHttpAgent { args } {
    variable ixload_handles_array
    
#    debug "ixLoadHttpAgent: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixLoadGetOptionalArgs $args]]
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    # These default options are practically hard coded, so if IxLoad API
    # changes default values, then these should be changed also
    set defaultWebPages [list \
            /1b.html   /4k.html   /8k.html   /16k.html  /32k.html  \
            /64k.html  /128k.html /256k.html /512k.html /1024k.html]
    
    set defaultResponseHeaders [list \
            200_OK 404_PageNotFound  ]
    
    set defaultCookieLists [list \
            LoginCookie UserCookie ]
    
    array set client_agent_args {
        browser_emulation         browserEmulation
        cookie_jar_size           cookieJarSize
        cookie_reject_probability cookieRejectProbability
        cookie_support_enable     enableCookieSupport
        esm_enable                enableEsm
        esm                       esm
        http_proxy_enable         enableHttpProxy
        https_proxy_enable        enableHttpsProxy
        ip_preference             ipPreference
        follow_http_redirects     followHttpRedirects
        http_proxy                httpProxy
        https_proxy               httpsProxy
        http_version              httpVersion
        keep_alive                keepAlive
        max_persistent_requests   maxPersistentRequests
        max_sessions              maxSessions
        ssl_enable                enableSsl
        sequential_session_reuse  sequentialSessionReuse
        ssl_version               sslVersion
        certificate               certificate
        private_key               privateKey
        private_key_password      privateKeyPassword
        client_ciphers            clientCiphers
        tos_enable                enableTos
        tos                       tos
    }
    array set server_agent_args {
        accept_ssl_connections acceptSslConnections
        http_port              httpPort
        https_port             httpsPort
        request_timeout        requestTimeout
    }
    if {($mode == "add") || ($mode == "modify")} {
        if {[info exists browser_emulation]} {
            switch -- $browser_emulation {
                custom {
                    set browser_emulation $::HTTP_Client(kBrowserTypeNone)
                }
                ie5 {
                    set browser_emulation $::HTTP_Client(kBrowserTypeIE5)
                }
                ie6 {
                    set browser_emulation $::HTTP_Client(kBrowserTypeIE6)
                }
                mozilla {
                    set browser_emulation $::HTTP_Client(kBrowserTypeMozilla)
                }
                firefox {
                    set browser_emulation $::HTTP_Client(kBrowserTypeFirefox)
                }
            }
        }
        if {[info exists http_version]} {
            switch -- $http_version {
                1.0 {
                    set http_version $::HTTP_Client(kHttpVersion10)
                }
                1.1 {
                    set http_version $::HTTP_Client(kHttpVersion11)
                }
            }
        }
        if {[info exists ssl_version]} {
            switch -- $ssl_version {
                ssl2 {
                    set ssl_version $::HTTP_Client(kSslVersion2)
                }
                ssl3 {
                    set ssl_version $::HTTP_Client(kSslVersion3)
                }
                tls1 {
                    set ssl_version $::HTTP_Client(kTlsVersion1)
                }
            }
        }
    }
    switch -- $mode {
        add {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        must contain traffic handler for this agent."
                return $returnList
            }
            if {![info exists target]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -target \
                        must be specified."
                return $returnList
            }
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid configuration handle."
                return $returnList
            }
            # a new name for this IxLoad target Network
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_handle \
                    -type agent ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agent_name [keylget retCode handle]
#            debug "new agent handler = $agent_name"
            
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
                    -handle $handle -key [list ixload_handle target]]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set target        [lindex [keylget retCode value] 1]
            
            set _cmd [format "%s" "$ixLoadHandler agentList.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }
#            debug "ixLoad INDEX=$index"
            set _target [expr {($target == "client") ? "Client" : "Server"}]
            set _cmd [format "%s" "$ixLoadHandler \
                    agentList.appendItem -name $agent_name -protocol HTTP \
                    -type $_target -enable 1"]
            debug "$_cmd"
            if {[catch {eval $_cmd} handler]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $handler."
                return $returnList
            }
            
            set command ""
            switch -- $target {
                client {
                    foreach item [array names client_agent_args] {
                        if {[info exists $item]} {
                            set _param $client_agent_args($item)
                            append command "-$_param [set $item] "
                        }
                    }
                }
                server {
                    foreach item [array names server_agent_args] {
                        if {[info exists $item]} {
                            set _param $server_agent_args($item)
                            append command "-$_param [set $item] "
                        }
                    }
                }
            }
            if {$command != ""} {
                set _cmd [format "%s" "$ixLoadHandler \
                        agentList($index).config $command"]
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            if {[info exists certificate_file]} {
                if {[isUNIX]} {
                    if {[file exists $certificate_file]} {
                        set put_file [lindex [file split $certificate_file] end]
                        set dest_file [file join \
                            IxLoad/Client/tclext/remoteScriptingService \
                            [file tail $put_file]]
                        set _cmd [format "%s" "doFileTransfer put \
                             $certificate_file $dest_file"]
                        debug "$_cmd"
                        if {[catch {eval $_cmd} _error]} {
                            catch {::IxLoad delete $handler}
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                Could not transfer certificate file: $_error."
                            return $returnList
                        }
                        set certificate_file $put_file
                    } else {
                        catch {::IxLoad delete $handler}
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $certificate_file does not exist."
                        return $returnList
                    }
                }
                set _cmd [format "%s" "$ixLoadHandler \
                        agentList($index).importCertificate \
                        $certificate_file"]
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            Couldn't import certificate file.\n$error."
                    return $returnList
                }
            }
            if {[info exists private_key_file]} {
                if {[isUNIX]} {
                    if {[file exists $private_key_file]} {
                        set put_file [lindex [file split $private_key_file] end]
                        set dest_file [file join \
                            IxLoad/Client/tclext/remoteScriptingService \
                            [file tail $put_file]]
                        set _cmd [format "%s" "doFileTransfer put \
                             $private_key_file $dest_file"]
                        debug "$_cmd"
                        if {[catch {eval $_cmd} _error]} {
                            catch {::IxLoad delete $handler}
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                Could not transfer private key file: $_error."
                            return $returnList
                        }
                        set private_key_file $put_file
                    } else {
                        catch {::IxLoad delete $handler}
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $private_key_file does not exist."
                        return $returnList
                    }
                }
                set _cmd [format "%s" "$ixLoadHandler \
                        agentList($index).importPrivateKey \
                        $private_key_file"]
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            Couldn't import private key file.\n$error."
                    return $returnList
                }
            }
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            save                  \
                    -handle          $agent_name           \
                    -type            agent                 \
                    -target          $target               \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               ]
            
            set page_handles_list ""
            set header_handles_list ""
            set cookielist_handles_list ""
            set cookie_handles_list ""
            if {$target == "server"} {
                set webPageIndex 0
                foreach {webPage} $defaultWebPages {
                    
                    # a new name for this IxLoad target Network
                    set retCode [::ixia::ixLoadHandlesArrayCommand \
                            -mode get_handle \
                            -type page       ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    
                    set page_name [keylget retCode handle]
#                    debug "new page handler = $page_name"
                    
                    set retCode [::ixia::ixLoadHandlesArrayCommand \
                            -mode            save                  \
                            -handle          $page_name            \
                            -type            page                  \
                            -target          $target               \
                            -ixload_handle   $ixLoadHandler        \
                            -ixload_index    $webPageIndex         \
                            -parent_handle   $agent_name           ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    
                    incr webPageIndex
                    lappend page_handles_list $page_name
                }
                
                set responseHeaderIndex 0
                foreach {responseHeader} $defaultResponseHeaders {
                    # a new name for this IxLoad target header
                    set retCode [::ixia::ixLoadHandlesArrayCommand \
                            -mode get_handle \
                            -type header     ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    
                    set header_name [keylget retCode handle]
#                    debug "new header handler = $header_name"
                    
                    set retCode [::ixia::ixLoadHandlesArrayCommand \
                            -mode            save                  \
                            -handle          $header_name          \
                            -type            header                \
                            -target          $target               \
                            -ixload_handle   $ixLoadHandler        \
                            -ixload_index    $responseHeaderIndex  \
                            -parent_handle   $agent_name           ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    
                    incr responseHeaderIndex
                    lappend header_handles_list $header_name
                }
                
                set cookieListIndex 0
                foreach {cookieList} $defaultCookieLists {
                    # a new name for this IxLoad target cookieList
                    set retCode [::ixia::ixLoadHandlesArrayCommand \
                            -mode get_handle     \
                            -type cookielist     ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    
                    set cookielist_name [keylget retCode handle]
#                    debug "new cookielist handler = $cookielist_name"
                    
                    set retCode [::ixia::ixLoadHandlesArrayCommand \
                            -mode            save                  \
                            -handle          $cookielist_name      \
                            -type            cookielist            \
                            -target          $target               \
                            -ixload_handle   $ixLoadHandler        \
                            -ixload_index    $cookieListIndex      \
                            -parent_handle   $agent_name           ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    
                    
                    # a new name for this IxLoad target cookie
                    set retCode [::ixia::ixLoadHandlesArrayCommand \
                            -mode get_handle     \
                            -type cookie         ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    
                    set cookie_name1 [keylget retCode handle]
#                    debug "new cookie handler = $cookie_name1"
                    
                    set retCode [::ixia::ixLoadHandlesArrayCommand \
                            -mode            save                  \
                            -handle          $cookie_name1         \
                            -type            cookie                \
                            -target          $target               \
                            -ixload_handle   $ixLoadHandler        \
                            -ixload_index    0                     \
                            -parent_handle   $agent_name           ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    
                    # a new name for this IxLoad target cookie
                    set retCode [::ixia::ixLoadHandlesArrayCommand \
                            -mode get_handle     \
                            -type cookie         ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    
                    set cookie_name2 [keylget retCode handle]
#                    debug "new cookie handler = $cookie_name2"
                    
                    set retCode [::ixia::ixLoadHandlesArrayCommand \
                            -mode            save                  \
                            -handle          $cookie_name2         \
                            -type            cookie                \
                            -target          $target               \
                            -ixload_handle   $ixLoadHandler        \
                            -ixload_index    1                     \
                            -parent_handle   $agent_name           ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    
                    incr cookieListIndex
                    lappend cookielist_handles_list $cookielist_name
                    keylset returnList $cookielist_name.cookie_handles \
                            [list $cookie_name1 $cookie_name2]
                }
            }
            
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles $agent_name
            if {$page_handles_list != ""} {
                keylset returnList page_handles       $page_handles_list
            }
            if {$header_handles_list != ""} {
                keylset returnList header_handles     $header_handles_list
            }
            if {$cookielist_handles_list != ""} {
                keylset returnList cookielist_handles $cookielist_handles_list
            }
            
            return $returnList
        }
        remove {
            # check to see if handler is ok. It should be an agent handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid HTTP agent handle."
                return $returnList
            }
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
                    -handle $handle -key [list ixload_handle ixload_index]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set index         [lindex [keylget retCode value] 1]
            set _cmd [format "%s" "$ixLoadHandler agentList.deleteItem \
                    $index"]
            debug $_cmd
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        agent.\n$error."
                return $returnList
            }
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles ""
            return $returnList
        }
        modify {
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid HTTP agent handle."
                return $returnList
            }
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
                    -handle $handle -key [list ixload_handle ixload_index \
                    target]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set index         [lindex [keylget retCode value] 1]
            set target        [lindex [keylget retCode value] 2]
            
            set command ""
            switch -- $target {
                client {
                    foreach item [array names client_agent_args] {
                        if {[info exists $item]} {
                            set _param $client_agent_args($item)
                            append command "-$_param [set $item] "
                        }
                    }
                }
                server {
                    foreach item [array names server_agent_args] {
                        if {[info exists $item]} {
                            set _param $server_agent_args($item)
                            append command "-$_param [set $item] "
                        }
                    }
                }
            }
            if {$command != ""} {
                set _cmd [format "%s" "$ixLoadHandler \
                        agentList($index).config $command"]
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            if {[info exists certificate_file]} {
                if {[isUNIX]} {
                    if {[file exists $certificate_file]} {
                        set put_file [lindex [file split $certificate_file] end]
                        set dest_file [file join \
                            IxLoad/Client/tclext/remoteScriptingService \
                            [file tail $put_file]]
                        set _cmd [format "%s" "doFileTransfer put \
                             $certificate_file $dest_file"]
                        debug "$_cmd"
                        if {[catch {eval $_cmd} _error]} {
                            catch {::IxLoad delete $handler}
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                Could not transfer certificate file: $_error."
                            return $returnList
                        }
                        set certificate_file $put_file
                    } else {
                        catch {::IxLoad delete $handler}
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $certificate_file does not exist."
                        return $returnList
                    }
                }
                set _cmd [format "%s" "$ixLoadHandler \
                        agentList($index).importCertificate \
                        $certificate_file"]
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            Couldn't import certificate file.\n$error."
                    return $returnList
                }
            }
            if {[info exists private_key_file]} {
                if {[isUNIX]} {
                    if {[file exists $private_key_file]} {
                        set put_file [lindex [file split $private_key_file] end]
                        set dest_file [file join \
                            IxLoad/Client/tclext/remoteScriptingService \
                            [file tail $put_file]]
                        set _cmd [format "%s" "doFileTransfer put \
                             $private_key_file $dest_file"]
                        debug "$_cmd"
                        if {[catch {eval $_cmd} _error]} {
                            catch {::IxLoad delete $handler}
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                Could not transfer private key file: $_error."
                            return $returnList
                        }
                        set private_key_file $put_file
                    } else {
                        catch {::IxLoad delete $handler}
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $private_key_file does not exist."
                        return $returnList
                    }
                }
                set _cmd [format "%s" "$ixLoadHandler \
                        agentList($index).importPrivateKey \
                        $private_key_file"]
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            Couldn't import private key file.\n$error."
                    return $returnList
                }
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles $handle
            return $returnList
        }
        enable -
        disable {
            set flag [expr {( $mode == "disable" ) ? 0 : 1}]
            # check to see if handler is ok. It should be an agent handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid HTTP agent handle."
                return $returnList
            }
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
                    -handle $handle -key [list ixload_handle ixload_index \
                    target]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set index         [lindex [keylget retCode value] 1]
            if {[catch {$ixLoadHandler agentList($index).config \
                            -enable $flag} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Couldn't $mode \
                        this agent.\n$error"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList  handles $handle
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode \
                    must be specified."
            return $returnList
        }
    }
}


proc ::ixia::ixLoadHttpAction {args} {
    variable ixload_handles_array
    
#    debug "\nixLoadHttpAction: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixLoadGetOptionalArgs $args]]
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    array set valuesHltToIxLoad {
        none       None
        before     AbortBeforeRequest
        after      AbortAfterRequest
        get        "GET"
        get_ssl    "GET(SSL)"
        delete     "DELETE"
        head       "HEAD"
        head_ssl   "HEAD(SSL)"
        put        "PUT"
        put_ssl    "PUT(SSL)"
        post       "POST"
        post_ssl   "POST(SSL)"
        think      "{Think}"
        loop_begin "{LoopBegin}"
        loop_end   "{LoopEnd}"
    }
    
    array set action_args {
        abort         abort
        arguments     arguments
        command       command
        destination   destination
        page_handle   pageObject
    }
    
    switch -- $mode {
        add {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            if {![info exists command]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -command must be provided."
                return $returnList
            }
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    action                        ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set action_name [keylget retCode handle]
#            debug "new action handler = $action_name"
            
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle ixload_index \
                    type target]                               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set agentIndex    [lindex [keylget retCode value] 1]
            set handleType    [lindex [keylget retCode value] 2]
            set target        [lindex [keylget retCode value] 3]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            
            # check to see if target is valid (only client agent accepted)
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client agent handle."
                return $returnList
            }
            
            # check if page argument is valid
            if {[info exists page_handle]} {
                set match1  [regexp {^/#[0-9]+$} $page_handle match]
                set match2  [regexp {^/[0-9]+k.htm[l]{0,1}$} $page_handle match]
                set match3  [info exists ixload_handles_array($page_handle)]
                if {$match3} {
                    # get ixload handler
                    set retCode [::ixia::ixLoadHandlesArrayCommand     \
                            -mode     get_value                        \
                            -handle   $page_handle                     \
                            -key      [list ixload_handle ixload_index \
                            type target parent_handle]]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    set ixLoadPageHandler [lindex [keylget retCode value] 0]
                    set pageIndex         [lindex [keylget retCode value] 1]
                    set pageHandleType    [lindex [keylget retCode value] 2]
                    set pageTarget        [lindex [keylget retCode value] 3]
                    set pageAgentName     [lindex [keylget retCode value] 4]
                    
                    # get agent index
                    set retCode [::ixia::ixLoadHandlesArrayCommand \
                            -mode     get_value                    \
                            -handle   $pageAgentName               \
                            -key      ixload_index                 ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    set pageAgentIndex  [keylget retCode value]
                    
                    # check to see if page_handle is a valid page handle
                    if {$pageHandleType != "page"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -page_handle $page_handle is not a valid page\
                                handle."
                        return $returnList
                    }
                    # check to see if page_handle is a valid server page handle
                    if {$pageTarget != "server"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -page_handle $page_handle is not a valid server\
                                agent handle."
                        return $returnList
                    }
                    
                    set    _page_cmd "$ixLoadPageHandler "
                    append _page_cmd "agentList($pageAgentIndex)."
                    append _page_cmd "webPageList($pageIndex)."
                    append _page_cmd "cget -page"
                    
                    debug "$_page_cmd"
                    if {[catch {eval $_page_cmd} page_handle]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $page_handle."
                        return $returnList
                    }
                }
            }
           
            if {[isUNIX]} { 
                if {[string toupper $command] == "PUT" || [string toupper $command] == "PUT_SSL"} {
                    if {[info exists arguments]} {
                        # we have a real file for command put
                        # -arguments will contain the file to be transferred
                        if {[file exists $arguments]} {
                            set put_file [lindex [file split $arguments] end]
                            set dest_file [file join \
                                IxLoad/Client/tclext/remoteScriptingService \
                                [file tail $put_file]]
                            set _cmd [format "%s" "doFileTransfer put \
                                $arguments $dest_file"]
                            debug "$_cmd"
                            if {[catch {eval $_cmd} _error]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                    File $arguments can't be transferred: \
                                    $_error"
                                return $returnList
                            }
                            set arguments $put_file
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    File $arguments does not exist."
                            return $returnList
                        }
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                -arguments should contain the path of \
                                the file needed to be PUT."
                        return $returnList
                    }
                }
            }

            # check if destination is valid
            if {[info exists destination]} {
                set match1 [isIpAddressValid [lindex [split $destination :] 0]]
                set match2 [::ipv6::isValidAddress $destination]
                set match3 [info exists ixload_handles_array($destination)]
                if {$match3} {
                    set retCode [::ixia::ixLoadHandlesArrayCommand     \
                            -mode     get_value                        \
                            -handle   $destination                     \
                            -key      [list ixload_handle ixload_index \
                            type target]]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    set ixLoadDestHandler [lindex [keylget retCode value] 0]
                    set destAgentIndex    [lindex [keylget retCode value] 1]
                    set destHandleType    [lindex [keylget retCode value] 2]
                    set destTarget        [lindex [keylget retCode value] 3]
                    
                    # check to see if destination is a valid agent handle
                    if {$destHandleType != "agent"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -destination $destination is not a valid agent\
                                handle."
                        return $returnList
                    }
                    # check to see if destination is a valid server agent handle
                    if {$destTarget != "server"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -destination $destination is not a valid server\
                                agent handle."
                        return $returnList
                    }
                    
                    set _dest_cmd "$ixLoadDestHandler       \
                            agentList($destAgentIndex).cget \
                            -name"
                            
                    debug $_dest_cmd
                    if {[catch {eval $_dest_cmd} destination]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $destination."
                        return $returnList
                    }
                    set _dest_cmd "$ixLoadHandler       \
                            agentList($agentIndex).cget \
                            -enableSsl"
                    
                    debug $_dest_cmd
                    if {[catch {eval $_dest_cmd} _sslEnabled]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $_sslEnabled."
                        return $returnList
                    }
                    
                    if {$_sslEnabled == 1} {
                        set portType "httpsPort"
                    } else  {
                        set portType "httpPort"
                    }

                    set _dest_cmd "$ixLoadDestHandler       \
                        agentList($destAgentIndex).cget -$portType"
                    
                    debug $_dest_cmd
                    if {[catch {eval $_dest_cmd} httpPort]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $httpPort."
                        return $returnList
                    }
                    
                    set destination "$destination:$httpPort"
                    
                    # get the traffic name
                    set _dest_cmd "$ixLoadDestHandler cget -name"
                    debug $_dest_cmd
                    if {[catch {eval $_dest_cmd} _trafficName]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $_trafficName."
                        return $returnList
                    }
                    
                    set destination ${_trafficName}_${destination}
                }
                if {(!$match1) && (!$match2) && (!$match3)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -destination $destination is not valid."
                    return $returnList
                }
            }
            
            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler \
                    agentList($agentIndex).actionList.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }
#            debug "ixLoad INDEX=$index"
            
            set _command ""
            foreach item [array names action_args] {
                if {[info exists $item]} {
                    set _param $action_args($item)
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    append _command " -$_param \"[set $item]\" "
                }
            }
            
            if {$_command != ""} {
                set _cmd [format "%s" "$ixLoadHandler                \
                        agentList($agentIndex).actionList.appendItem \
                        $_command"]
                
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            save                  \
                    -handle          $action_name          \
                    -type            action                \
                    -target          $target               \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles $action_name
            return $returnList
        }
        remove {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid action handle."
                return $returnList
            }
            # get handler properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle ixload_index \
                    type target parent_handle]                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler   [lindex [keylget retCode value] 0]
            set actionIndex     [lindex [keylget retCode value] 1]
            set handleType      [lindex [keylget retCode value] 2]
            set target          [lindex [keylget retCode value] 3]
            set agentName       [lindex [keylget retCode value] 4]
            
            # get agent properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $agentName                       \
                    -key      ixload_index                     ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agentIndex [keylget retCode value]
            
            # check to see if handle is a valid action handle
            if {$handleType != "action"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid action handle."
                return $returnList
            }
            
            if {[catch {$ixLoadHandler \
                            agentList($agentIndex).actionList.deleteItem \
                            $actionIndex} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        action.\n$error."
                return $returnList
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        modify {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid action handle."
                return $returnList
            }
            # get handler properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle ixload_index \
                    type target parent_handle]                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler   [lindex [keylget retCode value] 0]
            set actionIndex     [lindex [keylget retCode value] 1]
            set handleType      [lindex [keylget retCode value] 2]
            set target          [lindex [keylget retCode value] 3]
            set agentName       [lindex [keylget retCode value] 4]
            
            # get agent properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $agentName                       \
                    -key      ixload_index                     ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agentIndex [keylget retCode value]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "action"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid action handle."
                return $returnList
            }
            
            # check to see if target is valid (only client agent accepted)
            if {$target != "client"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid client action handle."
                return $returnList
            }
            
            # check if page argument is valid
            if {[info exists page_handle]} {
                set match1  [regexp {^/#[0-9]+$} $page_handle match]
                set match2  [regexp {^/[0-9]+k.htm[l]{0,1}$} $page_handle match]
                set match3  [info exists ixload_handles_array($page_handle)]
                if {$match3} {
                    # get ixload handler
                    set retCode [::ixia::ixLoadHandlesArrayCommand     \
                            -mode     get_value                        \
                            -handle   $page_handle                     \
                            -key      [list ixload_handle ixload_index \
                            type target parent_handle]]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    set ixLoadPageHandler [lindex [keylget retCode value] 0]
                    set pageIndex         [lindex [keylget retCode value] 1]
                    set pageHandleType    [lindex [keylget retCode value] 2]
                    set pageTarget        [lindex [keylget retCode value] 3]
                    set pageAgentName     [lindex [keylget retCode value] 4]
                    
                    # get agent index
                    set retCode [::ixia::ixLoadHandlesArrayCommand \
                            -mode     get_value                    \
                            -handle   $pageAgentName               \
                            -key      ixload_index                 ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    set pageAgentIndex  [keylget retCode value]
                    
                    # check to see if page_handle is a valid page handle
                    if {$pageHandleType != "page"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -page_handle $page_handle is not a valid page\
                                handle."
                        return $returnList
                    }
                    # check to see if page_handle is a valid server page handle
                    if {$pageTarget != "server"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -page_handle $page_handle is not a valid server\
                                agent handle."
                        return $returnList
                    }
                    
                    set    _page_cmd "$ixLoadPageHandler "
                    append _page_cmd "agentList($pageAgentIndex)."
                    append _page_cmd "webPageList($pageIndex)."
                    append _page_cmd "cget -page"
                    
                    if {[catch {eval $_page_cmd} page_handle]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $page_handle."
                        return $returnList
                    }
                }
                if {(!$match1) && (!$match2) && (!$match3)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -page_handle $page_handle is not valid."
                    return $returnList
                }
            }
            
            # check if destination is valid
            if {[info exists destination]} {
                set match1 [isIpAddressValid [lindex [split $destination :] 0]]
                set match2 [::ipv6::isValidAddress $destination]
                set match3 [info exists ixload_handles_array($destination)]
                if {$match3} {
                    set retCode [::ixia::ixLoadHandlesArrayCommand     \
                            -mode     get_value                        \
                            -handle   $destination                     \
                            -key      [list ixload_handle ixload_index \
                            type target]]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    set ixLoadDestHandler [lindex [keylget retCode value] 0]
                    set destAgentIndex    [lindex [keylget retCode value] 1]
                    set destHandleType    [lindex [keylget retCode value] 2]
                    set destTarget        [lindex [keylget retCode value] 3]
                    
                    # check to see if destination is a valid agent handle
                    if {$destHandleType != "agent"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -destination $destination is not a valid agent\
                                handle."
                        return $returnList
                    }
                    # check to see if destination is a valid server agent handle
                    if {$destTarget != "server"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -destination $destination is not a valid server\
                                agent handle."
                        return $returnList
                    }
                    
                    set _dest_cmd "$ixLoadDestHandler       \
                            agentList($destAgentIndex).cget \
                            -name"
                    debug $_dest_cmd
                    if {[catch {eval $_dest_cmd} destination]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $destination."
                        return $returnList
                    }
                    set _dest_cmd "$ixLoadHandler       \
                            agentList($agentIndex).cget \
                            -enableSsl"
                    
                    debug $_dest_cmd
                    if {[catch {eval $_dest_cmd} _sslEnabled]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $_sslEnabled."
                        return $returnList
                    }
                    
                    if {$_sslEnabled == 1} {
                        set portType "httpsPort"
                    } else  {
                        set portType "httpPort"
                    }
                    
                    set _dest_cmd "$ixLoadDestHandler       \
                            agentList($destAgentIndex).cget -$portType"
                    
                    debug $_dest_cmd
                    if {[catch {eval $_dest_cmd} httpPort]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $httpPort."
                        return $returnList
                    }
                    
                    set destination "$destination:$httpPort"
                    
                    # get the traffic name
                    set _dest_cmd "$ixLoadDestHandler cget -name"
                    debug $_dest_cmd
                    if {[catch {eval $_dest_cmd} _trafficName]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                $_trafficName."
                        return $returnList
                    }
                    
                    set destination ${_trafficName}_${destination}
                }
                if {(!$match1) && (!$match2) && (!$match3)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -destination $destination is not valid."
                    return $returnList
                }
            }
            set _command ""
            foreach item [array names action_args] {
                if {[info exists $item]} {
                    set _param $action_args($item)
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    append _command " -$_param \"[set $item]\" "
                }
            }
            
            if {$_command != ""} {
                set _cmd [format "%s" "$ixLoadHandler                \
                        agentList($agentIndex).actionList($actionIndex).config \
                        $_command"]
                
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        enable -
        disable {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode $mode \
                    is not supported for -property action."
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode \
                    must be specified."
            return $returnList
        }
    }
}


proc ::ixia::ixLoadHttpPage {args} {
    variable ixload_handles_array
    
#    debug "\nixLoadHttpPage: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixLoadGetOptionalArgs $args]]
    regsub {\-payload_file[ ]+ANY} $opt_args {-payload_file SHIFT} opt_args
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    array set valuesHltToIxLoad {
        range $::PageObject(kPayloadTypeRange)
        file  $::PageObject(kPayloadTypeFile)
    }
    
    array set page_args {
        cookieListName    cookie
        headerItem        response
        url               page
        payload_file      payloadFile
        payload_size      payloadSize
        payload_type      payloadType
    }
    
    switch -- $mode {
        add {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            # get next handler
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    page                          ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set page_name [keylget retCode handle]
#            debug "new page handler = $page_name"
            
            # get handler properties
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list ixload_handle ixload_index type target]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set agentIndex    [lindex [keylget retCode value] 1]
            set handleType    [lindex [keylget retCode value] 2]
            set target        [lindex [keylget retCode value] 3]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            
            # check to see if target is valid (only server agent accepted)
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server agent handle."
                return $returnList
            }
            
            # check if cookielist_handle is valid
            if {[info exists cookielist_handle]} {
                set retCode [::ixia::ixLoadHandlesArrayCommand     \
                        -mode     get_value                        \
                        -handle   $cookielist_handle               \
                        -key      [list ixload_handle ixload_index \
                        type target parent_handle]]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                set ixLoadCookieListHandler [lindex [keylget retCode value] 0]
                set cookieListIndex         [lindex [keylget retCode value] 1]
                set cookieListHandleType    [lindex [keylget retCode value] 2]
                set cookieListTarget        [lindex [keylget retCode value] 3]
                set cookieListAgentName     [lindex [keylget retCode value] 4]
                
                # get agent properties
                set retCode [::ixia::ixLoadHandlesArrayCommand     \
                        -mode     get_value                        \
                        -handle   $cookieListAgentName             \
                        -key      ixload_index                     ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                set cookieListAgentIndex [keylget retCode value]
                
                # check to see if destination is a valid agent handle
                if {$cookieListHandleType != "cookielist"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -cookielist_handle $cookielist_handle is not\
                            a valid cookie handle."
                    return $returnList
                }
                # check to see if cookie is a valid server cookie handle
                if {$cookieListTarget != "server"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -cookielist_handle $cookielist_handle is not\
                            a valid server cookie handle."
                    return $returnList
                }
                
                set _name_cmd    "$ixLoadCookieListHandler "
                append _name_cmd "agentList($cookieListAgentIndex)."
                append _name_cmd "cookieList($cookieListIndex)."
                append _name_cmd "cget -name"
                
                debug $_name_cmd
                if {[catch {eval $_name_cmd} cookieListName]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            $cookieListName."
                    return $returnList
                }
            }
            
            # check if header_handle is valid
            if {[info exists header_handle]} {
                set retCode [::ixia::ixLoadHandlesArrayCommand     \
                        -mode     get_value                        \
                        -handle   $header_handle                   \
                        -key      [list ixload_handle ixload_index \
                        type target parent_handle]]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                set ixLoadHeaderHandler [lindex [keylget retCode value] 0]
                set headerIndex         [lindex [keylget retCode value] 1]
                set headerHandleType    [lindex [keylget retCode value] 2]
                set headerTarget        [lindex [keylget retCode value] 3]
                set headerAgentName     [lindex [keylget retCode value] 4]
                
                # get agent properties
                set retCode [::ixia::ixLoadHandlesArrayCommand \
                        -mode     get_value                    \
                        -handle   $headerAgentName             \
                        -key      ixload_index                 ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                set headerAgentIndex [keylget retCode value]
                
                # check to see if header_handle is a valid header
                if {$headerHandleType != "header"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -header_handle $header_handle is not\
                            a valid header handle."
                    return $returnList
                }
                # check to see if header_handle is a valid server header
                if {$headerTarget != "server"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -header_handle $header_handle is not\
                            a valid server header handle."
                    return $returnList
                }
                
                set    _name_cmd "$ixLoadHeaderHandler "
                append _name_cmd "agentList($headerAgentIndex)."
                append _name_cmd "responseHeaderList.getItem $headerIndex"
                
                debug $_name_cmd
                if {[catch {eval $_name_cmd} headerItem]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            $headerItem."
                    return $returnList
                }
            }
            
            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler \
                    agentList($agentIndex).webPageList.indexCount"]
            
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }
#            debug "ixLoad INDEX=$index"
            
            set _command ""
            foreach item [array names page_args] {
                if {[info exists $item]} {
                    set _param $page_args($item)
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    append _command " -$_param \"[set $item]\" "
                }
            }
            
            if {$_command != ""} {
                set _cmd [format "%s" "$ixLoadHandler                 \
                        agentList($agentIndex).webPageList.appendItem \
                        $_command"]
                
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            save                  \
                    -handle          $page_name            \
                    -type            page                  \
                    -target          $target               \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles $page_name
            return $returnList
        }
        remove {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid page handle."
                return $returnList
            }
            # get handler properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle ixload_index \
                    type target parent_handle]                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler   [lindex [keylget retCode value] 0]
            set pageIndex       [lindex [keylget retCode value] 1]
            set handleType      [lindex [keylget retCode value] 2]
            set target          [lindex [keylget retCode value] 3]
            set agentName       [lindex [keylget retCode value] 4]
            
            # get agent properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $agentName                       \
                    -key      ixload_index                     ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agentIndex [keylget retCode value]
            
            # check to see if handle is a valid action handle
            if {$handleType != "page"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid page handle."
                return $returnList
            }
            
            if {[catch {$ixLoadHandler \
                            agentList($agentIndex).webPageList.deleteItem \
                            $pageIndex} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        page.\n$error."
                return $returnList
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        modify {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid page handle."
                return $returnList
            }
            # get handler properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle ixload_index \
                    type target parent_handle]                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler   [lindex [keylget retCode value] 0]
            set pageIndex       [lindex [keylget retCode value] 1]
            set handleType      [lindex [keylget retCode value] 2]
            set target          [lindex [keylget retCode value] 3]
            set agentName       [lindex [keylget retCode value] 4]
            
            # get agent properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $agentName                       \
                    -key      ixload_index                     ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agentIndex [keylget retCode value]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "page"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid page handle."
                return $returnList
            }
            
            # check to see if target is valid (only server page accepted)
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server page handle."
                return $returnList
            }
            
            # check if cookielist_handle is valid
            if {[info exists cookielist_handle]} {
                set retCode [::ixia::ixLoadHandlesArrayCommand     \
                        -mode     get_value                        \
                        -handle   $cookielist_handle               \
                        -key      [list ixload_handle ixload_index \
                        type target parent_handle]]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                set ixLoadCookieListHandler [lindex [keylget retCode value] 0]
                set cookieListIndex         [lindex [keylget retCode value] 1]
                set cookieListHandleType    [lindex [keylget retCode value] 2]
                set cookieListTarget        [lindex [keylget retCode value] 3]
                set cookieListAgentName     [lindex [keylget retCode value] 4]
                
                # get agent properties
                set retCode [::ixia::ixLoadHandlesArrayCommand     \
                        -mode     get_value                        \
                        -handle   $cookieListAgentName             \
                        -key      ixload_index                     ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                set cookieListAgentIndex [keylget retCode value]
                
                # check to see if destination is a valid agent handle
                if {$cookieListHandleType != "cookielist"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -cookielist_handle $cookielist_handle is not\
                            a valid cookie handle."
                    return $returnList
                }
                # check to see if cookie is a valid server cookie handle
                if {$cookieListTarget != "server"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -cookielist_handle $cookielist_handle is not\
                            a valid server cookie handle."
                    return $returnList
                }
                
                set _name_cmd    "$ixLoadCookieListHandler "
                append _name_cmd "agentList($cookieListAgentIndex)."
                append _name_cmd "cookieList($cookieListIndex)."
                append _name_cmd "cget -name"
                
                debug $_name_cmd
                if {[catch {eval $_name_cmd} cookieListName]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            $cookieListName."
                    return $returnList
                }
            }
            
            # check if header_handle is valid
            if {[info exists header_handle]} {
                set retCode [::ixia::ixLoadHandlesArrayCommand     \
                        -mode     get_value                        \
                        -handle   $header_handle                   \
                        -key      [list ixload_handle ixload_index \
                        type target parent_handle]]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                set ixLoadHeaderHandler [lindex [keylget retCode value] 0]
                set headerIndex         [lindex [keylget retCode value] 1]
                set headerHandleType    [lindex [keylget retCode value] 2]
                set headerTarget        [lindex [keylget retCode value] 3]
                set headerAgentName     [lindex [keylget retCode value] 4]
                
                # get agent properties
                set retCode [::ixia::ixLoadHandlesArrayCommand \
                        -mode     get_value                    \
                        -handle   $headerAgentName             \
                        -key      ixload_index                 ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                set headerAgentIndex [keylget retCode value]
                
                # check to see if header_handle is a valid header
                if {$headerHandleType != "header"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -header_handle $header_handle is not\
                            a valid header handle."
                    return $returnList
                }
                # check to see if header_handle is a valid server header
                if {$headerTarget != "server"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -header_handle $header_handle is not\
                            a valid server header handle."
                    return $returnList
                }
                
                set    _name_cmd "$ixLoadHeaderHandler "
                append _name_cmd "agentList($headerAgentIndex)."
                append _name_cmd "responseHeaderList.getItem $headerIndex"
                
                debug $_name_cmd
                if {[catch {eval $_name_cmd} headerItem]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            $headerItem."
                    return $returnList
                }
            }
            
            set _command ""
            foreach item [array names page_args] {
                if {[info exists $item]} {
                    set _param $page_args($item)
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    append _command " -$_param \"[set $item]\" "
                }
            }
            
            if {$_command != ""} {
                set _cmd [format "%s" "$ixLoadHandler \
                        agentList($agentIndex).webPageList($pageIndex).config \
                        $_command"]
                
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        enable -
        disable {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode $mode \
                    is not supported for -property page."
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode \
                    must be specified."
            return $returnList
        }
    }
}


proc ::ixia::ixLoadHttpHeader {args} {
    variable ixload_handles_array
    
#    debug "\nixLoadHttpHeader: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixLoadGetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    array set valuesHltToIxLoad {
        expiration_mode,never
        $::ResponseHeader(kExpirationModeNever)
        expiration_mode,datetime
        $::ResponseHeader(kExpirationModeDateTime)
        expiration_mode,afterrequest
        $::ResponseHeader(kExpirationModeAfterRequest)
        expiration_mode,afterlastmodified
        $::ResponseHeader(kExpirationModeAfterLastModified)
        last_modified_mode,never
        $::ResponseHeader(kLastModifiedModeNever)
        last_modified_mode,datetime
        $::ResponseHeader(kLastModifiedModeDateTime)
    }
    
    array set header_args {
        code                         code
        expiration_mode              expirationMode
        expiration_datetime          expirationDateTimeValue
        expiration_afterrequest      expirationAfterRequestValue
        expiration_afterlastmodified expirationAfterLastModifiedValue
        last_modified_mode           lastModifiedMode
        last_modified_datetime       lastModifiedDateTimeValue
        last_modified_incr_enable    lastModifiedIncrementEnable
        last_modified_incr_by        lastModifiedIncrementBy
        last_modified_incr_for       lastModifiedIncrementFor
        mime_type                    mimeType
        response_name                name
        response_description         description
    }
    
    switch -- $mode {
        add {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            # get next handler
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    header                        ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set header_name [keylget retCode handle]
#            debug "new header handler = $header_name"
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list ixload_handle ixload_index type target]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set agentIndex    [lindex [keylget retCode value] 1]
            set handleType    [lindex [keylget retCode value] 2]
            set target        [lindex [keylget retCode value] 3]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            
            # check to see if target is valid (only server agent accepted)
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server agent handle."
                return $returnList
            }
            
            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler \
                    agentList($agentIndex).responseHeaderList.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }
#            debug "ixLoad INDEX=$index"
            
            set _command ""
            foreach item [array names header_args] {
                if {[info exists $item]} {
                    set _param $header_args($item)
                    if {[info exists valuesHltToIxLoad($item,[set $item])]} {
                        set $item $valuesHltToIxLoad($item,[set $item])
                    }
                    append _command " -$_param \"[set $item]\" "
                }
            }
            
            if {$_command != ""} {
                set _cmd [format "%s" "$ixLoadHandler                        \
                        agentList($agentIndex).responseHeaderList.appendItem \
                        $_command"]
                
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            save                  \
                    -handle          $header_name          \
                    -type            header                \
                    -target          $target               \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            set    _header_cmd "$ixLoadHandler "
            append _header_cmd "agentList($agentIndex)."
            append _header_cmd "responseHeaderList.getItem $index"
            debug $_header_cmd
            if {[catch {eval $_header_cmd} responseHeader]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $responseHeader."
                return $returnList
            }
            
            if {[info exists key] && [info exists value]} {
                foreach {key_elem} $key {value_elem} $value {
                    set _response_cmd "$responseHeader \
                            responseList.appendItem    \
                            -data \"$key_elem: $value\""
                    
                    debug $_response_cmd
                    if {[catch {eval $_response_cmd} handler]} {
                        catch {::IxLoad delete $handler}
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: $handler."
                        return $returnList
                    }
                }
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles $header_name
            return $returnList
        }
        remove {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid header handle."
                return $returnList
            }
            
            # get handler properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle ixload_index \
                    type target parent_handle]                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler   [lindex [keylget retCode value] 0]
            set headerIndex     [lindex [keylget retCode value] 1]
            set handleType      [lindex [keylget retCode value] 2]
            set target          [lindex [keylget retCode value] 3]
            set agentName       [lindex [keylget retCode value] 4]
            
            # get agent properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $agentName                       \
                    -key      ixload_index                     ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agentIndex [keylget retCode value]
            
            # check to see if handle is a valid action handle
            if {$handleType != "header"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid header handle."
                return $returnList
            }
            
            # check to see if target is valid (only server header accepted)
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server header handle."
                return $returnList
            }
            
            set    _remove_cmd "$ixLoadHandler "
            append _remove_cmd "agentList($agentIndex)."
            append _remove_cmd "responseHeaderList.deleteItem $headerIndex"
            
            if {[catch {eval $_remove_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        header.\n$error."
                return $returnList
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        modify {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid header handle."
                return $returnList
            }
            
            # get handler properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle ixload_index \
                    type target parent_handle]                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler   [lindex [keylget retCode value] 0]
            set headerIndex     [lindex [keylget retCode value] 1]
            set handleType      [lindex [keylget retCode value] 2]
            set target          [lindex [keylget retCode value] 3]
            set agentName       [lindex [keylget retCode value] 4]
            
            # get agent properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $agentName                       \
                    -key      ixload_index                     ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agentIndex [keylget retCode value]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "header"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid header handle."
                return $returnList
            }
            
            # check to see if target is valid (only server header accepted)
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server header handle."
                return $returnList
            }
            
            set _command ""
            foreach item [array names header_args] {
                if {[info exists $item]} {
                    set _param $header_args($item)
                    if {[info exists valuesHltToIxLoad($item,[set $item])]} {
                        set $item $valuesHltToIxLoad($item,[set $item])
                    }
                    append _command " -$_param \"[set $item]\" "
                }
            }
            
            if {$_command != ""} {
                set    _cmd "$ixLoadHandler "
                append _cmd "agentList($agentIndex)."
                append _cmd "responseHeaderList($headerIndex)."
                append _cmd "config $_command"
                
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }
            
            set    _header_cmd "$ixLoadHandler "
            append _header_cmd "agentList($agentIndex)."
            append _header_cmd "responseHeaderList.getItem $headerIndex"
            debug $_header_cmd
            if {[catch {eval $_header_cmd} responseHeader]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $responseHeader."
                return $returnList
            }
            
            if {[info exists key] && [info exists value]} {
                foreach {key_elem} $key {value_elem} $value {
                    set _response_cmd "$responseHeader \
                            responseList.appendItem    \
                            -data \"$key_elem: $value\""
                    
                    debug $_response_cmd
                    if {[catch {eval $_response_cmd} handler]} {
                        catch {::IxLoad delete $handler}
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: $handler."
                        return $returnList
                    }
                }
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        enable -
        disable {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode $mode \
                    is not supported for -property header."
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode \
                    must be specified."
            return $returnList
        }
    }
}


proc ::ixia::ixLoadHttpCookieList {args} {
    variable ixload_handles_array
    
#    debug "\nixLoadHttpCookieList: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixLoadGetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    array set valuesHltToIxLoad {
        cookielist_mode,ignore     $::CookieObject(kModeIgnore)
        cookielist_mode,setcookie1 $::CookieObject(kModeReflectSetCookie1)
        cookielist_mode,setcookie2 $::CookieObject(kModeReflectSetCookie2)
        cookielist_mode,normal     $::CookieObject(kModeNormal)
        type,setcookie1            $::CookieObject(kTypeSetCookie1)
        type,setcookie2            $::CookieObject(kTypeSetCookie2)
    }
    
    array set cookielist_args {
        cookielist_description description
        cookielist_mode        mode
        cookielist_name        name
        type                   type
    }
    
    switch -- $mode {
        add {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            # get next handler
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    cookielist                    ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set cookielist_name [keylget retCode handle]
#            debug "new cookielist handler = $cookielist_name"
            
            # get ixLoad handler
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle ixload_index type target]                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set agentIndex    [lindex [keylget retCode value] 1]
            set handleType    [lindex [keylget retCode value] 2]
            set target        [lindex [keylget retCode value] 3]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "agent"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            
            # check to see if target is valid (only server agent accepted)
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server agent handle."
                return $returnList
            }
            
            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler \
                    agentList($agentIndex).cookieList.indexCount"]
            
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }
#            debug "ixLoad INDEX=$index"
            
            set _command ""
            foreach item [array names cookielist_args] {
                if {[info exists $item]} {
                    set _param $cookielist_args($item)
                    if {[info exists valuesHltToIxLoad($item,[set $item])]} {
                        set $item $valuesHltToIxLoad($item,[set $item])
                    }
                    append _command " -$_param \"[set $item]\" "
                }
            }
            
            if {$_command != ""} {
                set _cmd [format "%s" "$ixLoadHandler                \
                        agentList($agentIndex).cookieList.appendItem \
                        $_command"]
                
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            save                  \
                    -handle          $cookielist_name      \
                    -type            cookielist            \
                    -target          $target               \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles $cookielist_name
            return $returnList
        }
        remove {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid cookielist handle."
                return $returnList
            }
            # get handler properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle ixload_index \
                    type target parent_handle]                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler   [lindex [keylget retCode value] 0]
            set cookieListIndex [lindex [keylget retCode value] 1]
            set handleType      [lindex [keylget retCode value] 2]
            set target          [lindex [keylget retCode value] 3]
            set agentName       [lindex [keylget retCode value] 4]
            
            # get agent properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $agentName                       \
                    -key      ixload_index                     ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agentIndex [keylget retCode value]
            
            # check to see if handle is a valid action handle
            if {$handleType != "cookielist"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid cookielist handle."
                return $returnList
            }
            
            set    _remove_cmd "$ixLoadHandler "
            append _remove_cmd "agentList($agentIndex)."
            append _remove_cmd "cookieList.deleteItem $cookieListIndex"
            
            if {[catch {eval $_remove_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        cookielist.\n$error."
                return $returnList
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        modify {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid cookielist handle."
                return $returnList
            }
            
            # get handler properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle ixload_index \
                    type target parent_handle]                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler   [lindex [keylget retCode value] 0]
            set cookieListIndex [lindex [keylget retCode value] 1]
            set handleType      [lindex [keylget retCode value] 2]
            set target          [lindex [keylget retCode value] 3]
            set agentName       [lindex [keylget retCode value] 4]
            
            # get agent properties
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $agentName                       \
                    -key      ixload_index                     ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agentIndex [keylget retCode value]
            
            # check to see if handle is a valid cookielist handle
            if {$handleType != "cookielist"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid cookielist handle."
                return $returnList
            }
            
            # check to see if target is valid (only server cookielist accepted)
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server cookielist handle."
                return $returnList
            }
            
            set _command ""
            foreach item [array names cookielist_args] {
                if {[info exists $item]} {
                    set _param $cookielist_args($item)
                    if {[info exists valuesHltToIxLoad($item,[set $item])]} {
                        set $item $valuesHltToIxLoad($item,[set $item])
                    }
                    append _command " -$_param \"[set $item]\" "
                }
            }
            
            if {$_command != ""} {
                set    _cmd "$ixLoadHandler "
                append _cmd "agentList($agentIndex)."
                append _cmd "cookieList($cookieListIndex)."
                append _cmd "config $_command"
                
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        enable -
        disable {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode $mode \
                    is not supported for -property cookielist."
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode \
                    must be specified."
            return $returnList
        }
    }
}


proc ::ixia::ixLoadHttpCookie {args} {
    variable ixload_handles_array
    
#    debug "\nixLoadHttpCookie: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixLoadGetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    array set valuesHltToIxLoad {
    }
    
    array set cookie_args {
        domain       domain
        max_age      maxAge
        cookie_name  name
        path         path
        cookie_value value
    }
    
    switch -- $mode {
        add {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            # get next handler
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    cookie                        ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set cookie_name [keylget retCode handle]
#            debug "new cookie handler = $cookie_name"
            
            # get ixLoad handler
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle ixload_index \
                    type target parent_handle]                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler   [lindex [keylget retCode value] 0]
            set cookieListIndex [lindex [keylget retCode value] 1]
            set handleType      [lindex [keylget retCode value] 2]
            set target          [lindex [keylget retCode value] 3]
            set agentName       [lindex [keylget retCode value] 4]
            
            # get agent index
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $agentName                   \
                    -key      ixload_index                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agentIndex [keylget retCode value]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "cookielist"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid cookielist handle."
                return $returnList
            }
            
            # check to see if target is valid (only server agent accepted)
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server cookielist\
                        handle."
                return $returnList
            }
            
            # finding the future index of this element
            set    _cmd "$ixLoadHandler "
            append _cmd "agentList($agentIndex)."
            append _cmd "cookieList($cookieListIndex)."
            append _cmd "cookieContentList.indexCount"
            
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $index."
                return $returnList
            }
#            debug "ixLoad INDEX=$index"
            
            set _command ""
            foreach item [array names cookie_args] {
                if {[info exists $item]} {
                    set _param $cookie_args($item)
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    append _command " -$_param \"[set $item]\" "
                }
            }
            
            if {$_command != ""} {
                set    _cmd "$ixLoadHandler "
                append _cmd "agentList($agentIndex)."
                append _cmd "cookieList($cookieListIndex)."
                append _cmd "cookieContentList."
                append _cmd "appendItem $_command"
                
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            save                  \
                    -handle          $cookie_name          \
                    -type            cookie                \
                    -target          $target               \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles $cookie_name
            return $returnList
        }
        remove {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid cookie handle."
                return $returnList
            }
            # get ixLoad handler
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle ixload_index \
                    type target parent_handle]                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler   [lindex [keylget retCode value] 0]
            set cookieIndex     [lindex [keylget retCode value] 1]
            set handleType      [lindex [keylget retCode value] 2]
            set target          [lindex [keylget retCode value] 3]
            set cookieListName  [lindex [keylget retCode value] 4]
            
            # get cookieList index
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $cookieListName                  \
                    -key      [list ixload_index parent_handle]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set cookieListIndex   [lindex [keylget retCode value] 0]
            set agentName         [lindex [keylget retCode value] 1]
            
            # get agent index
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $agentName                   \
                    -key      ixload_index                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agentIndex [keylget retCode value]
            
            # check to see if handle is a valid action handle
            if {$handleType != "cookie"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid cookie handle."
                return $returnList
            }
            
            set    _remove_cmd "$ixLoadHandler "
            append _remove_cmd "agentList($agentIndex)."
            append _remove_cmd "cookieList($cookieListIndex)."
            append _remove_cmd "cookieContentList."
            append _remove_cmd "deleteItem $cookieIndex"
            
            if {[catch {eval $_remove_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        cookie.\n$error."
                return $returnList
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        modify {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid cookie handle."
                return $returnList
            }
            # get ixLoad handler
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $handle                          \
                    -key      [list ixload_handle ixload_index \
                    type target parent_handle]                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler   [lindex [keylget retCode value] 0]
            set cookieIndex     [lindex [keylget retCode value] 1]
            set handleType      [lindex [keylget retCode value] 2]
            set target          [lindex [keylget retCode value] 3]
            set cookieListName  [lindex [keylget retCode value] 4]
            
            # get cookieList index
            set retCode [::ixia::ixLoadHandlesArrayCommand     \
                    -mode     get_value                        \
                    -handle   $cookieListName                  \
                    -key      [list ixload_index parent_handle]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set cookieListIndex   [lindex [keylget retCode value] 0]
            set agentName         [lindex [keylget retCode value] 1]
            
            # get agent index
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $agentName                   \
                    -key      ixload_index                 ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set agentIndex [keylget retCode value]
            
            # check to see if handle is a valid cookie handle
            if {$handleType != "cookie"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid cookie handle."
                return $returnList
            }
            
            # check to see if target is valid (only server cookie accepted)
            if {$target != "server"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid server cookie handle."
                return $returnList
            }
            
            set _command ""
            foreach item [array names cookielist_args] {
                if {[info exists $item]} {
                    set _param $cookielist_args($item)
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    append _command " -$_param \"[set $item]\" "
                }
            }
            
            if {$_command != ""} {
                set    _cmd "$ixLoadHandler "
                append _cmd "agentList($agentIndex)."
                append _cmd "cookieList($cookieListIndex)."
                append _cmd "cookieContentList($cookieIndex)."
                append _cmd "config $_command"
                
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        enable -
        disable {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode $mode \
                    is not supported for -property cookielist."
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode \
                    must be specified."
            return $returnList
        }
    }
}
