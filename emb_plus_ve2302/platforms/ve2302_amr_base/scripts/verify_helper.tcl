# Copyright (C) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

################################################################
# These are helper functions for building the Verify Mem Map
################################################################

#variable design_name
#variable verify_mem_file
#variable verify_mem_map
variable verify_board
#variable variant

# Generate ASCII
proc ascii32 {str} {

    set value 0

    for {set i 0} {$i < 4} {incr i} {
        if {$i < [string length $str]} {
            scan [string index $str $i] %c c
        } else {
            set c 0
        }

        set value [expr {($value << 8) | $c}]
    }

    return $value
}


##################################################################
# Generate types for the verify block
# Change for every new board
##################################################################

proc generate_verify_mem { cfg } {

variable verify_board

puts "DEBUG: Current BD = [current_bd_design]"

    dict with cfg {
        puts "variant=$variant"
        puts "mem_file=$mem_file"
        puts "map_file=$map_file"
        puts "verify_board=$verify_board"
        puts "design_name=$design_name"
    }


  # Create lists of the different types of blocks
  set gtm_list {}
  set gty_list {}
  set pwr_list {}

  # Walk through the address segments and build a list of GTM, GTY, and PWR instances
  # Only look at xdma_bypass_addr_mask/m_axi
  # because it makes it easier to get one copy
  # of the address segments.
  set segs [get_bd_addr_segs /STATIC_DESIGN/xdma_bypass_addr_mask/m_axi/*]

  foreach seg $segs {

    set offset [get_property OFFSET $seg]

    if {$offset eq ""} {
        continue
    }

    set slave [get_bd_addr_segs -of_objects $seg]

    #
    # Extract instance name
    #
    set fields [split $slave "/"]

    #
    # Examples:
    # gtwiz_versal_gtm_qsfp0_slr1
    # gtwiz_versal_gtyp_mcio1a_slr2
    # power_0
    #
    set inst [lindex $fields end-2]

    set range [get_property RANGE $seg]

    set entry [list $inst $offset $range]

    set seg_name [get_property NAME $seg]

    if {[regexp {^gtwiz_versal_gtm_} $inst]} {

        lappend gtm_list $entry

    } elseif {[regexp {^gtwiz_versal_gtyp_} $inst]} {

        lappend gty_list $entry

    } elseif {[regexp {^power_0} $inst]} {

        lappend pwr_list $entry

    } elseif {[regexp {_DDR_} $seg_name]} {
        set entry [list $seg_name $offset $range]
        lappend ddr_list $entry
    }
  }

  # Get a deterministic number for use in the lists
  set gtm_list [lsort -index 0 $gtm_list]
  set gty_list [lsort -index 0 $gty_list]
  set pwr_list [lsort -index 0 $pwr_list]



  # Build verify entries
  set verify_entries {}

  # Assign all the IDs for the different types of blocks.
  # The ID is used in the memory map file and the memory initialization file.
  # The ID is a 4 character string that is converted to a 32 bit value and stored in the memory initialization file.
  # The ID is also used in the memory map file to identify the block.

  # GTMs
  set idx 0

  foreach entry $gtm_list {
      lassign $entry inst offset range
      set type "GTM"
      set id $idx
      lappend verify_entries \
          [list $type $id $inst $offset $range]
      incr idx
  }

  # GTYs
  set idx 0

  foreach entry $gty_list {
      lassign $entry inst offset range
      set type "GTY"
      set id $idx
      lappend verify_entries \
          [list $type $id $inst $offset $range]
      incr idx
  }

  # PWRs
  set idx 0

  foreach entry $pwr_list {
      lassign $entry inst offset range
      set type "PWR"
      set id $idx
      lappend verify_entries \
          [list $type $id $inst $offset $range]
      incr idx
  }

  # DDRs (DDR_LOW0 is always DDR0 because it will always be there, whearas the others
  # may or may not be there, and may be an unknown number of regions, so they always be after DDR0 in the list)
    #
    # Examples:
    # DDR_LOW0 (8M) @ 0x1880_0000 = DDR0 << always DDR0
    # DDR_LOW1 = DDR1
    # DDR_LOW2 = DDR2

  set idx 1
  set ddr_low {}
  set ddr_other {}

  foreach entry $ddr_list {
      lassign $entry seg_name offset range
      set type "DDR"
      set id $idx
      if {[regexp {_DDR_LOW0$} $seg_name]} {
          lappend ddr_low $entry
      } else {
          lappend ddr_other $entry
      }
  }

  foreach entry $ddr_low {
      lassign $entry seg_name offset range
      lappend verify_entries \
          [list $type 0 $seg_name $offset $range]
  }

  foreach entry [lsort -index 0 $ddr_other] {
      lassign $entry seg_name offset range
      lappend verify_entries \
          [list $type $idx $seg_name $offset $range]
      incr idx
  }

#  # Sanity check
#  foreach entry $verify_entries {
#    lassign $entry id inst offset range
#    puts "$id  $inst $offset  $range"
#  }

  set variant_tag [variant_get $variant verify_tag]

  # Write the header to MEM file
  set fp [open $mem_file w]

  puts $fp "@00000000"
  # Magic word
  puts $fp [format "%08X" [ascii32 "BTST"]]
  # Version
  puts $fp "00000001"
  # header size
  puts $fp "00000040"
  # num entries
  puts $fp [format "%08X" [llength $verify_entries]]
  # entry size
  puts $fp "00000020"
  # module
  puts $fp [format "%08X" [ascii32 $variant_tag]]
  # board pt 1
  puts $fp [format "%08X" [ascii32 $verify_board]]
  # board pt 2
  puts $fp "00000000"
  # Reserved
  puts $fp [format "%08X" [ascii32 "RSVD"]]
  puts $fp [format "%08X" [ascii32 "RSVD"]]
  puts $fp [format "%08X" [ascii32 "RSVD"]]
  puts $fp [format "%08X" [ascii32 "RSVD"]]
  puts $fp [format "%08X" [ascii32 "RSVD"]]
  puts $fp [format "%08X" [ascii32 "RSVD"]]
  puts $fp [format "%08X" [ascii32 "RSVD"]]
  puts $fp [format "%08X" [ascii32 "RSVD"]]

  # Write the entries to MEM file
  foreach entry $verify_entries {

    lassign $entry type id inst offset range

    scan $offset %llx addr
    scan $range  %llx size

    set low  [expr {$addr & 0xFFFFFFFF}]
    set high [expr {($addr >> 32) & 0xFFFFFFFF}]
    set type [string toupper $type]

    puts $fp [format "%08X" [ascii32 $type]]
    puts $fp [format "%08X" $id]
    puts $fp [format "%08X" $low]
    puts $fp [format "%08X" $high]
    puts $fp [format "%08X" $size]
    # Reserved
    puts $fp "00000000"
    puts $fp "00000000"
    puts $fp "00000000"

  }

  close $fp

  # Now generate the map file
  set timestamp [clock format [clock seconds] \
    -format "%Y-%m-%d %H:%M:%S %Z"]

  set fp [open $map_file w]

  puts $fp "Verify Memory Map"
  puts $fp "================="
  puts $fp ""

  puts $fp "Project: $design_name"
  puts $fp "Board: $verify_board"
  puts $fp "Variant: $variant"
  puts $fp "Generated: $timestamp"
  puts $fp ""

  puts $fp [format "%-5s %-8s %-40s %-18s %-10s" \
      "TYPE" "ID" "INSTANCE" "ADDRESS" "SIZE"]

  puts $fp [string repeat "-" 90]

  foreach entry $verify_entries {

      lassign $entry type id inst offset range

      puts $fp [format "%-5s %-8s %-40s %-18s %-10s" \
          $type \
          $id \
          $inst \
          $offset \
          $range]
  }
  puts $fp "Entries    : [llength $verify_entries]"
  puts $fp ""
  close $fp
}
