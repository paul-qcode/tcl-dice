ns_register_proc POST /results.html dice_roller_results

proc dice_roller_results {} {

    set set_id [ns_conn form]

    set number  [ns_set get $set_id number]
    set faces   [ns_set get $set_id faces]
    set rolls   [ns_set get $set_id rolls]
    set discard [ns_set get $set_id discard]
    

    if { $number eq "" || $faces eq "" || $rolls eq "" } {
      ns_return 200 text/html "One of the fields was blank"
    }

    set html [dice_roller $faces $number $rolls $discard]

    set html_head {<!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
	  <title>Results</title>
	<style>table, tr, td, th {padding: 10px; margin:5px; border:1px solid grey;}</style>
        </head>
        <body>}

    set html_foot {</body></html>}
    
    ns_return 200 text/html "$html_head $html $html_foot"
}

ns_register_proc GET /fake-results.html dice_roller_tcl_results

proc dice_roller_tcl_results {} {
    set result [dice_roller_tcl 6 7 4 low]
    ns_return 200 text/html result
}



proc dice_roller {faces dice repeat {discard none}} {
    #| proc to roll {dice} number of dice with {faces} faces a {repeat} number of times.

    #| Append header for table of results
    set results "<table>"
    append results "<tr><th>Roll</th><th>Dice</th><th>Results</th><th>Removed</th><th>Total</th></tr>"
    
    for {set i 1} {$i <= $repeat} {incr i} {
	set rolls {}
	for {set j 1} {$j <= $dice} {incr j} {
	    #| Add a random number between 1 and the number of faces on the dice
	    lappend rolls [expr {int(rand()*$faces)+1}]
	}
	#| Sort the set of all rolls smallest to highest so we can manipulate
	set rolls [lsort -integer $rolls]
	#| Remove a result (optional) - Remove either the first roll or the last roll, doesn't matter if the results are duplicates
	#| (Don't remove all roles matching the highest or lowest roll - otherwise a yahtzee would be empty.
	switch $discard {
	    "low" {
		#| Remove the lowest result
		set removed [lindex $rolls 0]
		set rolls [lreplace $rolls 0 0]
	    }
	    "high" {
		#| Remove the highest result
		set listlen [expr [llength $rolls] - 1]
		set removed [lindex $rolls $listlen]		
	        set rolls [lreplace $rolls $listlen $listlen]
	    }
	    default {
		#| Leave results alone
		set removed "none"
	    }
	}

	set discard_output $discard[expr {$discard == "none" ? "" : " ($removed)"}]
	
	append results "<tr><td>$i</td><td>$dice x $faces-sides</td><td>$rolls</td><td>$discard_output</td><td>[listsum $rolls]</td></tr>"
    }

    append results "</table>"
    
    return $results
}

proc dice_roller_tcl {faces dice repeat {discard none}} {
    #| original proc of diceroller but configured to output formatted string instead of html
    set results {}
    lappend results [format "%-6s %-20s %-[expr $dice*2]s %-12s %s" Roll Dice Results Removed Total]
    
    for {set i 1} {$i <= $repeat} {incr i} {
	set rolls {}
	for {set j 1} {$j <= $dice} {incr j} {
	    lappend rolls [expr {int(rand()*$faces)+1}]
	}
	set rolls [lsort -integer $rolls]
	switch $discard {
	    "low" {
		set removed [lindex $rolls 0]
		set rolls [lreplace $rolls 0 0]
	    }
	    "high" {
		set listlen [expr [llength $rolls] - 1]
		set removed [lindex $rolls $listlen]		
	        set rolls [lreplace $rolls $listlen $listlen]
	    }
	    default {
		set removed "none"
	    }
	}
	lappend results [format "%-6d %-20s %-[expr $dice*2]s %-12s %d" $i "$dice x $faces-sides" \
			     $rolls "$discard[expr {$discard == "none" ? "" : " ($removed)"}]"  [pb::listsum $rolls]]
	
    }
    return $results
}

proc listsum {l} {
    #| Use mathop to sum all items in a list
    ::tcl::mathop::+ {*}$l
}

