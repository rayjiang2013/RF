proc ixAccessValidate::getSupPortUtilPpsInfo { ch ca po sp frameSize ratio Util Pps } {

        variable subPortRates
    
        upvar $Util util
        upvar $Pps  pps
    
        ixAccessSubPort     get $ch $ca $po $sp
        ixAccessAddrList    get $ch $ca $po $sp
    
        set numPortFrames   [ixAccessStreamQueue cget -numPortFrames]
        set absFrameSize    [expr $frameSize + [ixAccessStreamQueue cget -frameSizeAdjust]]
        set rateMode        [ixAccessTraffic cget -rateMode]
        set duration        [ixAccessTraffic cget -duration]
        set txMode          [ixAccessPort cget -txMode]
    
        set overhead            0
        set encapOrPreamble     8
        if { [ixAccessPort cget -cardType] == $::kIxAccessAtm} {
            set overhead        [expr [ixAccessSubPort cget -phyStartOverhead] + \
                                     [ixAccessSubPort cget -phyTrailOverhead]]
            set absFrameSize    [expr $absFrameSize - $overhead]
            set encapOrPreamble [ixAccessAddrList cget -encapsulation]
        }
    
        # Adjust the ratio for this subPort based on whether it is advance
        # schedular mode or packet stream mode
        set numFrames [ixAccessStreamQueue cget -numFrames]
        if { $txMode == $::kIxAccessAdvanceStream } {
            set ratio [mpexpr ($ratio * $numFrames) / $numPortFrames]
        }
    
        if { $rateMode  == $::kIxAccessLineUtilization } {
            set cfgUtil [mpexpr double([ixAccessTraffic cget -percentageLineRate])]
            set util    [mpexpr $cfgUtil * $ratio]
            set pps     [calculateFPS $ch $ca $po $util $absFrameSize $encapOrPreamble]
        } elseif { $rateMode == $::kIxAccessPacketPerSec } {
            set cfgPps  [mpexpr double([ixAccessTraffic cget -packetPerSecond])]
            set pps     [mpexpr $cfgPps * $ratio]
            set util    [calculatePercentMaxRate $ch $ca $po $pps $absFrameSize \
                             $encapOrPreamble]
        } else {
            set cfgBps  [mpexpr double([ixAccessTraffic cget -bitsPerSecond])]
            set bps     [mpexpr $cfgBps * $ratio]
            set pps     [mpexpr $bps / ([expr $absFrameSize + $overhead] * 8.)]
            set util    [calculatePercentMaxRate $ch $ca $po $pps $absFrameSize \
                             $encapOrPreamble]
        }
    
        set numStreamFrames [mpexpr $pps * $duration]
        if { $txMode == $::kIxAccessPacketStream } {
            set numStreamFrames [mpexpr ($numStreamFrames * $numFrames) / $numPortFrames]
        }
    
        set entry [list [expr $absFrameSize + $overhead] $util $pps $frameSize $numStreamFrames]
        lappend subPortRates($ch,$ca,$po,$sp) $entry
    
        return $numStreamFrames
    }
}
