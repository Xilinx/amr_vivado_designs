# Copyright (C) 2025, Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
#
# Post-process sdtgen partial-overlay DTSIs so they compile with dtc and apply
# cleanly as runtime device-tree overlays.
#
# Usage:
#   tclsh fix_partial_dtsi.tcl                 ;# fix all project_sdt partials
#   tclsh fix_partial_dtsi.tcl <file.dtsi> ... ;# fix only the given file(s)

# Set to 0 to KEEP the partial-fpga-config fragment (e.g. if you load the PDI
# via fpgautil -b <pdi> -o <dtbo> instead of programming it separately).
set REMOVE_FPGA_CONFIG 1

# Regexes (brace-quoted; \{ / \} match literal device-tree braces).
set NODE_ANY   {^(\s*)(?:([A-Za-z_][-\w]*)\s*:\s*)?([A-Za-z_][-\w@,.:+]*)\s*\{\s*$}
set NODE_LBL   {^(\s*)([A-Za-z_][-\w]*)\s*:\s*([A-Za-z_][-\w@,.:+]*)\s*\{\s*$}
set NODE_DEDUP {^\s*([A-Za-z_][-\w]*)\s*:\s*[A-Za-z_][-\w@,.]*\s*\{\s*$}
set REF_TARGET {^\s*&([A-Za-z_]\w*)\s*\{\s*$}

proc n_open  {s} { return [regexp -all -- {\{} $s] }
proc n_close {s} { return [regexp -all -- {\}} $s] }

# Exclusive end index of the node block opening at lines[i], by brace balance.
proc block_end {linesName i} {
    upvar 1 $linesName lines
    set n [llength $lines]
    set depth [expr {[n_open [lindex $lines $i]] - [n_close [lindex $lines $i]]}]
    set j [expr {$i + 1}]
    while {$j < $n && $depth > 0} {
        set l [lindex $lines $j]
        incr depth [expr {[n_open $l] - [n_close $l]}]
        incr j
    }
    return $j
}

# All labels referenced via &name.
proc collect_refs {linesName} {
    upvar 1 $linesName lines
    set refs [dict create]
    foreach l $lines {
        foreach tok [regexp -all -inline -- {&[A-Za-z_]\w*} $l] {
            dict set refs [string range $tok 1 end] 1
        }
    }
    return $refs
}

# All labels currently declared on nodes.
proc collect_labels {linesName} {
    upvar 1 $linesName lines
    global NODE_ANY
    set labels [dict create]
    foreach l $lines {
        if {[regexp $NODE_ANY $l -> ind lbl name]} {
            if {$lbl ne ""} { dict set labels $lbl 1 }
        }
    }
    return $labels
}

# ----------------------------------------------------------------------------
# Transforms (each takes a lines list, returns {newLines removedList})
# ----------------------------------------------------------------------------

proc remove_fpga_config {lines} {
    global REF_TARGET
    set out {}; set removed {}
    set n [llength $lines]; set i 0
    while {$i < $n} {
        set line [lindex $lines $i]
        if {[regexp $REF_TARGET $line -> lbl]} {
            set end [block_end lines $i]
            set hit 0
            for {set k $i} {$k < $end} {incr k} {
                set bl [lindex $lines $k]
                if {[string match *partial-fpga-config* $bl] || \
                    [string match *firmware-name* $bl]} { set hit 1; break }
            }
            if {$hit} {
                lappend removed $lbl
                set i $end
                if {$i < $n && [string trim [lindex $lines $i]] eq ""} { incr i }
                continue
            }
        }
        lappend out $line
        incr i
    }
    return [list $out $removed]
}

proc remove_aie_nodes {lines} {
    global NODE_ANY
    set out {}; set removed {}
    set n [llength $lines]; set i 0
    while {$i < $n} {
        set line [lindex $lines $i]
        if {[regexp $NODE_ANY $line -> ind lbl name]} {
            set hay "$lbl $name"
            set isaie 0
            foreach k {ai_engine aie_aperture aie_core_ref_clk} {
                if {[string match *$k* $hay]} { set isaie 1; break }
            }
            if {$isaie} {
                set end [block_end lines $i]
                lappend removed [expr {$lbl ne "" ? $lbl : $name}]
                set i $end
                continue
            }
        }
        lappend out $line
        incr i
    }
    return [list $out $removed]
}

proc remove_unreferenced_null_clocks {lines} {
    global NODE_ANY
    set refs [collect_refs lines]
    set out {}; set removed {}
    set n [llength $lines]; set i 0
    while {$i < $n} {
        set line [lindex $lines $i]
        if {[regexp $NODE_ANY $line -> ind lbl name]} {
            set end [block_end lines $i]
            set is_clock 0; set has_null 0
            for {set k $i} {$k < $end} {incr k} {
                set bl [lindex $lines $k]
                if {[string match *compatible* $bl] && [string match *fixed-clock* $bl]} { set is_clock 1 }
                if {[string match *clock-frequency* $bl] && [string match {*"NULL"*} $bl]} { set has_null 1 }
            }
            set short [lindex [split $name "@"] 0]
            if {$is_clock && $has_null && ![dict exists $refs $lbl] && ![dict exists $refs $short]} {
                lappend removed [expr {$lbl ne "" ? $lbl : $name}]
                set i $end
                continue
            }
        }
        lappend out $line
        incr i
    }
    return [list $out $removed]
}

proc dedup_labels {lines} {
    global NODE_DEDUP
    set seen [dict create]
    set out {}; set dropped {}
    set n [llength $lines]; set i 0
    while {$i < $n} {
        set line [lindex $lines $i]
        if {[regexp $NODE_DEDUP $line -> lbl]} {
            if {[dict exists $seen $lbl]} {
                set end [block_end lines $i]
                lappend dropped $lbl
                set i $end
                continue
            }
            dict set seen $lbl 1
        }
        lappend out $line
        incr i
    }
    return [list $out $dropped]
}

proc alias_short_labels {lines} {
    global NODE_LBL
    set refs [collect_refs lines]
    set labels [collect_labels lines]
    set out {}; set added {}
    foreach line $lines {
        if {[regexp $NODE_LBL $line -> ind lbl name]} {
            set short [lindex [split $name "@"] 0]
            if {[dict exists $refs $short] && $short ne $lbl && ![dict exists $labels $short]} {
                lappend out "${ind}${short}: ${lbl}: ${name} \{"
                dict set labels $short 1
                lappend added $short
                continue
            }
        }
        lappend out $line
    }
    return [list $out $added]
}

# ----------------------------------------------------------------------------
# Driver
# ----------------------------------------------------------------------------
proc fix_overlay {path} {
    global REMOVE_FPGA_CONFIG
    set f [open $path "r"]
    set content [read $f]
    close $f
    set lines [split $content "\n"]

    set rf {}
    if {$REMOVE_FPGA_CONFIG} { lassign [remove_fpga_config $lines] lines rf }
    lassign [remove_aie_nodes $lines]                lines ra
    lassign [remove_unreferenced_null_clocks $lines] lines rn
    lassign [dedup_labels $lines]                    lines rd
    lassign [alias_short_labels $lines]              lines rs

    set f [open $path "w"]
    puts -nonewline $f [join $lines "\n"]
    close $f
    puts "fix_partial_dtsi: patched $path"
    puts "                  fpga-config removed : $rf"
    puts "                  aie removed         : $ra"
    puts "                  null-clk removed    : $rn"
    puts "                  dup-label removed   : $rd"
    puts "                  short aliases added : $rs"
}

# If explicit files were passed, fix only those; otherwise fix every generated
# partial overlay under project_sdt/.
if {[llength $argv] > 0} {
    foreach p $argv { fix_overlay $p }
} else {
    foreach p [lsort [glob -nocomplain -- ./project_sdt/*/*_partial.dtsi]] {
        fix_overlay $p
    }
}
