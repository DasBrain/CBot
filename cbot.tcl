proc ircsplit str {
	set res {}
	if {[string index $str 0] eq ":"} {
		lappend res [string range $str 1 [set first [string first " " $str]]-1]
		set str [string range $str 1+$first end]
	} else {
		lappend res {}
	}
	if {[set pos [string first " :" $str]] != -1} {
		lappend res {*}[split [string range $str 0 ${pos}-1]]
		lappend res [string range $str 2+$pos end]
	} else {
		lappend res {*}[split $str]
	}
	return $res
}

set sockChan [socket irc.technet.xi.ht 6667]
fconfigure $sockChan -translation crlf -buffering line
puts $sockChan "NICK foo"
puts $sockChan "USER username * * :foo"
puts $sockChan "PRIVMSG CT :hi"
while {![eof $sockChan]} {
	set line [gets $sockChan]
	puts ">> $line"
	set lline [ircsplit $line]
	switch -nocase -- [lindex $lline 1] {
		PING {puts $sockChan "PONG :[lindex $lline 2]"}
		001 {puts $sockChan "JOIN #test"}
		PRIVMSG {switch -- [lindex $lline 3] {
				!quit {
					puts $sockChan "QUIT :Requested"
					close $sockChan
					return
				}
			}
		}
	}
}